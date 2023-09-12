# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway
resource "azurerm_virtual_network_gateway" "this" {
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = "${var.name_prefix}vgw${var.name_suffix}-${var.name}"
  tags                = var.tags

  type     = try(var.type, "Vpn")
  vpn_type = try(var.vpn_type, "RouteBased")
  sku      = try(var.sku, "Basic")

  active_active                    = try(var.active_active, false)
  default_local_network_gateway_id = try(var.default_local_network_gateway_id, null)
  edge_zone                        = try(var.edge_zone, null)
  enable_bgp                       = try(var.enable_bgp, false)
  generation                       = try(var.generation, null)
  private_ip_address_enabled       = try(var.private_ip_address_enabled, null)

  dynamic "ip_configuration" {
    for_each = var.ip_configuration
    content {
      name                          = ip_configuration.value.name
      public_ip_address_id          = try(ip_configuration.value.create_public_ip, false) ? azurerm_public_ip.this[ip_configuration.value.name].id : try(data.azurerm_public_ip.exists[ip_configuration.value.name].id, null)
      private_ip_address_allocation = try(ip_configuration.value.private_ip_address_allocation, "Dynamic")
      subnet_id                     = ip_configuration.value.subnet_id
    }
  }

  dynamic "vpn_client_configuration" {
    for_each = var.vpn_client_configuration
    content {
      address_space = try(vpn_client_configuration.value.address_space, null)
      aad_tenant    = try(vpn_client_configuration.value.aad_tenant, null)
      aad_audience  = try(vpn_client_configuration.value.aad_audience, null)
      aad_issuer    = try(vpn_client_configuration.value.aad_issuer, null)
      dynamic "root_certificate" {
        for_each = try(vpn_client_configuration.value.root_certificate, null) != null ? { for t in vpn_client_configuration.value.root_certificate : t.name => t } : {}
        content {
          name             = root_certificate.value.name
          public_cert_data = root_certificate.value.public_cert_data
        }
      }
      dynamic "revoked_certificate" {
        for_each = try(vpn_client_configuration.value.revoked_certificate, null) != null ? { for t in vpn_client_configuration.value.revoked_certificate : t.name => t } : {}
        content {
          name       = revoked_certificate.value.name
          thumbprint = revoked_certificate.value.thumbprint
        }
      }
      radius_server_address = try(vpn_client_configuration.value.radius_server_address, null)
      radius_server_secret  = try(vpn_client_configuration.value.radius_server_secret, null)
      vpn_client_protocols  = try(vpn_client_configuration.value.vpn_client_protocols, null)
      vpn_auth_types        = try(vpn_client_configuration.value.vpn_auth_types, null)
    }
  }

  dynamic "bgp_settings" {
    for_each = [var.local_bgp_settings]
    content {
      asn = try(bgp_settings.value.asn, null)
      dynamic "peering_addresses" {
        for_each = try(bgp_settings.value.peering_addresses, {})
        content {
          ip_configuration_name = try(peering_addresses.key, null)
          apipa_addresses       = [for i in try(peering_addresses.value.apipa_addresses, []) : var.azure_bgp_peers_addresses[i]]
          default_addresses     = try(peering_addresses.value.default_addresses, null)
        }
      }
      peer_weight = try(bgp_settings.value.peer_weight, null)
    }
  }

  dynamic "custom_route" {
    for_each = var.custom_route
    content {
      address_prefixes = try(custom_route.value.address_prefixes, null)
    }
  }

  lifecycle {
    precondition {
      condition = (contains(["VpnGw2", "VpnGw3", "VpnGw4", "VpnGw5", "VpnGw2AZ", "VpnGw3AZ", "VpnGw4AZ", "VpnGw5AZ"], var.sku) && coalesce(var.generation, "Generation1") == "Generation2"
      ) || (contains(["Basic", "Standard", "HighPerformance", "UltraPerformance", "ErGw1AZ", "ErGw2AZ", "ErGw3AZ", "VpnGw1", "VpnGw1AZ"], var.sku) && coalesce(var.generation, "Generation1") == "Generation1")
      error_message = "Generation2 is only value for a sku larger than VpnGw2 or VpnGw2AZ"
    }
    precondition {
      condition     = var.active_active && length(keys(var.local_bgp_settings.peering_addresses)) == 2 || !var.active_active && length(keys(var.local_bgp_settings.peering_addresses)) == 1
      error_message = "Map of peering addresses has to contain 1 (for active-standby) or 2 objects (for active-active)."
    }
    precondition {
      condition     = var.active_active && length(keys(var.azure_bgp_peers_addresses)) >= 2 || !var.active_active && length(keys(var.azure_bgp_peers_addresses)) >= 1
      error_message = "For active-standby you need to configure at least 1 custom Azure APIPA BGP IP address, for active-active at least 2."
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
resource "azurerm_public_ip" "this" {
  for_each = { for ip_configuration in var.ip_configuration :
    ip_configuration.name => try(ip_configuration.public_ip_standard_sku, false)
  if ip_configuration.create_public_ip }

  resource_group_name = var.resource_group_name
  location            = var.location
  name                = "${var.name_prefix}pip-vgw${var.name_suffix}-${each.key}"

  allocation_method = each.value ? "Static" : "Dynamic"
  zones             = var.enable_zones ? var.avzones : null
  tags              = var.tags
  sku               = each.value ? "Standard" : "Basic"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip
data "azurerm_public_ip" "exists" {
  for_each = { for ip_configuration in var.ip_configuration : ip_configuration.name => ip_configuration.public_ip_name if ip_configuration.public_ip_name != null }

  name                = each.value
  resource_group_name = var.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway 
resource "azurerm_local_network_gateway" "this" {
  for_each = var.local_network_gateways

  name                = "${var.name_prefix}lgw-vgw${var.name_suffix}-${each.value.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = each.value.gateway_address
  address_space       = try(each.value.address_space, [])

  dynamic "bgp_settings" {
    for_each = each.value.remote_bgp_settings
    content {
      asn                 = try(bgp_settings.value.asn, null)
      bgp_peering_address = try(bgp_settings.value.bgp_peering_address, null)
      peer_weight         = try(bgp_settings.value.peer_weight, null)
    }
  }

  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection
resource "azurerm_virtual_network_gateway_connection" "this" {
  for_each = var.local_network_gateways

  name                = "${var.name_prefix}con-vgw${var.name_suffix}-${each.value.connection}"
  location            = var.location
  resource_group_name = var.resource_group_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
  local_network_gateway_id   = azurerm_local_network_gateway.this[each.key].id

  enable_bgp                     = try(var.enable_bgp, false)
  local_azure_ip_address_enabled = try(var.private_ip_address_enabled, true)
  shared_key                     = var.ipsec_shared_key

  dynamic "custom_bgp_addresses" {
    for_each = try(each.value.custom_bgp_addresses, {})
    content {
      primary   = try(var.azure_bgp_peers_addresses[custom_bgp_addresses.value.primary], null)
      secondary = try(var.azure_bgp_peers_addresses[custom_bgp_addresses.value.secondary], null)
    }
  }

  connection_mode = try(var.connection_mode, "Default")
  dynamic "ipsec_policy" {
    for_each = try(var.ipsec_policy, {})
    content {
      dh_group         = try(ipsec_policy.value.dh_group, null)
      ike_encryption   = try(ipsec_policy.value.ike_encryption, null)
      ike_integrity    = try(ipsec_policy.value.ike_integrity, null)
      ipsec_encryption = try(ipsec_policy.value.ipsec_encryption, null)
      ipsec_integrity  = try(ipsec_policy.value.ipsec_integrity, null)
      pfs_group        = try(ipsec_policy.value.pfs_group, null)
      sa_datasize      = try(ipsec_policy.value.sa_datasize, null)
      sa_lifetime      = try(ipsec_policy.value.sa_lifetime, null)
    }
  }

  tags = var.tags
}

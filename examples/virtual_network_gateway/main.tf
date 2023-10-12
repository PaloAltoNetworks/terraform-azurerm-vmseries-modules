# Create or source the Resource Group.
resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = "${var.name_prefix}${var.resource_group_name}"
  location = var.location

  tags = var.tags
}

data "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

locals {
  resource_group = var.create_resource_group ? azurerm_resource_group.this[0] : data.azurerm_resource_group.this[0]
}

# Manage the network required for the topology.
module "vnet" {
  source = "../../modules/vnet"

  for_each = var.vnets

  name                   = each.value.name
  create_virtual_network = each.value.create_virtual_network
  resource_group_name    = coalesce(each.value.resource_group_name, local.resource_group.name)
  location               = var.location

  address_space = each.value.address_space

  create_subnets          = each.value.create_subnets
  subnets                 = each.value.subnets
  network_security_groups = each.value.network_security_groups
  route_tables            = each.value.route_tables

  tags = var.tags
}

# Create virtual network gateway
module "vng" {
  source = "../../modules/virtual_network_gateway"

  for_each = var.virtual_network_gateways

  location            = var.location
  resource_group_name = local.resource_group.name
  name                = each.value.name
  avzones             = try(each.value.avzones, null)

  type     = try(each.value.type, null)
  vpn_type = try(each.value.vpn_type, null)
  sku      = try(each.value.sku, null)

  active_active                    = try(each.value.active_active, null)
  default_local_network_gateway_id = try(each.value.default_local_network_gateway_id, null)
  edge_zone                        = try(each.value.edge_zone, null)
  enable_bgp                       = try(each.value.enable_bgp, null)
  generation                       = try(each.value.generation, null)
  private_ip_address_enabled       = try(each.value.private_ip_address_enabled, null)

  ip_configuration = [
    for ip_configuration in each.value.ip_configuration : {
      name                          = try(ip_configuration.name, null)
      create_public_ip              = try(ip_configuration.create_public_ip, null)
      public_ip_name                = try(ip_configuration.public_ip_name, null)
      private_ip_address_allocation = try(ip_configuration.private_ip_address_allocation, null)
      subnet_id                     = try(module.vnet[ip_configuration.vnet_key].subnet_ids[ip_configuration.subnet_name], null)
    }
  ]

  vpn_client_configuration = [
    for vpn_client_configuration in try(each.value.vpn_client_configuration, []) : {
      address_space = try(vpn_client_configuration.address_space, null)
      aad_tenant    = try(vpn_client_configuration.aad_tenant, null)
      aad_audience  = try(vpn_client_configuration.aad_audience, null)
      aad_issuer    = try(vpn_client_configuration.aad_issuer, null)
      root_certificate = [
        for root_certificate in vpn_client_configuration.root_certificate : {
          name             = root_certificate.name
          public_cert_data = root_certificate.public_cert_data
        }
      ]
      revoked_certificate = [
        for revoked_certificate in vpn_client_configuration.revoked_certificate : {
          name       = revoked_certificate.name
          thumbprint = revoked_certificate.thumbprint
        }
      ]
      radius_server_address = try(vpn_client_configuration.radius_server_address, null)
      radius_server_secret  = try(vpn_client_configuration.radius_server_secret, null)
      vpn_client_protocols  = try(vpn_client_configuration.vpn_client_protocols, null)
      vpn_auth_types        = try(vpn_client_configuration.vpn_auth_types, null)
    }
  ]
  azure_bgp_peers_addresses = each.value.azure_bgp_peers_addresses
  local_bgp_settings        = each.value.local_bgp_settings
  custom_route = [
    for custom_route in try(each.value.custom_route, []) : {
      address_prefixes = try(custom_route.address_prefixes, null)
    }
  ]
  ipsec_shared_key       = each.value.ipsec_shared_key
  local_network_gateways = each.value.local_network_gateways
  connection_mode        = try(each.value.connection_mode, null)
  ipsec_policy           = try(each.value.ipsec_policy, [])

  tags = var.tags
}
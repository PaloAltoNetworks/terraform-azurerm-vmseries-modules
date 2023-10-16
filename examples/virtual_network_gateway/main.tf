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
  avzones             = each.value.avzones

  type     = each.value.type
  vpn_type = each.value.vpn_type
  sku      = each.value.sku

  active_active                    = each.value.active_active
  default_local_network_gateway_id = each.value.default_local_network_gateway_id
  edge_zone                        = each.value.edge_zone
  enable_bgp                       = each.value.enable_bgp
  generation                       = each.value.generation
  private_ip_address_enabled       = each.value.private_ip_address_enabled

  ip_configuration = [
    for ip_configuration in each.value.ip_configuration :
    merge(ip_configuration, { subnet_id = module.vnet[ip_configuration.vnet_key].subnet_ids[ip_configuration.subnet_name] })
  ]

  vpn_client_configuration  = each.value.vpn_client_configuration
  azure_bgp_peers_addresses = each.value.azure_bgp_peers_addresses
  local_bgp_settings        = each.value.local_bgp_settings
  custom_route              = each.value.custom_route
  ipsec_shared_key          = each.value.ipsec_shared_key
  local_network_gateways    = each.value.local_network_gateways
  connection_mode           = each.value.connection_mode
  ipsec_policy              = each.value.ipsec_policy

  tags = var.tags
}
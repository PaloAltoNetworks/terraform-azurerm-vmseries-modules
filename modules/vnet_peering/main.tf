# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network
data "azurerm_virtual_network" "local_peer" {
  name                = var.local_peer_config.vnet_name
  resource_group_name = var.local_peer_config.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network
data "azurerm_virtual_network" "remote_peer" {
  name                = var.remote_peer_config.vnet_name
  resource_group_name = var.remote_peer_config.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering
resource "azurerm_virtual_network_peering" "local" {
  name                         = var.local_peer_config.name
  resource_group_name          = var.local_peer_config.resource_group_name
  virtual_network_name         = var.local_peer_config.vnet_name
  remote_virtual_network_id    = data.azurerm_virtual_network.remote_peer.id
  allow_virtual_network_access = var.local_peer_config.allow_virtual_network_access
  allow_forwarded_traffic      = var.local_peer_config.allow_forwarded_traffic
  allow_gateway_transit        = var.local_peer_config.allow_gateway_transit
  use_remote_gateways          = var.local_peer_config.use_remote_gateways
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering
resource "azurerm_virtual_network_peering" "remote" {
  name                         = var.remote_peer_config.name
  resource_group_name          = var.remote_peer_config.resource_group_name
  virtual_network_name         = var.remote_peer_config.vnet_name
  remote_virtual_network_id    = data.azurerm_virtual_network.local_peer.id
  allow_virtual_network_access = var.remote_peer_config.allow_virtual_network_access
  allow_forwarded_traffic      = var.remote_peer_config.allow_forwarded_traffic
  allow_gateway_transit        = var.remote_peer_config.allow_gateway_transit
  use_remote_gateways          = var.remote_peer_config.use_remote_gateways
}
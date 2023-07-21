data "azurerm_virtual_network" "local_peer" {
  name                = var.local_peer_config.vnet_name
  resource_group_name = var.local_peer_config.resource_group_name
}

data "azurerm_virtual_network" "remote_peer" {
  name                = var.remote_peer_config.vnet_name
  resource_group_name = var.remote_peer_config.resource_group_name
}

resource "azurerm_virtual_network_peering" "local" {
  name                         = try(var.local_peer_config.name, "${var.local_peer_config.vnet_name}-to-${var.remote_peer_config.vnet_name}")
  resource_group_name          = var.local_peer_config.resource_group_name
  virtual_network_name         = var.local_peer_config.vnet_name
  remote_virtual_network_id    = data.azurerm_virtual_network.remote_peer.id
  allow_virtual_network_access = try(var.local_peer_config.allow_virtual_network_access, true)
  allow_forwarded_traffic      = try(var.local_peer_config.allow_forwarded_traffic, true)
  allow_gateway_transit        = try(var.local_peer_config.allow_gateway_transit, false)
  use_remote_gateways          = try(var.local_peer_config.use_remote_gateways, false)
}

resource "azurerm_virtual_network_peering" "remote" {
  name                         = try(var.remote_peer_config.name, "${var.remote_peer_config.vnet_name}-to-${var.local_peer_config.vnet_name}")
  resource_group_name          = var.remote_peer_config.resource_group_name
  virtual_network_name         = var.remote_peer_config.vnet_name
  remote_virtual_network_id    = data.azurerm_virtual_network.local_peer.id
  allow_virtual_network_access = try(var.remote_peer_config.allow_virtual_network_access, true)
  allow_forwarded_traffic      = try(var.remote_peer_config.allow_forwarded_traffic, true)
  allow_gateway_transit        = try(var.remote_peer_config.allow_gateway_transit, false)
  use_remote_gateways          = try(var.remote_peer_config.use_remote_gateways, false)
}
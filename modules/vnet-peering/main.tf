data "azurerm_virtual_network" "local" {
  name                = var.local_vnet_name
  resource_group_name = var.local_resource_group_name
}

data "azurerm_virtual_network" "peer" {
  name                = var.peer_vnet_name
  resource_group_name = var.peer_resource_group_name
}

resource "azurerm_virtual_network_peering" "local" {
  name                         = "${var.name_prefix}${var.local_vnet_name}-to-${var.peer_vnet_name}"
  resource_group_name          = var.local_resource_group_name
  virtual_network_name         = var.local_vnet_name
  remote_virtual_network_id    = data.azurerm_virtual_network.peer.id
  allow_virtual_network_access = var.local_allow_virtual_network_access
  allow_forwarded_traffic      = var.local_allow_forwarded_traffic
  allow_gateway_transit        = var.local_allow_gateway_transit
  use_remote_gateways          = var.local_use_remote_gateways
}

resource "azurerm_virtual_network_peering" "peer" {
  name                         = "${var.name_prefix}${var.peer_vnet_name}-to-${var.local_vnet_name}"
  resource_group_name          = var.peer_resource_group_name
  virtual_network_name         = var.peer_vnet_name
  remote_virtual_network_id    = data.azurerm_virtual_network.local.id
  allow_virtual_network_access = var.peer_allow_virtual_network_access
  allow_forwarded_traffic      = var.peer_allow_forwarded_traffic
  allow_gateway_transit        = var.peer_allow_gateway_transit
  use_remote_gateways          = var.peer_use_remote_gateways
}
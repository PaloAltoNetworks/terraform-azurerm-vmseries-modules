output "local_peering_name" {
  description = "The name of the local VNET peering."
  value       = azurerm_virtual_network_peering.local.name
}

output "remote_peering_name" {
  description = "The name of the remote VNET peering."
  value       = azurerm_virtual_network_peering.peer.name
}

output "public_mgmt_ip" {
  value       = [for k, v in azurerm_public_ip.this : azurerm_public_ip.this[k].ip_address]
  description = "Panorama public management IP address"
}

output "private_mgmt_ip" {
  value       = [for k, v in azurerm_network_interface.this : azurerm_network_interface.this[k].private_ip_address]
  description = "Panorama private management IP address"
}
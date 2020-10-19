
output "panorama-publicip" {
  value       = azurerm_public_ip.panorama-pip-mgmt.ip_address
  description = "Panorama Public IP address"
}

output "resource-group" {
  value       = azurerm_resource_group.panorama
  description = "Panorama Resource group resource"
}

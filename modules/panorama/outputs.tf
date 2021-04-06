
output "mgmt_ip_address" {
  description = "Panorama management IP address. If `public_ip` was `true`, it is a public IP address, otherwise a private IP address."
  value       = try(var.interface[0].public_ip, false) ? azurerm_public_ip.this[0].ip_address : azurerm_network_interface.this.ip_configuration[0].private_ip_address
}

output "interface" {
  description = "Panorama network interface. The `azurerm_network_interface` object."
  value       = azurerm_network_interface.this
}

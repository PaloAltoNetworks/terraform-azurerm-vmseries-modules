
output "panorama-publicip" {
  value       = [for k, v in azurerm_public_ip.this : azurerm_public_ip.this[k].ip_address]
  description = "Panorama Public IP address"
}

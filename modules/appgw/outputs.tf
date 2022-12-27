output "public_ip" {
  description = "A public IP assigned to the Application Gateway."
  value       = azurerm_public_ip.this.ip_address
}

output "public_domain_name" {
  description = "Public domain name assigned to the Application Gateway."
  value       = azurerm_public_ip.this.fqdn
}

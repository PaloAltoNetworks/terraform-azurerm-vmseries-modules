output "public_ip" {
  description = "A public IP assigned to the Application Gateway."
  value       = azurerm_public_ip.this.ip_address
}

output "public_domain_name" {
  description = "Public domain name assigned to the Application Gateway."
  value       = azurerm_public_ip.this.fqdn
}

output "application_gateway_backend_address_pool_id" {
  description = "The identifier of the Application Gateway backend address pool."
  value       = one(azurerm_application_gateway.this.backend_address_pool).id
}

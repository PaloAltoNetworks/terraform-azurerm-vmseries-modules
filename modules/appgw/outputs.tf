output "public_ip" {
  description = "A public IP assigned to the Application Gateway."
  value       = try(azurerm_public_ip.this[0].ip_address, data.azurerm_public_ip.this[0].ip_address)
}

output "public_domain_name" {
  description = "Public domain name assigned to the Application Gateway."
  value       = try(azurerm_public_ip.this[0].fqdn, data.azurerm_public_ip.this[0].fqdn)
}

output "backend_pool_id" {
  description = "The identifier of the Application Gateway backend address pool."
  value       = one(azurerm_application_gateway.this.backend_address_pool).id
}

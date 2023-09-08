output "backend_pool_ids" {
  description = "Backend pools' identifiers."
  value       = { for k, v in azurerm_lb_backend_address_pool.this : k => v.id }
}

output "frontend_ip_config_id" {
  description = "Frontend IP configuration identifier."
  value       = azurerm_lb.this.frontend_ip_configuration[0].id
}
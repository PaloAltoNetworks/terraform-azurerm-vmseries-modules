output "backend_pool_id" {
  value       = azurerm_lb_backend_address_pool.lb_backend.id
  description = "The identifier of the backend pool."
}

output "frontend_ip_configs" {
  value       = local.frontend_ip_configs
  description = "The Frontend configs of the loadbalancer."
}

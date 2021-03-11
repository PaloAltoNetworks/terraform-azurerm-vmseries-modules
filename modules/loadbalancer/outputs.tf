output "backend_pool_ids" {
  value       = { for k, v in azurerm_lb_backend_address_pool.lb_backend : v.name => v.id }
  description = "The IDs of the backend pools."
}

output "frontend_ip_configs" {
  value       = { for k, v in azurerm_lb.lb.frontend_ip_configuration : v.name => v.id }
  description = "The Frontend configs of the loadbalancer."
}

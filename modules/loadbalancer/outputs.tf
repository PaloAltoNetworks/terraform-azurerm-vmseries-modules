output "backend-pool-ids" {
  value       = { for k, v in azurerm_lb_backend_address_pool.lb-backend : v.name => v.id }
  description = "The ID of the backend pools."
}

output "frontend-ip-configs" {
  value       = { for k, v in azurerm_lb.lb.frontend_ip_configuration : v.name => v.id }
  description = "IP config resources of the load balancer."
}

output "backend-pools-id" {
  value       = [for v in azurerm_lb_backend_address_pool.lb-backend : map(v.name, v.id)]
  description = "The ID of the backend pools."
}

output "frontend-ip-configs" {
  value       = toset([for c in azurerm_lb.lb.frontend_ip_configuration : c.name])
  description = "IP config resources of the load balancer."
}

output "backend-pool-id" {
  description = "ID of outbound load balancer backend address pool."
  value       = azurerm_lb_backend_address_pool.lb-backend.id
}

output "frontend-ip-configs" {
  description = "IP configuration resources from outbound load balancers."
  value       = toset([for c in azurerm_lb.lb.frontend_ip_configuration : c.name])
}
output "pip-ips" {
  value = {
    for pip in azurerm_public_ip.this :
    pip.id => pip.ip_address
  }
  description = "All PIPs associated with the inbound load balancer."
}

output "backend-pool-id" {
  value       = azurerm_lb_backend_address_pool.lb-backend.id
  description = "The ID of the backend pool."

}
output "frontend-ip-configs" {
  value       = toset([for c in azurerm_lb.lb.frontend_ip_configuration : c.name])
  description = "IP config resources of the load balancer."
}

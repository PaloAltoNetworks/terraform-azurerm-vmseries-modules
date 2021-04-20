output "backend_pool_id" {
  value       = azurerm_lb_backend_address_pool.lb_backend.id
  description = "The identifier of the backend pool."
}

output "frontend_ip_configs" {
  value       = { for k, v in azurerm_lb.lb.frontend_ip_configuration : v.name => coalesce(try(data.azurerm_public_ip.exists[v.name].ip_address, ""), try(azurerm_public_ip.this[v.name].ip_address, ""), v.private_ip_address) }
  description = "The Frontend configs of the loadbalancer."
}

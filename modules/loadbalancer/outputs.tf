output "backend_pool_id" {
  description = "The identifier of the backend pool."
  value       = azurerm_lb_backend_address_pool.lb_backend.id
}

output "frontend_ip_configs" {
  description = "Map of IP addresses, one per each entry of `frontend_ips` input. Contains public IP address for the frontends that have it, private IP address otherwise."
  # value       = local.output_ips
  value = local.frontend_addresses
}

output "health_probe" {
  description = "The health probe object."
  value       = azurerm_lb_probe.probe
}

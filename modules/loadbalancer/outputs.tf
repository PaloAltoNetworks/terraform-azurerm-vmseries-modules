output "backend_pool_ids" {
  value       = { for k, v in azurerm_lb_backend_address_pool.lb_backend : v.name => v.id }
  description = "The IDs of the backend pools."
}

output "frontend_ip_configs" {
  #value       = { for k, v in azurerm_lb.lb.frontend_ip_configuration : v.name => coalesce(v.public_ip_address_id, v.private_ip_address) }
  value = { for k, v in azurerm_lb.lb.frontend_ip_configuration : v.name => coalesce(try(data.azurerm_public_ip.provided[v.name].ip_address, ""), try(azurerm_public_ip.this[v.name].ip_address, ""), v.private_ip_address) }

  description = "The Frontend configs of the loadbalancer."
}

#output "frontend_ip_configs" {
#  value       = { for k, v in azurerm_lb.lb.frontend_ip_configuration : v.name => v.id }
#  description = "The Frontend configs of the loadbalancer."
#}

output "public_data_regex" {
  value = { for k, v in local.frontend_ips : k => v.public_ip_data }
}
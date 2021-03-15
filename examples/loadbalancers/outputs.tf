output "private_backend_pool_ids" {
  value       = module.private_lb.backend_pool_ids
  description = "The ID of the private backend pools."
}

output "public_backend_pool_ids" {
  value       = module.public_lb.backend_pool_ids
  description = "The ID of the backend public pools."
}

output "private_frontend_ip_configs" {
  value       = module.private_lb.frontend_ip_configs
  description = "The Frontend configs of the loadtbalancer."
}

output "public_frontend_ip_configs" {
  value       = module.public_lb.frontend_ip_configs
  description = "The Frontend configs of the loadbalancer."
}

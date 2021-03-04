output "private-backend-pool-ids" {
  value       = module.private_lb.backend-pool-ids
  description = "The ID of the private backend pools."
}

output "public-backend-pool-ids" {
  value       = module.public_lb.backend-pool-ids
  description = "The ID of the backend public pools."
}

output "private-frontend-ip-configs" {
  value       = module.private_lb.frontend-ip-configs
  description = "IP config resources of the private load balancer."
}

output "public-frontend-ip-configs" {
  value       = module.public_lb.frontend-ip-configs
  description = "IP config resources of the public load balancer."
}
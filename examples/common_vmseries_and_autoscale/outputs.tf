output "username" {
  description = "Initial administrative username to use for VM-Series."
  value       = var.authentication.username
}

output "password" {
  description = "Initial administrative password to use for VM-Series."
  value       = local.password
  sensitive   = true
}

output "metrics_instrumentation_keys" {
  description = "The Instrumentation Key of the created instance(s) of Azure Application Insights."
  value       = try(module.ngfw_metrics[0].metrics_instrumentation_keys, null)
  sensitive   = true
}

output "lb_frontend_ips" {
  description = "IP Addresses of the load balancers."
  value       = length(var.load_balancers) > 0 ? { for k, v in module.load_balancer : k => v.frontend_ip_configs } : null
}

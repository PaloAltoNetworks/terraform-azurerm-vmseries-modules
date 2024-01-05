output "usernames" {
  description = "Initial firewall administrative usernames for all deployed Scale Sets."
  value       = { for k, v in module.vmss : k => v.username }
}

output "passwords" {
  description = "Initial firewall administrative passwords for all deployed Scale Sets."
  value       = { for k, v in module.vmss : k => v.password }
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

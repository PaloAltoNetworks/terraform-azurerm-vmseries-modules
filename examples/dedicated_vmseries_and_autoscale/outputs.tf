output "username" {
  description = "Initial administrative username to use for VM-Series."
  value       = var.vmseries_username
}

output "password" {
  description = "Initial administrative password to use for VM-Series."
  value       = local.vmseries_password
  sensitive   = true
}

output "metrics_instrumentation_keys" {
  description = "The Instrumentation Key of the created instance(s) of Azure Application Insights."
  value       = var.application_insights != null ? { for k, v in module.ai : k => v.metrics_instrumentation_key } : null
  sensitive   = true
}

output "lb_frontend_ips" {
  description = "IP Addresses of the load balancers."
  value       = length(var.load_balancers) > 0 ? { for k, v in module.load_balancer : k => v.frontend_ip_configs } : null
}

output "username" {
  description = "Initial administrative username to use for VM-Series."
  value       = var.username
}

output "password" {
  description = "Initial administrative password to use for VM-Series."
  value       = random_password.this.result
  sensitive   = true
}

output "metrics_instrumentation_key_inbound" {
  description = "The Instrumentation Key of the created instance of Azure Application Insights for Inbound firewalls. The instance is unused by default, but is ready to receive custom PAN-OS metrics from the firewalls. To use it, paste this Instrumentation Key into PAN-OS -> Device -> VM-Series -> Azure."
  value       = module.inbound_scale_set.metrics_instrumentation_key
  sensitive   = true
}

output "metrics_instrumentation_key_outbound" {
  description = "The Instrumentation Key of the created instance of Azure Application Insights for Outbound firewalls. The instance is unused by default, but is ready to receive custom PAN-OS metrics from the firewalls. To use it, paste this Instrumentation Key into PAN-OS -> Device -> VM-Series -> Azure."
  value       = module.outbound_scale_set.metrics_instrumentation_key
  sensitive   = true
}

output "inbound_frontend_ips" {
  value = module.inbound_lb.frontend_ip_configs
}

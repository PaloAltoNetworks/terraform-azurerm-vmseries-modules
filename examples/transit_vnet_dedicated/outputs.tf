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
  description = "The Instrumentation Key of the created instances of Azure Application Insights. An instance is unused by default, but is ready to receive custom PAN-OS metrics from the firewall. To use it, paste this Instrumentation Key into PAN-OS -> Device -> VM-Series -> Azure."
  value       = { for k, v in module.vmseries : k => v.metrics_instrumentation_key if v.metrics_instrumentation_key != null }
  sensitive   = true
}

output "lb_frontend_ips" {
  description = "IP Addresses of the load balancers."
  value       = { for k, v in module.load_balancer : k => v.frontend_ip_configs }
}

output "vmseries_mgmt_ip" {
  description = "IP addresses for the VMSeries management interface."
  value       = { for k, v in module.vmseries : k => v.mgmt_ip_address }
}
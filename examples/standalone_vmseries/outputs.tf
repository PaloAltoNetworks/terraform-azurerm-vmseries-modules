output "usernames" {
  description = "Initial administrative username to use for VM-Series."
  value       = { for k, v in local.authentication : k => v.username }
}

output "passwords" {
  description = "Initial administrative password to use for VM-Series."
  value       = { for k, v in local.authentication : k => v.password }
  sensitive   = true
}

output "natgw_public_ips" {
  description = "Nat Gateways Public IP resources."
  value = length(var.natgws) > 0 ? { for k, v in module.natgw : k => {
    pip        = v.natgw_pip
    pip_prefix = v.natgw_pip_prefix
  } } : null
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

output "vmseries_mgmt_ips" {
  description = "IP addresses for the VMSeries management interface."
  value       = { for k, v in module.vmseries : k => v.mgmt_ip_address }
}

output "bootstrap_storage_urls" {
  value     = length(var.bootstrap_storages) > 0 ? { for k, v in module.bootstrap : k => v.file_share_urls } : null
  sensitive = true
}

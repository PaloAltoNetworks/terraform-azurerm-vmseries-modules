output "username" {
  description = "Initial administrative username to use for VM-Series."
  value       = var.vmseries_common.username
}

output "password" {
  description = "Initial administrative password to use for VM-Series."
  value       = local.vmseries_password
  sensitive   = true
}

output "vmseries_mgmt_ips" {
  description = "IP addresses for VM-Series management."
  value       = { for k, v in module.vmseries : k => v.mgmt_ip_address }
}

output "gwlb_frontend_ip_configuration_ids" {
  description = "Configuration IDs of Gateway Load Balancers' frontends."
  value       = { for k, v in module.gwlb : k => v.frontend_ip_config_id }
}

output "appvms_username" {
  description = "Initial administrative username to use for application VMs."
  value       = var.appvms_common.username
  sensitive   = true
}

output "appvms_password" {
  description = "Initial administrative password to use for application VMs."
  value       = local.appvms_password
  sensitive   = true
}

output "lb_frontend_ips" {
  description = "IP addresses of the Load Balancers serving applications."
  value       = { for k, v in module.load_balancer : k => v.frontend_ip_configs }
}

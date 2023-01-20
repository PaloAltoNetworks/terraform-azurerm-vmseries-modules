output "username" {
  description = "Initial administrative username to use for VM-Series."
  value       = var.username
}

output "password" {
  description = "Initial administrative password to use for VM-Series."
  value       = local.password
  sensitive   = true
}

output "mgmt_ip_addresses" {
  description = "IP Addresses for VM-Series management (https or ssh)."
  value       = { for k, v in module.vmseries : k => v.mgmt_ip_address }
}

output "frontend_ips" {
  description = "IP Addresses of the load balancers."
  value       = { for k, v in module.load_balancer : k => v.frontend_ip_configs }
}
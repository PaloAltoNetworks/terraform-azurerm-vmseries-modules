output "username" {
  description = "Initial administrative username to use for VM-Series."
  value       = var.username
}

output "password" {
  description = "Initial administrative password to use for VM-Series."
  value       = coalesce(var.password, random_password.this.result)
  sensitive   = true
}

output mgmt_ip_addresses {
  description = "IP Addresses for VM-Series management (https or ssh)."
  value = merge(
    { for k, v in module.inbound_vmseries : k => v.mgmt_ip_address },
    { for k, v in module.outbound_vmseries : k => v.mgmt_ip_address },
  )
}

output frontend_ips {
  description = "IP Addresses of the inbound load balancer."
  value       = module.inbound_lb.frontend_ip_configs
}

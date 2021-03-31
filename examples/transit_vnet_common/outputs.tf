output "username" {
  description = "PAN Device username"
  value       = var.username
}

output "password" {
  description = "PAN Device password"
  value       = coalesce(var.password, random_password.this.result)
}

output mgmt_ip_addresses {
  value = { for k, v in module.common_vmseries : k => v.mgmt_ip_address }
}

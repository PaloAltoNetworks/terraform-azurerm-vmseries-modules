output "username" {
  description = "PAN Device username"
  value       = var.username
}

output "password" {
  description = "PAN Device password"
  value       = coalesce(var.password, random_password.password.result)
}

output mgmt_private_ip_addresses {
  value = { for k, v in module.common_vmseries : k => v.mgmt_ip_address }
}

output mgmt_public_ip_addresses {
  value = { for k, v in var.instances : k => azurerm_public_ip.mgmt[k].ip_address }
}

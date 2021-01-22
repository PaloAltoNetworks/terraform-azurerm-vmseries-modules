output "username" {
  description = "PAN Device username"
  value       = var.username
}

output "password" {
  description = "PAN Device password"
  value       = random_password.password.result
}

output ip_addresses {
  value = module.inbound-vm-series.ip_addresses
}

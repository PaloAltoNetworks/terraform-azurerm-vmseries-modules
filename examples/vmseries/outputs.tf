output "username" {
  description = "Initial administrative username to use for VM-Series."
  value       = var.username
}

output "password" {
  description = "Initial administrative password to use for VM-Series."
  value       = random_password.this.result
  sensitive   = true
}

output "mgmt_ip_addresses" {
  description = "IP Addresses for VM-Series management (https or ssh)."
  value       = module.vmseries.mgmt_ip_address
}

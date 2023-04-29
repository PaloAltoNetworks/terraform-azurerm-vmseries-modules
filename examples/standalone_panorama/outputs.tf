output "username" {
  description = "Initial administrative username to use for VM-Series."
  value       = var.vmseries_username
}

output "password" {
  description = "Initial administrative password to use for VM-Series."
  value       = local.vmseries_password
  sensitive   = true
}

output "panorama_mgmt_ips" {
  value = { for k, v in module.panorama : k => v.mgmt_ip_address }
}
output "username" {
  description = "Initial administrative username to use for VM-Series."
  value       = { for k, v in local.authentication : k => v.username }
}

output "password" {
  description = "Initial administrative password to use for VM-Series."
  value       = { for k, v in local.authentication : k => v.password }
  sensitive   = true
}

output "panorama_mgmt_ips" {
  value = { for k, v in module.panorama : k => v.mgmt_ip_address }
}
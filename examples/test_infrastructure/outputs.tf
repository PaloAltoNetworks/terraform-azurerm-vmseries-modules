output "username" {
  description = "Test VMs admin account."
  value       = var.username
}

output "password" {
  description = "Password for the admin user."
  value       = local.password
  sensitive   = true
}

output "vm_private_ips" {
  description = "A map of private IPs assigned to test VMs."
  value       = { for k, v in azurerm_network_interface.vm : k => v.private_ip_address }
}
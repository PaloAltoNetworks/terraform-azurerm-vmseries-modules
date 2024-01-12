output "scale_set_name" {
  description = "Name of the created scale set."
  value       = azurerm_linux_virtual_machine_scale_set.this.name
}

output "username" {
  description = "Firewall admin account name."
  value       = var.authentication.username
}

output "password" {
  description = "Firewall admin password"
  value       = local.password
  sensitive   = true
}
output "scale_set_name" {
  description = "Name of the created scale set."
  value       = azurerm_linux_virtual_machine_scale_set.this.name
}

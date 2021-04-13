output "inbound-scale-set-name" {
  description = "Name of inbound scale set."
  value       = azurerm_virtual_machine_scale_set.this.name
}

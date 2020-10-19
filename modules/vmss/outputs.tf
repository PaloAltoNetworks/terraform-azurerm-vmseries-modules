output "inbound-scale-set-name" {
  description = "Name of inbound scale set"

  value = azurerm_virtual_machine_scale_set.inbound-scale-set.name
}

output "outbound-scale-set-name" {
  description = "Name of outbound scale set"
  value       = azurerm_virtual_machine_scale_set.outbound-scale-set.name
}

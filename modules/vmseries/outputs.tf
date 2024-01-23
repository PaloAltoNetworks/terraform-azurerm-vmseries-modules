output "mgmt_ip_address" {
  description = "VM-Series management IP address. If `create_public_ip` was `true`, it is a public IP address, otherwise a private IP address."
  value = try(
    azurerm_public_ip.this[var.interfaces[0].name].ip_address,
    azurerm_network_interface.this[var.interfaces[0].name].ip_configuration[0].private_ip_address
  )
}

output "interfaces" {
  description = "Map of VM-Series network interfaces. Keys are equal to var.interfaces `name` properties."
  value       = azurerm_network_interface.this
}

output "principal_id" {
  description = "The ID of Azure Service Principal of the created VM-Series. Usable only if `identity_type` contains SystemAssigned."
  value       = var.virtual_machine.identity_type != null ? azurerm_linux_virtual_machine.this.identity[0].principal_id : null
}

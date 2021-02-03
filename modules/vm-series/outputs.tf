
output "ip_addresses" {
  description = "VM-Series management IP addresses."
  value       = { for k, v in var.instances : k => azurerm_network_interface.nic-fw-mgmt[k].ip_configuration[0].private_ip_address }
}

output "principal_id" {
  description = "A map of Azure Service Principals for each of the created VM-Series. Map's key is the same as virtual machine key, the value is an oid of a Service Principal. Usable only if `identity_type` contains SystemAssigned."
  value       = { for k, v in var.instances : k => azurerm_virtual_machine.this[k].identity[0].principal_id if var.identity_type != null && var.identity_type != "" }
}

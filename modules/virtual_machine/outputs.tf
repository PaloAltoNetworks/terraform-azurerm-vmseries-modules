output "public_ips" {
  description = "A map of public IPs created"
  value       = { for v in azurerm_public_ip.this : v.name => v.ip_address }
}

output "interfaces" {
  description = "List of interfaces. The elements of the list are `azurerm_network_interface` objects. The order is the same as `interfaces` input."
  value       = azurerm_network_interface.this
}

output "principal_id" {
  description = "The oid of Azure Service Principal of the created virtual machine. Usable only if `identity_type` contains SystemAssigned."
  value       = var.identity_type != null && var.identity_type != "" ? azurerm_virtual_machine.this.identity[0].principal_id : null
}

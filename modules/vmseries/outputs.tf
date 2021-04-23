output "mgmt_ip_address" {
  description = "VM-Series management IP address. If `create_public_ip` was `true`, it is a public IP address, otherwise a private IP address."
  value       = try(var.interfaces[0].create_public_ip, false) ? azurerm_public_ip.this[0].ip_address : azurerm_network_interface.this[0].ip_configuration[0].private_ip_address
}

output "interfaces" {
  description = "List of VM-Series network interfaces. The elements of the list are `azurerm_network_interface` objects. The order is the same as `interfaces` input."
  value       = azurerm_network_interface.this
}

output "principal_id" {
  description = "The oid of Azure Service Principal of the created VM-Series. Usable only if `identity_type` contains SystemAssigned."
  value       = var.identity_type != null && var.identity_type != "" ? azurerm_virtual_machine.this.identity[0].principal_id : null
}

output "metrics_instrumentation_key" {
  description = "The Instrumentation Key of the created instance of Azure Application Insights. The instance is unused by default, but is ready to receive custom PAN-OS metrics from the firewalls. To use it, paste this Instrumentation Key into PAN-OS -> Device -> VM-Series -> Azure."
  value       = try(azurerm_application_insights.this[0].instrumentation_key, null)
  sensitive   = true
}

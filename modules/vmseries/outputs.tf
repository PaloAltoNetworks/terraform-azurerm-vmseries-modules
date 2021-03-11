
output "mgmt_ip_address" {
  description = "VM-Series management IP addresses."
  value       = azurerm_network_interface.data[0].ip_configuration[0].private_ip_address
}

output "principal_id" {
  description = "The oid of Azure Service Principal of the created VM-Series. Usable only if `identity_type` contains SystemAssigned."
  value       = var.identity_type != null && var.identity_type != "" ? azurerm_virtual_machine.this.identity[0].principal_id : null
}

output "metrics_instrumentation_key" {
  description = "The Instrumentation Key of the created instance of Azure Application Insights. The instance is unused by default, but is ready to receive custom PAN-OS metrics from the firewalls. To use it, paste this Instrumentation Key into PAN-OS -> Device -> VM-Series -> Azure."
  value       = try(azurerm_application_insights.this[0].instrumentation_key, null)
}

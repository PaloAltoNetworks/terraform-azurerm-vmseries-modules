
output "ip_addresses" {
  description = "VM-Series management IP addresses."
  value       = { for k, v in var.instances : k => azurerm_network_interface.nic-fw-mgmt[k].ip_configuration[0].private_ip_address }
}

output "principal_id" {
  description = "A map of Azure Service Principals for each of the created VM-Series. Map's key is the same as virtual machine key, the value is an oid of a Service Principal. Usable only if `identity_type` contains SystemAssigned."
  value       = { for k, v in var.instances : k => azurerm_virtual_machine.this[k].identity[0].principal_id if var.identity_type != null && var.identity_type != "" }
}

output "metrics_instrumentation_key" {
  description = "The Instrumentation Key of the created instance of Azure Application Insights. The instance is unused by default, but is ready to receive custom PAN-OS metrics from the firewalls. To use it, paste this Instrumentation Key into PAN-OS -> Device -> VM-Series -> Azure."
  value       = try(azurerm_application_insights.this[0].instrumentation_key, null)
}

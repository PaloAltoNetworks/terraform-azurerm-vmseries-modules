output "scale_set_name" {
  description = "Name of the created scale set."
  value       = azurerm_linux_virtual_machine_scale_set.this.name
}

output "metrics_instrumentation_key" {
  description = "The Instrumentation Key of the created instance of Azure Application Insights. The instance is unused by default, but is ready to receive custom PAN-OS metrics from the firewalls. To use it, paste this Instrumentation Key into PAN-OS -> Device -> VM-Series -> Azure."
  value       = try(azurerm_application_insights.this[0].instrumentation_key, null)
  sensitive   = true
}

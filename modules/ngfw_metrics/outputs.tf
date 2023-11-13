output "metrics_instrumentation_keys" {
  description = "The Instrumentation Key of the created instance of Azure Application Insights."
  value       = { for k, v in azurerm_application_insights.this : k => v.instrumentation_key }
  sensitive   = true
}

output "application_insights_ids" {
  description = "An Azure ID of the Application Insights resource created by this module."
  value       = { for k, v in azurerm_application_insights.this : k => v.id }
}
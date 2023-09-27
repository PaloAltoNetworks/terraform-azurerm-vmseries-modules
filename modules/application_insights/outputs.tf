output "metrics_instrumentation_key" {
  description = "The Instrumentation Key of the created instance of Azure Application Insights."
  value       = azurerm_application_insights.this.instrumentation_key
  sensitive   = true
}

output "application_insights_id" {
  description = "An Azure ID of the Application Insights resource created by this module."
  value       = azurerm_application_insights.this.id
}
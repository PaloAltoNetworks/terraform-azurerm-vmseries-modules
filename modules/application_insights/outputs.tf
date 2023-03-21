output "metrics_instrumentation_key" {
  description = <<-EOF
  The Instrumentation Key of the created instance of Azure Application Insights. 
  
  The instance is unused by default, but is ready to receive custom PAN-OS metrics from the firewalls. To use it, paste this Instrumentation Key into PAN-OS -> Device -> VM-Series -> Azure.
  EOF
  value       = azurerm_application_insights.this.instrumentation_key
  sensitive   = true
}

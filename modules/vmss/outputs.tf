output "scale_set_name" {
  description = "Name of the created scale set."
  value       = azurerm_linux_virtual_machine_scale_set.this.name
}

# output "autoscale_vars_tmp" {
#   value = local.autoscale_vars_tmp
# }

# output "autoscale_config" {
#   value = local.autoscale_config
# }

output "default_autoscale_profiles" {
  value = local.default_autoscale_profiles
}

# output "scheduled_autoscale_profiles" {
#   value = local.scheduled_autoscale_profiles
# }

# output "combined_autoscale_profiles" {
#   value = local.combined_autoscale_profiles
# }

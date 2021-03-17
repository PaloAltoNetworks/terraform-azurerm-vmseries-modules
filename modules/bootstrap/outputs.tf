output "storage_account" {
  description = "Bootstrap storage account resource object."
  value       = local.storage_account
}

output "storage_share_name" {
  description = "Name of storage share usable as VM-Series bootstrap configuration."
  value       = azurerm_storage_share.this.name
}

output "primary_access_key" {
  description = "Primary access key associated with the bootstrap storage account."
  value       = local.storage_account.primary_access_key
}

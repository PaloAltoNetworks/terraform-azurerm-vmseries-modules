output "storage_account" {
  description = "The Azure Storage Account object used for the Bootstrap."
  value       = local.storage_account
  sensitive   = true
}

output "storage_share" {
  description = "The File Share object within Azure Storage used for the Bootstrap."
  value       = azurerm_storage_share.this
  sensitive   = true
}

output "primary_access_key" {
  description = "The primary access key for the Azure Storage Account."
  value       = local.storage_account.primary_access_key
  sensitive   = true
}

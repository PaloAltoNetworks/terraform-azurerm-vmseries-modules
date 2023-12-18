output "storage_account_name" {
  description = "The Azure Storage Account name. For either created or sourced"
  value       = local.storage_account.name
}

output "storage_account_primary_access_key" {
  description = "The primary access key for the Azure Storage Account. For either created or sourced"
  value       = local.storage_account.primary_access_key
  sensitive   = true
}

output "file_share_urls" {
  description = "The File Shares' share URL used for bootstrap configuration."
  value       = { for k, v in azurerm_storage_share.this : k => v.url }
}

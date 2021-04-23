output "storage_account_name" {
  description = "Name of the Azure Storage Account object used for the Bootstrap."
  value       = module.bootstrap.storage_account.name
  sensitive   = true
}

output "storage_account_id" {
  description = "Identifier of the Azure Storage Account object used for the Bootstrap."
  value       = module.bootstrap.storage_account.id
  sensitive   = true
}

output "storage_share_name" {
  description = "Name of the File Share within Azure Storage."
  value       = module.bootstrap.storage_share.name
  sensitive   = true
}

output "storage_share_id" {
  description = "Identifier of the File Share within Azure Storage."
  value       = module.bootstrap.storage_share.id
  sensitive   = true
}

output "primary_access_key" {
  description = "The primary access key for the Azure Storage Account."
  value       = module.bootstrap.primary_access_key
  sensitive   = true
}

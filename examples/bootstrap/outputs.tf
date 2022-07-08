output "storage_account_name" {
  description = "Name of the Azure Storage Account object used for the Bootstrap."
  value       = module.inbound_bootstrap.storage_account.name
}

output "storage_account_id" {
  description = "Identifier of the Azure Storage Account object used for the Bootstrap."
  value       = module.inbound_bootstrap.storage_account.id
}

output "primary_access_key" {
  description = "The primary access key for the Azure Storage Account."
  value       = module.inbound_bootstrap.primary_access_key
  sensitive   = true
}

output "storage_share_names" {
  description = "Names of the File Shares within Azure Storage."
  value = {
    inbound = module.inbound_bootstrap.storage_share.name
    obew    = module.obew_bootstrap.storage_share.name
  }
}

output "storage_share_ids" {
  description = "Identifier of the File Share within Azure Storage."
  value = {
    inbound = module.inbound_bootstrap.storage_share.id
    obew    = module.obew_bootstrap.storage_share.id
  }
}

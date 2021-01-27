output "bootstrap-storage-account" {
  value       = local.storage_account
  description = "Bootstrap storage account resource"
}

output "inbound-bootstrap-share-name" {
  value       = azurerm_storage_share.inbound-bootstrap-storage-share.name
  description = "Name of storage share, used to store inbound firewall bootstrap configuration"
}

output "outbound-bootstrap-share-name" {
  value       = azurerm_storage_share.outbound-bootstrap-storage-share.name
  description = "Name of storage share, used to store outbound firewall bootstrap configuration"
}

output "storage-key" {
  value       = local.storage_account.primary_access_key
  description = "Primary access key associated with the bootstrap storage account"
}

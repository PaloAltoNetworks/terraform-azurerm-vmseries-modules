output "bootstrap-storage-account" {
  value       = azurerm_storage_account.bootstrap-storage-account
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
  value       = azurerm_storage_account.bootstrap-storage-account.primary_access_key
  description = "Primary access key associated with the bootstrap storage account"
}

output "storage-container-name" {
  value       = azurerm_storage_container.vm-sc.name
  description = "Name of storage container available to store VM series disks"
}


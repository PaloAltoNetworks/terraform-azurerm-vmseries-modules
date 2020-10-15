# sotrage_account
output "storage_account" { value = azurerm_storage_account.this }
output "storage_account_access_key" { value = azurerm_storage_account.this.primary_access_key }
output "storage_account_endpoint" { value = azurerm_storage_account.this.primary_blob_endpoint }

# storage_share
output "storage_share" { value = azurerm_storage_share.this }


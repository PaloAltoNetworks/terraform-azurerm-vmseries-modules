resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.storage_account_replication_type
}

resource "azurerm_storage_share" "this" {
  name                 = var.file_share_name
  storage_account_name = azurerm_storage_account.this.name
}

resource "azurerm_storage_share_directory" "root" {
  name                 = var.root_directory
  share_name           = azurerm_storage_share.this.name
  storage_account_name = azurerm_storage_account.this.name
}

resource "azurerm_storage_share_directory" "dirs" {
  for_each             = toset(var.config_dirs)
  name                 = "${var.root_directory}/${each.key}"
  share_name           = azurerm_storage_share.this.name
  storage_account_name = azurerm_storage_account.this.name
  depends_on           = [azurerm_storage_share_directory.root]
}

resource "null_resource" "this" {
  for_each = var.config_files
  provisioner "local-exec" {
    command = <<EOT
      az storage file upload \
      --source './${var.bootstrap_files_dir}/${each.key}' \
      --path '${var.root_directory}/${each.value.path}' \
      --share-name '${var.file_share_name}' \
      --account-name '${azurerm_storage_account.this.name}' \
      --account-key '${azurerm_storage_account.this.primary_access_key}';
    EOT
  }
  depends_on = [azurerm_storage_share_directory.dirs]
}

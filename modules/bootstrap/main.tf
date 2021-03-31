resource "azurerm_storage_account" "this" {
  count = var.create_storage_account ? 1 : 0

  name                     = var.storage_account_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

data "azurerm_storage_account" "this" {
  count = var.create_storage_account ? 0 : 1

  name                = var.existing_storage_account
  resource_group_name = var.resource_group_name
}

locals {
  storage_account = var.create_storage_account ? try(azurerm_storage_account.this[0], null) : data.azurerm_storage_account.this[0]
}

resource "azurerm_storage_share" "this" {
  name                 = var.storage_share_name
  storage_account_name = local.storage_account.name
  quota                = 50
}

resource "azurerm_storage_share_directory" "nonconfig" {
  for_each = toset([
    "content",
    "software",
  "license"])

  name                 = each.key
  share_name           = azurerm_storage_share.this.name
  storage_account_name = local.storage_account.name
}

resource "azurerm_storage_share_directory" "config" {
  name                 = "config"
  share_name           = azurerm_storage_share.this.name
  storage_account_name = local.storage_account.name
}

resource "azurerm_storage_share_file" "this" {
  for_each = var.files

  name             = regex("[^/]*$", each.value)
  path             = replace(each.value, "/[/]*[^/]*$/", "")
  storage_share_id = azurerm_storage_share.this.id
  source           = replace(each.key, "/CalculateMe[X]${random_id.this[each.key].id}/", "CalculateMeX${random_id.this[each.key].id}")
  # Live above is equivalent to:   `source = each.key`  but it re-creates the file every time the content changes.
  # The replace() is not actually doing anything, except tricking Terraform to destroy a resource.
  # There is a field content_md5 designed specifically for that. But I see a bug in the provider: 
  # When content_md5 is changed, the re-upload seemingly succeeds, result being however a totally empty file (size zero).
  # Workaround: use random_id above to cause the full destroy/create of a file.
  depends_on = [azurerm_storage_share_directory.config, azurerm_storage_share_directory.nonconfig]
}

resource "random_id" "this" {
  for_each = var.files

  keepers = {
    # Re-randomize on every content/md5 change. It forcibly recreates all users of this random_id.
    md5 = md5(file(each.key))
  }
  byte_length = 8
}

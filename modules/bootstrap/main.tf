resource "azurerm_storage_account" "this" {
  count = var.create_storage_account ? 1 : 0

  name                     = var.storage_account_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  min_tls_version          = var.min_tls_version
  account_replication_type = "LRS"
  account_tier             = "Standard"
  tags                     = var.tags
}

data "azurerm_storage_account" "this" {
  count = var.create_storage_account ? 0 : 1

  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

locals {
  storage_account = var.create_storage_account ? azurerm_storage_account.this[0] : data.azurerm_storage_account.this[0]
}

resource "azurerm_storage_share" "this" {
  name                 = var.storage_share_name
  storage_account_name = local.storage_account.name
  quota                = var.storage_share_quota
  access_tier          = var.storage_share_access_tier
}

resource "azurerm_storage_share_directory" "this" {
  for_each = toset([
    "content",
    "config",
    "software",
    "plugins",
    "license"
  ])

  name                 = each.key
  share_name           = azurerm_storage_share.this.name
  storage_account_name = local.storage_account.name
}

resource "azurerm_storage_share_file" "this" {
  for_each = var.files

  name             = regex("[^/]*$", each.value)
  path             = replace(each.value, "/[/]*[^/]*$/", "")
  storage_share_id = azurerm_storage_share.this.id
  source           = replace(each.key, "/CalculateMe[X]${random_id.this[each.key].id}/", "CalculateMeX${random_id.this[each.key].id}")
  # Line above is equivalent to:   `source = each.key`  but it re-creates the file every time the content changes.
  # The replace() is not actually doing anything, except tricking Terraform to destroy a resource.
  # There is a field content_md5 designed specifically for that. But I see a bug in the provider (last seen in 2.76):
  # When content_md5 changes the re-uploading seemingly succeeds, result being however a totally empty file (size zero).
  # Workaround: use random_id above to cause the full destroy/create of a file.
  depends_on = [azurerm_storage_share_directory.this]
}

resource "random_id" "this" {
  for_each = var.files

  keepers = {
    # Re-randomize on every content/md5 change. It forcibly recreates all users of this random_id.
    md5 = try(var.files_md5[each.key], filemd5(each.key))
  }
  byte_length = 8
}

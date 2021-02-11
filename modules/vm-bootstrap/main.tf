data "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "this" {
  count = var.create_storage_account ? 1 : 0

  name                     = substr(lower(coalesce(var.storage_account_name, replace("${var.name_prefix}bootstrap", "/[_-]+/", ""))), 0, 23)
  location                 = data.azurerm_resource_group.this.location
  resource_group_name      = data.azurerm_resource_group.this.name
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

locals {
  storage_account = var.create_storage_account ? azurerm_storage_account.this[0] : var.existing_storage_account
}

###############################################################################

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
  share_name           = azurerm_storage_share.this.name
  storage_account_name = local.storage_account.name
  name                 = "config"
}

resource "azurerm_storage_share_file" "this" {
  for_each = var.files

  name             = regex("[^/]*$", each.value)
  path             = replace(each.value, "/[/]*[^/]*$/", "")
  storage_share_id = azurerm_storage_share.this.id
  source           = replace(each.key, "/CalculateMe[X]${random_id.file[each.key].id}/", "CalculateMeX${random_id.file[each.key].id}")
  # Live above is equivalent to:   `source = each.key`  but it re-creates the file every time the content changes.
  # The replace() is not actually doing anything, except tricking Terraform to destroy a resource.
  # There is a field content_md5 designed specifically for that. But I see a bug in the provider: 
  # When content_md5 is changed, the re-upload seemingly succeeds, result being however a totally empty file (size zero).
  # Workaround: use random_id above to cause the full destroy/create of a file.
  depends_on = [
    azurerm_storage_share_directory.config,
    azurerm_storage_share_directory.nonconfig,
  ]
}

resource "random_id" "file" {
  for_each = var.files

  keepers = {
    # Re-randomize on every content/md5 change. It forcibly recreates all users of this random_id.
    md5 = md5(file(each.key))
  }
  byte_length = 8
}

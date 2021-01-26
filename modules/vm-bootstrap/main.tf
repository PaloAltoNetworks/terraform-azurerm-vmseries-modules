resource "azurerm_resource_group" "this" {
  count = var.create_storage_account ? 1 : 0

  name     = coalesce(var.resource_group_name, "${var.name_prefix}bootstrap")
  location = var.location
}

resource "azurerm_storage_account" "this" {
  count = var.create_storage_account ? 1 : 0

  name                     = coalesce(var.storage_account_name, replace("${var.name_prefix}bootstrap", "/[_-]+/", ""))
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.this[0].location
  resource_group_name      = azurerm_resource_group.this[0].name
}

locals {
  storage_account = var.create_storage_account ? azurerm_storage_account.this[0] : var.existing_storage_account
}

###############################################################################

resource "azurerm_storage_share" "inbound-bootstrap-storage-share" {
  name                 = var.name_inbound_bootstrap_storage_share
  storage_account_name = local.storage_account.name
  quota                = 50
}

resource "azurerm_storage_share_directory" "bootstrap-storage-directories" {
  for_each = toset([
    "content",
    "software",
  "license"])
  name                 = each.key
  share_name           = azurerm_storage_share.inbound-bootstrap-storage-share.name
  storage_account_name = local.storage_account.name
}

resource "azurerm_storage_share_directory" "inbound-bootstrap-config-directory" {
  share_name           = azurerm_storage_share.inbound-bootstrap-storage-share.name
  storage_account_name = local.storage_account.name
  name                 = "config"
}

resource "azurerm_storage_share_file" "this" {
  for_each = var.files

  name             = regex("[^/]*$", each.value)
  path             = replace(each.value, "/[/]*[^/]*$/", "")
  storage_share_id = azurerm_storage_share.inbound-bootstrap-storage-share.id
  source           = replace(each.key, "/CalculateMe[X]${random_id.file[each.key].id}/", "CalculateMeX${random_id.file[each.key].id}")
  # Live above is equivalent to:   `source = each.key`  but it re-creates the file every time the content changes.
  # The replace() is not actually doing anything, except tricking Terraform to destroy a resource.
  # There is a field content_md5 designed specifically for that. But I see a bug in the provider: 
  # When content_md5 is changed, the re-upload seemingly succeeds, result being however a totally empty file (size zero).
  # Workaround: use random_id above to cause the full destroy/create of a file.
  depends_on = [
    azurerm_storage_share_directory.inbound-bootstrap-config-directory,
    azurerm_storage_share_directory.bootstrap-storage-directories,
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

resource "azurerm_storage_share" "outbound-bootstrap-storage-share" {
  name                 = var.name_outbound-bootstrap-storage-share
  storage_account_name = local.storage_account.name
  quota                = 50
}

resource "azurerm_storage_share_directory" "outbound-bootstrap-storage-directories" {
  for_each = toset([
    "content",
    "software",
  "license"])
  name                 = each.key
  share_name           = azurerm_storage_share.outbound-bootstrap-storage-share.name
  storage_account_name = local.storage_account.name
}

resource "azurerm_storage_share_directory" "outbound-bootstrap-config-directory" {
  share_name           = azurerm_storage_share.outbound-bootstrap-storage-share.name
  storage_account_name = local.storage_account.name
  name                 = "config"
}


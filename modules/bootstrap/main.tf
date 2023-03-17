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
  source           = each.key
  content_md5      = try(var.files_md5[each.key], filemd5(each.key))

  depends_on = [azurerm_storage_share_directory.this]
}

resource "azurerm_resource_group" "bootstrap" {
  name     = "${var.name_prefix}${var.sep}${var.name_rg}"
  location = var.location
}

# The storage account is used for the VM Series bootstrap
# Ref: https://docs.paloaltonetworks.com/vm-series/8-1/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-the-vm-series-firewall-in-azure.html#idd51f75b8-e579-44d6-a809-2fafcfe4b3b6
resource "azurerm_storage_account" "bootstrap-storage-account" {
  name                     = "${var.name_prefix}${var.name_bootstrap_share}"
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.bootstrap.location
  resource_group_name      = azurerm_resource_group.bootstrap.name
}

resource "azurerm_storage_share" "inbound-bootstrap-storage-share" {
  name                 = var.name_inbound_bootstrap_storage_share
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
  quota                = 50
}

resource "azurerm_storage_share_directory" "bootstrap-storage-directories" {
  for_each = toset([
    "content",
    "software",
  "license"])
  name                 = each.key
  share_name           = azurerm_storage_share.inbound-bootstrap-storage-share.name
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
}

resource "azurerm_storage_share_directory" "inbound-bootstrap-config-directory" {
  share_name           = azurerm_storage_share.inbound-bootstrap-storage-share.name
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
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
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
  quota                = 50
}

resource "azurerm_storage_share_directory" "outbound-bootstrap-storage-directories" {
  for_each = toset([
    "content",
    "software",
  "license"])
  name                 = each.key
  share_name           = azurerm_storage_share.outbound-bootstrap-storage-share.name
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
}

resource "azurerm_storage_share_directory" "outbound-bootstrap-config-directory" {
  share_name           = azurerm_storage_share.outbound-bootstrap-storage-share.name
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
  name                 = "config"
}


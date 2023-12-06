# Create or source the Resource Group.
resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = "${var.name_prefix}${var.resource_group_name}"
  location = var.location

  tags = var.tags
}

data "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

locals {
  resource_group = var.create_resource_group ? azurerm_resource_group.this[0] : data.azurerm_resource_group.this[0]
}

# module "bootstrap" {
#   source = "../../modules/bootstrap"

#   for_each = var.bootstrap_storages

#   create_storage_account = var.bootstrap_storages["bootstrap-storage"].create_storage_account
#   name                   = var.bootstrap_storages["bootstrap-storage"].name
#   resource_group_name    = coalesce(var.bootstrap_storages["bootstrap-storage"].resource_group_name, local.resource_group.name)
#   location               = var.location

#   storage_network_security  = var.bootstrap_storages["bootstrap-storage"].storage_network_security
#   file_shares_configuration = var.bootstrap_storages["bootstrap-storage"].file_shares_configuration
#   file_shares               = var.bootstrap_storages["bootstrap-storage"].file_shares

#   tags = var.tags
# }

module "bootstrap" {
  source = "../../modules/bootstrap"

  for_each = var.bootstrap_storages

  create_storage_account = each.value.create_storage_account
  name                   = each.value.name
  resource_group_name    = coalesce(each.value.resource_group_name, local.resource_group.name)
  location               = var.location

  storage_network_security  = each.value.storage_network_security
  file_shares_configuration = each.value.file_shares_configuration
  file_shares               = each.value.file_shares

  tags = var.tags
}

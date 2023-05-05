resource "azurerm_storage_account" "this" {
  count = var.create_storage_account ? 1 : 0

  name                     = var.name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  min_tls_version          = var.min_tls_version
  account_replication_type = "LRS"
  account_tier             = "Standard"
  tags                     = var.tags
  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = var.retention_policy_days
    }
  }
  network_rules {
    default_action             = var.storage_acl == true ? "Deny" : "Allow"
    ip_rules                   = var.storage_acl == true ? var.storage_allow_inbound_public_ips : null
    virtual_network_subnet_ids = var.storage_acl == true ? var.storage_allow_vnet_subnet_ids : null
  }
}

data "azurerm_storage_account" "this" {
  count = var.create_storage_account ? 0 : 1

  name                = var.name
  resource_group_name = var.resource_group_name
}

locals {
  storage_account = var.create_storage_account ? azurerm_storage_account.this[0] : data.azurerm_storage_account.this[0]
}

resource "azurerm_storage_share" "this" {
  count = var.storage_share_name != null ? 1 : 0

  name                 = var.storage_share_name
  storage_account_name = local.storage_account.name
  quota                = var.storage_share_quota
  access_tier          = var.storage_share_access_tier

  lifecycle {
    precondition {
      condition = var.storage_share_name != null ? alltrue([
        can(regex("^[a-z0-9](-?[a-z0-9])+$", var.storage_share_name)),
        can(regex("^([a-z0-9-]){3,63}$", var.storage_share_name))
      ]) : true
      error_message = "A File Share name must be between 3 and 63 characters, all lowercase numbers, letters or a dash, it must follow a valid URL schema."
    }
  }
}

resource "azurerm_storage_share_directory" "this" {
  for_each = var.storage_share_name != null ? toset([
    "content",
    "config",
    "software",
    "plugins",
    "license"
  ]) : toset([])

  name                 = each.key
  share_name           = azurerm_storage_share.this[0].name
  storage_account_name = local.storage_account.name
}

resource "azurerm_storage_share_file" "this" {
  for_each = var.storage_share_name != null ? var.files : {}

  name             = regex("[^/]*$", each.value)
  path             = replace(each.value, "/[/]*[^/]*$/", "")
  storage_share_id = azurerm_storage_share.this[0].id
  source           = each.key
  content_md5      = try(var.files_md5[each.key], filemd5(each.key))

  depends_on = [azurerm_storage_share_directory.this]
}

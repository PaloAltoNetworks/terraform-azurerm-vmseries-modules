# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "this" {
  count = var.create_storage_account ? 1 : 0

  name                     = var.name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  min_tls_version          = var.storage_network_security.min_tls_version
  account_replication_type = "LRS"
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  tags                     = var.tags

  dynamic "network_rules" {
    for_each = length(var.storage_network_security.allowed_public_ips) > 0 || length(var.storage_network_security.allowed_subnet_ids) > 0 ? [1] : []
    content {
      default_action             = "Deny"
      ip_rules                   = var.storage_network_security.allowed_public_ips
      virtual_network_subnet_ids = var.storage_network_security.allowed_subnet_ids
    }
  }

  lifecycle {
    precondition {
      condition     = var.location != null
      error_message = "When creating a storage account the `location` variable cannot be null."
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account
data "azurerm_storage_account" "this" {
  count = var.create_storage_account ? 0 : 1

  name                = var.name
  resource_group_name = var.resource_group_name
}

locals {
  storage_account = var.create_storage_account ? azurerm_storage_account.this[0] : data.azurerm_storage_account.this[0]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share
resource "azurerm_storage_share" "this" {
  for_each = var.file_shares_configuration.create_file_shares ? var.file_shares : {}

  name                 = each.value.name
  storage_account_name = local.storage_account.name
  quota                = coalesce(each.value.quota, var.file_shares_configuration.quota)
  access_tier          = coalesce(each.value.access_tier, var.file_shares_configuration.access_tier)
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_share
data "azurerm_storage_share" "this" {
  for_each = var.file_shares_configuration.create_file_shares ? {} : var.file_shares

  name                 = each.value.name
  storage_account_name = local.storage_account.name

  lifecycle {
    precondition {
      condition     = !var.file_shares_configuration.create_file_shares && !var.create_storage_account
      error_message = "You cannot source File Shares from a newly created Storage Account."
    }
  }
}

locals {
  file_shares     = var.file_shares_configuration.create_file_shares ? azurerm_storage_share.this : data.azurerm_storage_share.this
  package_folders = ["content", "config", "software", "plugins", "license"]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share_directory
resource "azurerm_storage_share_directory" "this" {
  for_each = {
    for v in setproduct(keys(var.file_shares), local.package_folders) :
    join("-", v) => {
      share_key   = v[0]
      folder_name = v[1]
    }
    if !var.file_shares_configuration.disable_package_dirs_creation
  }

  name                 = each.value.folder_name
  share_name           = local.file_shares[each.value.share_key].name
  storage_account_name = local.storage_account.name
}


locals {
  bootstrap_filenames = {
    for k, v in var.file_shares : k => {
      for f in try(fileset(v.bootstrap_package_path, "**"), {}) : f => "${v.bootstrap_package_path}/${f}"
    }
  }

  # invert var.files map 
  inverted_files = {
    for k, v in var.file_shares : k => {
      for k, v in v.bootstrap_files : v => k
    }
  }

  inverted_filenames = {
    for k, _ in var.file_shares : k => merge(local.bootstrap_filenames[k], local.inverted_files[k])
  }

  # invert local.filenames map
  filenames = {
    for k, _ in var.file_shares : k => { for _k, _v in local.inverted_filenames[k] : _v => _k }
  }
  filenames_across_fileshares_flat = flatten([
    for file_share, share_files in local.filenames : [
      for source_path, dest_path in share_files : {
        file_share      = file_share
        source_path     = source_path
        remote_path     = regex("^(.*)/", dest_path)[0]
        remote_filename = regex("[^/]+$", dest_path)
      }
    ]
  ])

  filenames_across_fileshares = {
    for v in local.filenames_across_fileshares_flat :
    replace("${v.file_share}-${v.source_path}", "/[./]+/", "-") => v
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share_file
resource "azurerm_storage_share_file" "this" {
  for_each = local.filenames_across_fileshares

  # When creating files inside of a File Share we need to specify the path and filename separately
  # regardless that the provider's documentation states that `name` can be also a path.
  # When this resource is used that way it errors out with the following message:
  #   `... unexpected new value: Root object was present, but now absent.`
  # The file is being created but state is not updated.
  name             = each.value.remote_filename
  path             = each.value.remote_path
  storage_share_id = local.file_shares[each.value.file_share].id
  source           = each.value.source_path
  content_md5 = try(
    var.file_shares[each.value.file_share].bootstrap_files_md5[each.value.source_path],
    filemd5(each.value.source_path)
  )

  depends_on = [azurerm_storage_share_directory.this]
}

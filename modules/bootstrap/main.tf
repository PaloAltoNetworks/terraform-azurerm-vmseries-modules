# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "this" {
  count = var.storage_account.create ? 1 : 0

  name                     = var.name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  min_tls_version          = var.storage_network_security.min_tls_version
  account_replication_type = var.storage_account.replication_type
  account_tier             = var.storage_account.tier
  account_kind             = var.storage_account.kind
  tags                     = var.tags

  lifecycle {
    precondition {
      condition     = var.location != null
      error_message = "When creating a storage account the `location` variable cannot be null."
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules
resource "azurerm_storage_account_network_rules" "this" {
  count = var.storage_account.create ? 1 : 0

  storage_account_id         = azurerm_storage_account.this[0].id
  default_action             = length(var.storage_network_security.allowed_public_ips) > 0 || length(var.storage_network_security.allowed_subnet_ids) > 0 ? "Deny" : "Allow"
  ip_rules                   = var.storage_network_security.allowed_public_ips
  virtual_network_subnet_ids = var.storage_network_security.allowed_subnet_ids
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account
data "azurerm_storage_account" "this" {
  count = var.storage_account.create ? 0 : 1

  name                = var.name
  resource_group_name = var.resource_group_name
}

locals {
  storage_account = var.storage_account.create ? azurerm_storage_account.this[0] : data.azurerm_storage_account.this[0]
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
      condition     = !var.file_shares_configuration.create_file_shares && !var.storage_account.create
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
  # This locals section is responsible for handling the bootstrap files.
  # The files that will be uploaded to File Shares can come from 2 places:
  #  - bootstrap_package_path - a local bootstrap package (a folder structure + bootstrap files, static)
  #  - bootstrap_files - a map defining a source file and a destination where this file should be places in the bootstrap package
  #    on the File Share (static, but can be dynamic)
  #
  # Since these are two different locations, we need to merge them. The `bootstrap_files` property has a higher precedence as
  # as it can contain files created dynamically during Terraform run. Hence, in a situation where a file is present in both
  # locations, the one from `bootstrap_files` will be used.
  # 
  # This operation is done by comparing destination paths from both sources. But before we do that we need to perform some
  # operations - the information about the bootstrap files is stored in different formats for both locations.

  # 1. Load information about the files present in the local bootstrap package - `bootstrap_package_path`.
  #    We will receive a map where keys will be paths pointing to where the file should be placed on the File Share and values
  #    will be paths to local files.
  #    Assuming that the bootstrap package is stored under `bootstrap` folder we will get a map like this:
  # 
  #    ```
  #    bootstrap_filenames = {
  #      "config/bootstrap.xml" = "bootstrap/config/bootstrap.xml"
  #      ...
  #    }
  #    ```
  bootstrap_filenames = {
    for k, v in var.file_shares : k => {
      for f in try(fileset(v.bootstrap_package_path, "**"), {}) : f => "${v.bootstrap_package_path}/${f}"
    }
  }

  # 2. Invert the `bootstrap_files`. This map has keys pointing to local files and values specifying the destination. To be able
  #    to compare destinations we need to swap keys with values.
  inverted_files = {
    for k, v in var.file_shares : k => {
      for k, v in v.bootstrap_files : v => k
    }
  }

  # 3. Compare both packages using destinations. There is no real comparison being made. We simply merge both maps, the latter one
  #    takes precedence (we simply use the mechanism of the `merge` function).
  inverted_filenames = {
    for k, _ in var.file_shares : k => merge(local.bootstrap_filenames[k], local.inverted_files[k])
  }

  # 4. Go back to the old format. We want to have the local path as key and the remote destination as value - this is a natural
  #    way of interacting with the `azurerm_storage_share_file` resource. Therefore we swap keys with values again.
  filenames = {
    for k, _ in var.file_shares : k => { for _k, _v in local.inverted_filenames[k] : _v => _k }
  }
  # 5. Build a flat map with unique keys describing all files across all File Shares.
  #    NOTE. Up to this point all maps we were iterating over had two levels:
  #     1. keys were File Share names
  #     2. keys were file names (either source or destination)
  #    The `azurerm_storage_share_file` resource that will be used to upload all files for all file shares runs over a flat map.
  #    Therefore we need to flatten the `local.filenames` map and introduce unique keys. Since there is no mechanism built into
  #    Terraform that would allow map flattening we do it in two steps:
  # 
  #  a. turn the map into a flat list
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
  #  b. turn the flat list into a map. Note, that the key is a combination of the File Share name and the file's source path.
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

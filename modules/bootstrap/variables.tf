variable "create_storage_account" {
  description = "If `true`, create a Storage Account."
  default     = true
  type        = bool
}

variable "storage_account_name" {
  description = <<-EOF
  Name of the Storage Account, either a new or an existing one (depending on the value of `create_storage_account`).

  The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters.
  EOF
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "A Storage Account name must be between 3 and 24 characters, only lower case letters and numbers are allowed."
  }
}

variable "resource_group_name" {
  description = "Name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "Region to deploy bootstrap resources. Ignored when `create_storage_account` is set to `false`."
  default     = null
  type        = string
}

variable "min_tls_version" {
  description = "The minimum supported TLS version for the storage account."
  default     = "TLS1_2"
  type        = string
}

variable "files" {
  description = <<-EOF
  Map of all files to copy to bucket. The keys are local paths, the values are remote paths.
  Always use slash `/` as directory separator (unix-like), not the backslash `\`.
  Example: 
  ```
  files = {
    "dir/my.txt" = "config/init-cfg.txt"
  }
  ```
  EOF
  default     = {}
  type        = map(string)
}

variable "files_md5" {
  description = <<-EOF
  Optional map of MD5 hashes of file contents.
  Normally the map could be all empty, because all the files that exist before the `terraform apply` will have their hashes auto-calculated.
  This input is necessary only for the selected files which are created/modified within the same Terraform run as this module.
  The keys of the map should be identical with selected keys of the `files` input, while the values should be MD5 hashes of the contents of that file.

  Example:
  ```
  files_md5 = {
      "dir/my.txt" = "6f7ce3191b50a58cc13e751a8f7ae3fd"
  }
  ```
  EOF
  default     = {}
  type        = map(string)
}

variable "storage_share_name" {
  description = <<-EOF
  Name of a storage File Share to be created that will hold `files` used for bootstrapping.
  For rules defining a valid name see [Microsoft documentation](https://docs.microsoft.com/en-us/rest/api/storageservices/Naming-and-Referencing-Shares--Directories--Files--and-Metadata#share-names).
  EOF
  type        = string
  validation {
    condition = alltrue([
      can(regex("^[a-z0-9](-?[a-z0-9])+$", var.storage_share_name)),
      can(regex("^([a-z0-9-]){3,63}$", var.storage_share_name))
    ])
    error_message = "A File Share name must be between 3 and 63 characters, all lowercase numbers, letters or a dash, it must follow a valid URL schema."
  }
}

variable "storage_share_quota" {
  description = "Maximum size of a File Share."
  default     = 50
  type        = number
}

variable "storage_share_access_tier" {
  description = "Access tier for the File Share."
  default     = "Cool"
  type        = string
}

variable "tags" {
  description = "A map of tags to be associated with the resources created."
  default     = {}
  type        = map(string)
}

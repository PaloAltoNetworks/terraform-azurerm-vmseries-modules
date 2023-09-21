variable "create_storage_account" {
  description = "If `true`, create a Storage Account."
  default     = true
  type        = bool
}

variable "name" {
  description = <<-EOF
  Name of the Storage Account, either a new or an existing one (depending on the value of `create_storage_account`).

  The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters.
  EOF
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
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

variable "bootstrap_files_dir" {
  description = "Bootstrap file directory. If the variable has a value of `null` (default) - then it will not upload any other files other than the ones specified in the `files` variable. More information can be found at https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-package."
  default     = null
  type        = string
}


variable "files_md5" {
  description = <<-EOF
  Optional map of MD5 hashes of file contents.
  Normally the map could be empty, because all the files that exist before the `terraform apply` will have their hashes auto-calculated.
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
  default     = null
  type        = string
  nullable    = true
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

variable "retention_policy_days" {
  description = "Log retention policy in days"
  type        = number
  default     = 7
  validation {
    condition     = var.retention_policy_days > 0 && var.retention_policy_days < 365
    error_message = "Enter a value between 1 and 365."
  }
}

variable "blob_delete_retention_policy_days" {
  description = "Specifies the number of days that the blob should be retained"
  type        = number
  default     = 7
  validation {
    condition     = var.blob_delete_retention_policy_days > 0 && var.blob_delete_retention_policy_days < 365
    error_message = "Enter a value between 1 and 365."
  }
}

variable "storage_allow_inbound_public_ips" {
  description = <<-EOF
    List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access the Storage Account.
    Only public IPs are allowed - RFC1918 address space is not permitted.
  EOF
  type        = list(string)
  default     = []
}

variable "storage_allow_vnet_subnet_ids" {
  description = <<-EOF
  List of the allowed VNet subnet ids.
  Note that this option requires network service endpoint enabled for Microsoft Storage for the specified subnets.
  If you are using [vnet module](../vnet/README.md) - set `storage_private_access` to true for the specific subnet.
  Example:
  ```
  [
    module.vnet.subnet_ids["subnet-mgmt"],
    module.vnet.subnet_ids["subnet-pub"],
    module.vnet.subnet_ids["subnet-priv"]
  ]
  ```
  EOF
  type        = list(string)
  default     = []
}

variable "storage_acl" {
  description = "If `true`, storage account network rules will be activated with `Deny` as the default action. In such case, at least one of `storage_allow_inbound_public_ips` or `storage_allow_vnet_subnet_ids` must be a non-empty list."
  default     = true
  type        = bool
}
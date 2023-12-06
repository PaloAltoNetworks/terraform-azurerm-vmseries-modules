variable "name" {
  description = <<-EOF
  Name of the Storage Account.
  Either a new or an existing one (depending on the value of `create_storage_account`).

  The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters.
  EOF
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "A Storage Account name must be between 3 and 24 characters, only lower case letters and numbers are allowed."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "The name of the Azure region to deploy the resources in."
  default     = null
  type        = string
}

variable "tags" {
  description = "The map of tags to assign to all created resources."
  default     = {}
  type        = map(string)
}

variable "create_storage_account" {
  description = <<-EOF
  Controls creation of a Storage Account.
  
  When set to `false` an existing Storage Account will be used to create bootstrap file shares.
  EOF
  default     = true
  nullable    = false
  type        = bool
}

variable "storage_network_security" {
  description = <<-EOF
  A map defining network security settings for a new storage account.

  When not set or set to `null` it will disable any network security setting.

  When you decide define this setting, at least one of `allowed_public_ips` or `allowed_subnet_ids` has to be defined.
  Otherwise you will cut anyone off the storage account. This will have implications on this Terraform code as it operates on
  File Shares. Files Shares API comes under this networks restrictions.

  Following properties are available:

  - `min_tls_version`     - (`string`, optional, defaults to `TLS1_2`) minimum supported TLS version
  - `allowed_public_ips`  - (`list`, optional, defaults to `[]`) list of IP CIDR ranges that are allowed to access the Storage
                            Account. Only public IPs are allowed, RFC1918 address space is not permitted.
  - `allowed_subnet_ids`  - (`list`, optional, defaults to `[]`) list of the allowed VNet subnet ids. Note that this option
                            requires network service endpoint enabled for Microsoft Storage for the specified subnets.
                            If you are using [vnet module](../vnet/README.md), set `storage_private_access` to true for the
                            specific subnet.

  EOF
  default     = {}
  nullable    = false
  type = object({
    min_tls_version    = optional(string, "TLS1_2")
    allowed_public_ips = optional(list(string), [])
    allowed_subnet_ids = optional(list(string), [])
  })
  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.storage_network_security.min_tls_version)
    error_message = "The `min_tls_version` property can be one of: \"TLS1_0\", \"TLS1_1\", \"TLS1_2\"."
  }
}

variable "file_shares_configuration" {
  description = <<-EOF
  A map defining common File Share setting.

  Any of this can be overridden in a particular File Share definition. See [`file_shares`](#file_shares) variable for details.

  Following options are available:
  
  - `quota`       - (`number`, optional, defaults to `10`) maximum size of a File Share in GB, a value between 1 and
                    5120 (5TB)
  - `access_tier` - (`string`, optional, defaults to `Cool`) access tier for a File Share, can be one of: "Cool", "Hot",
                    "Premium", "TransactionOptimized". 
  EOF
  default     = {}
  nullable    = false
  type = object({
    quota       = optional(number, 10)
    access_tier = optional(string, "Cool")
  })
  validation {
    condition     = var.file_shares_configuration.quota >= 1 && var.file_shares_configuration.quota <= 5120
    error_message = "The `quota` property can take values between 1 and 5120."
  }
  validation {
    condition     = contains(["Cool", "Hot", "Premium", "TransactionOptimized"], var.file_shares_configuration.access_tier)
    error_message = "The `access_tier` property can take one of the following values: \"Cool\", \"Hot\", \"Premium\", \"TransactionOptimized\"."
  }
}

variable "file_shares" {
  description = <<-EOF
  Definition of File Shares.

  This is a map of objects where each object is a File Share definition. There are situations where every firewall can use the
  same bootstrap package. But you there are situation where each firewall (or a group of firewalls) need a separate one.

  This configuration parameter can help you to create multiple File Shares, per your needs, w/o multiplying Storage Accounts
  at the same time.

  Following properties are available per each File Share definition:

  - `name`                    - (`string`, required) name of the File Share
  - `bootstrap_package_path`  - (`string`, optional, defaults to `null`) a path to a folder containing a full bootstrap package.
                                For details on the bootstrap package structure see [documentation](https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-package)
  - `bootstrap_files`         - (`map`, optional, defaults to `{}`) a map of files that will be copied to the File Share and build
                                the bootstrap package. 
                                
      Keys are local paths, values - remote. Only Unix like directory separator (`/`) is supported. If `bootstrap_package_path`
      is also specified, these files will overwrite any file uploaded from that path.

  - `bootstrap_files_md5`     - (`map`, optional, defaults to `{}`) a map of MD5 hashes for files specified in `bootstrap_files`.

      For static files (present and/or not modified before Terraform plan kicks in) this map can be empty. The MD5 hashes are
      calculated automatically. It's only required for files modified/created by Terraform. You can use `md5` or `filemd5`
      Terraform functions to calculate MD5 hashes dynamically.

      Keys in this map are local paths, variables - MD5 hashes. For files for which you would like to provide MD5 hashes, 
      keys in this map should match keys in `bootstrap_files` property.


  Additionally you can override the default `quota` and `access_tier` properties per File Share (same restrictions apply):

  - `quota`       - (`number`, optional, defaults to `10`) maximum size of a File Share in GB, a value between 1 and
                    5120 (5TB)
  - `access_tier` - (`string`, optional, defaults to `Cool`) access tier for a File Share, can be one of: "Cool", "Hot",
                    "Premium", "TransactionOptimized". 

  EOF
  default     = {}
  nullable    = false
  type = map(object({
    name                   = string
    bootstrap_package_path = optional(string)
    bootstrap_files        = optional(map(string), {})
    bootstrap_files_md5    = optional(map(string), {})
    quota                  = optional(number)
    access_tier            = optional(string)
  }))
  validation {
    condition = alltrue([
      for _, v in var.file_shares :
      alltrue([
        can(regex("^[a-z0-9](-?[a-z0-9])+$", v.name)),
        can(regex("^([a-z0-9-]){3,63}$", v.name))
      ])
    ])
    error_message = "A File Share name must be between 3 and 63 characters, all lowercase numbers, letters or a dash, it must follow a valid URL schema."
  }
  validation {
    condition     = alltrue([for _, v in var.file_shares : v.quota >= 1 && v.quota <= 5120 if v.quota != null])
    error_message = "The `quota` property can take values between 1 and 5120."
  }
  validation {
    condition = alltrue([
      for _, v in var.file_shares :
      contains(["Cool", "Hot", "Premium", "TransactionOptimized"], v.access_tier)
      if v.access_tier != null
    ])
    error_message = "The `access_tier` property can take one of the following values: \"Cool\", \"Hot\", \"Premium\", \"TransactionOptimized\"."
  }
}

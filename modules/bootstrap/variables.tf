variable "resource_group_name" {
  description = "Name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "Region to deploy vm-series bootstrap resources. Ignored when using an `existing_storage_account`."
  default     = null
  type        = string
}

variable "create_storage_account" {
  description = "If true, create a Storage Account and ignore `existing_storage_account`."
  default     = true
  type        = bool
}

variable "storage_account_name" {
  description = <<-EOF
  Default name of the storage account, if creating it. Ignored when `existing_storage_account` object is non-null.
  The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters.
  EOF
  default     = "pantfstorage"
  type        = string
}

variable "existing_storage_account" {
  description = "Name of the existing Storage Account object to use. Ignored when `create_storage_account` is true."
  default     = null
  type        = string
}

variable "files" {
  description = "Map of all files to copy to bucket. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\\`. For example `{\"dir/my.txt\" = \"config/init-cfg.txt\"}`"
  default     = {}
  type        = map(string)
}


variable "storage_share_name" {
  description = "Name of storage share to be created that holds `files` for bootstrapping."
  default     = "bootstrapshare"
  type        = string
}

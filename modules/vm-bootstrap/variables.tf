variable "location" {
  description = "Region to deploy vm-series bootstrap resources. Ignored when using an `existing_storage_account`."
  default     = null
  type        = string
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here."
  type        = string
}

variable "create_storage_account" {
  description = "If true, create a Storage Account and a Resource Group and ignore `existing_storage_account`."
  default     = true
  type        = bool
}

variable "existing_storage_account" {
  description = "The existing Storage Account object to use. Ignored when `create_storage_account` is true."
  default     = null
}

variable files {
  description = "Map of all files to copy to bucket. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\\`. For example `{\"dir/my.txt\" = \"config/init-cfg.txt\"}`"
  default     = {}
  type        = map(string)
}

variable "resource_group_name" {
  description = "Name of the resource group, if creating it. Ignored when `existing_storage_account` object is non-null."
  default     = null
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account, if creating it. Ignored when `existing_storage_account` object is non-null."
  default     = null
  type        = string
}

variable "name_inbound_bootstrap_storage_share" {
  default = "ibbootstrapshare"
}

variable "name_outbound-bootstrap-storage-share" {
  default = "obbootstrapshare"
}

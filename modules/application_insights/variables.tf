variable "name" {
  description = "Name of the Application Insights instance."
  type        = string
}

variable "workspace_mode" {
  description = <<-EOF
  Application Insights mode. If `true` (default), the 'Workspace-based' mode is used. With `false`, the mode is set to legacy 'Classic'.

  NOTICE. Azure support for classic Application Insights mode will end on Feb 29th 2024. It's already not available in some of the new regions.
  EOF
  default     = true
  type        = bool
  nullable    = false
}

variable "workspace_name" {
  description = "The name of the Log Analytics workspace. Can be `null`, in which case a default name is auto-generated."
  default     = null
  type        = string
}

variable "workspace_sku" {
  description = "Azure Log Analytics Workspace mode SKU. For more information refer to [Microsoft's documentation](https://learn.microsoft.com/en-us/azure/azure-monitor//usage-estimated-costs#moving-to-the-new-pricing-model)."
  default     = "PerGB2018"
  type        = string
}

variable "metrics_retention_in_days" {
  description = "Specifies the retention period in days. Possible values are 0, 30, 60, 90, 120, 180, 270, 365, 550 or 730. Azure defaults is 90."
  default     = null
  type        = number
}

variable "location" {
  description = "A name of a region in which the resources will be creatied."
  type        = string
}

variable "resource_group_name" {
  description = "A name of an existing Resource Group."
  type        = string
}

variable "tags" {
  description = "A map of tags assigned to all resources created by this module."
  default     = {}
  type        = map(string)
}

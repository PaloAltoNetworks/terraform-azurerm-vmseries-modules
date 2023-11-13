variable "name" {
  description = "The name of the Azure Log Analytics Workspace."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "The name of the Azure region to deploy the resources in."
  type        = string
}

variable "tags" {
  description = "The map of tags to assign to all created resources."
  default     = {}
  type        = map(string)
}

variable "create_workspace" {
  default = true
  type    = bool
}

variable "log_analytics_config" {
  description = <<-EOF
  EOF
  default     = {}
  nullable    = false
  type = object({
    sku                       = optional(string)
    metrics_retention_in_days = optional(number)
  })
}

variable "application_insights" {
  type = map(object({
    name                      = string
    resource_group_name       = optional(string)
    metrics_retention_in_days = optional(number)
  }))
}

# variable "workspace_name" {
#   description = "The name of the Log Analytics workspace. Can be `null`, in which case a default name is auto-generated."
#   type        = string
# }

# variable "workspace_sku" {
#   description = "Azure Log Analytics Workspace mode SKU. For more information refer to [Microsoft's documentation](https://learn.microsoft.com/en-us/azure/azure-monitor//usage-estimated-costs#moving-to-the-new-pricing-model)."
#   default     = null
#   # default     = "PerGB2018"
#   type = string
# }

# variable "workspace_metrics_retention_in_days" {
#   description = "Specifies the retention period in days. Possible values are 0, 30, 60, 90, 120, 180, 270, 365, 550 or 730. Azure defaults is 90."
#   default     = null
#   type        = number
# }

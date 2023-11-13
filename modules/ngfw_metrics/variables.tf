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
  description = "Controls creation or sourcing of a Log Analytics Workspace."
  default     = true
  nullable    = false
  type        = bool
}

variable "log_analytics_config" {
  description = <<-EOF
  Configuration of the log analytics workspace.

  Following properties are available:

  - `sku`                       - (`string`, optional, defaults to Azure defaults) the SKU of the Log Analytics Workspace.

    As of API version `2018-04-03` the Azure default value is `PerGB2018`, other possible values are:
    `Free`, `PerNode`, `Premium`, `Standard`, `Standalone`, `Unlimited`, `CapacityReservation`.

  - `metrics_retention_in_days` - (`number`, optional, defaults to Azure defaults) workspace data retention in days, 
                                  possible values are between 30 and 730.
  EOF
  default     = {}
  nullable    = false
  type = object({
    sku                       = optional(string)
    metrics_retention_in_days = optional(number)
  })
  validation {
    condition = var.log_analytics_config.sku != null ? contains([
      "Free",
      "PerNode",
      "Premium",
      "Standard",
      "Standalone",
      "Unlimited",
      "CapacityReservation",
      "PerGB2018"],
      var.log_analytics_config.sku
    ) : true
    error_message = "The `var.log_analytics_config.sku` property has to have a value of either: `Free`, `PerNode`, `Premium`, `Standard`, `Standalone`, `Unlimited`, `CapacityReservation` or `PerGB2018`."
  }
  validation {
    condition     = var.log_analytics_config.metrics_retention_in_days != null && var.log_analytics_config.metrics_retention_in_days >= 30 && var.log_analytics_config.metrics_retention_in_days <= 730
    error_message = "The `var.log_analytics_config.metrics_retention_in_days` property can take values between 30 and 730 (both inclusive)."
  }
}

variable "application_insights" {
  description = <<-EOF
  A map defining Application Insights instances.

  Following properties are available:

  - `name`                      - (`string`, required) the name of the Application Insights instance
  - `resource_group_name`       - (`string`, optional, defaults to `var.resource_group_name`) name of a Resource Group that will
                                  host the Application Insights instance.

    This property can be handy in case one would like to use an existing Log Analytics Workspace, but for whatever reason the
    Application Insights instances should be created in a separate Resource Group (due to limited access for example).

  - `metrics_retention_in_days` - (`number`, optional, defaults to `var.log_analytics_config.metrics_retention_in_days`)
                                  Application Insights data retention in days, possible values are between 30 and 730.
  EOF
  type = map(object({
    name                      = string
    resource_group_name       = optional(string)
    metrics_retention_in_days = optional(number)
  }))
  validation {
    condition = alltrue([
      for _, v in var.application_insights :
      v.metrics_retention_in_days >= 30 && v.metrics_retention_in_days <= 730
      if v.metrics_retention_in_days != null
    ])
    error_message = "The `metrics_retention_in_days` property can take values between 30 and 730 (both inclusive)."
  }
}

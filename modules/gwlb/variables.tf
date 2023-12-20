variable "name" {
  description = "The name of the Azure Load Balancer."
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

variable "zones" {
  description = <<-EOF
  Controls zones for Gateway Load Balancer's Fronted IP configurations.

  Setting this variable to explicit `null` disables a zonal deployment.
  This can be helpful in regions where Availability Zones are not available.
  EOF
  default     = ["1", "2", "3"]
  type        = list(string)
  validation {
    condition     = var.zones != null ? length(var.zones) > 0 : true
    error_message = "The `var.zones` can either be a non empty list of Availability Zones or explicit `null`."
  }
}

variable "frontend_ip" {
  description = <<-EOF
  Frontend IP configuration of the gateway load balancer.

  Following settings are available:
  - `name`                          - (Required|string) Name of the frontend IP configuration. `var.name` by default.
  - `subnet_id`                     - (Required|string) Id of a subnet to associate with the configuration.
  - `private_ip_address`            - (Optional|string) Private IP address to assign.
  - `private_ip_address_allocation` - (Optional|string) The allocation method for the private IP address.
  - `private_ip_address_version`    - (Optional|string) The IP version for the private IP address.
  EOF
  type = object({
    name                          = string
    subnet_id                     = string
    private_ip_address            = optional(string)
    private_ip_address_allocation = optional(string)
    private_ip_address_version    = optional(string)
  })
}

variable "health_probes" {
  description = <<-EOF
  Health probe configuration for the gateway load balancer backends.

  Following settings are available:
  - `name`                - (Optional|string) Name of the health probe. Defaults to `name` variable value.
  - `port`                - (Required|int)
  - `protocol`            - (Optional|string)
  - `probe_threshold`     - (Optional|int)
  - `request_path`        - (Optional|string)
  - `interval_in_seconds` - (Optional|int)
  - `number_of_probes`    - (Optional|int)

  For details, please refer to [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe#argument-reference).
  EOF
  type = map(object({
    name                = optional(string)
    port                = number
    protocol            = optional(string)
    probe_threshold     = optional(number)
    request_path        = optional(string)
    interval_in_seconds = optional(number)
    number_of_probes    = optional(number)
  }))
}

variable "backends" {
  description = <<-EOF
  Map with backend configurations for the gateway load balancer. Azure GWLB rule can have up to two backends.

  Following settings are available:
  - `name`              - (Optional|string) Name of the backend. If not specified name is generated from `name` variable and backend key.
  - `tunnel_interfaces` - (Required|map) Map with tunnel interfaces specs.)

  Each tunnel interface specification consists of following settings (refer to [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool#tunnel_interface) for details):
  - `identifier` - (Required|int) Interface identifier.
  - `port`       - (Required|int) Interface port.
  - `type`       - (Required|string) Either "External" or "Internal".

  If one backend is specified, it has to have both external and internal tunnel interfaces specified.
  For two backends, each has to have exactly one.

  On GWLB inspection enabled VM-Series instance, `identifier` and `port` default to:
  - `800`/`2000` for `Internal` tunnel type
  - `801`/`2001` for `External` tunnel type
  Variable default reflects this configuration on GWLB side. Additionally, for VM-Series tunnel interface protocol is always VXLAN.
  EOF
  default = {
    ext-int = {
      tunnel_interfaces = {
        internal = {
          identifier = 800
          port       = 2000
          protocol   = "VXLAN"
          type       = "Internal"
        }
        external = {
          identifier = 801
          port       = 2001
          protocol   = "VXLAN"
          type       = "External"
        }
      }
    }
  }
  type = map(object({
    name = optional(string)
    tunnel_interfaces = map(object({
      identifier = number
      port       = number
      protocol   = optional(string, "VXLAN")
      type       = string
    }))
  }))
}

variable "lb_rule" {
  description = <<-EOF
  Load balancing rule config.

  Available options:
  - `name`              - (Optional|string) Name for the rule. Defaults to `var.frontend_ip_config.name`.
  - `load_distribution` - (Optional|string) Refer to [provider docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule#load_distribution).
  EOF
  default     = null
  type        = map(string)
}

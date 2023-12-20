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

variable "frontend_ips" {
  description = <<-EOF
  Map of frontend IP configurations of the Gateway Load Balancer.

  Following settings are available:
  - `name`                          - (`string`, required) name of the frontend IP configuration. `var.name` by default.
  - `subnet_id`                     - (`string`, required) id of a subnet to associate with the configuration.
  - `private_ip_address`            - (`string`, optional) private IP address to assign.
  - `private_ip_address_allocation` - (`string`, optional, defaults to `Dynamic`) the allocation method for the private IP address.
  - `private_ip_address_version`    - (`string`, optional, defaults to `IPv4`) the IP version for the private IP address.
  EOF
  type = map(object({
    name                          = string
    subnet_id                     = string
    private_ip_address            = optional(string)
    private_ip_address_allocation = optional(string, "Dynamic")
    private_ip_address_version    = optional(string, "IPv4")
  }))
  validation { # name
    condition = (length(flatten([for _, v in var.frontend_ips : v.name]))
    == length(distinct(flatten([for _, v in var.frontend_ips : v.name]))))
    error_message = "The `name` property has to be unique among all frontend definitions."
  }
  validation { # private_ip_address
    condition = alltrue([
      for _, fip in var.frontend_ips :
      can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", fip.private_ip_address))
      if fip.private_ip_address != null
    ])
    error_message = "The `private_ip_address` property should be in IPv4 format."
  }
  validation { # private_ip_address_allocation
    condition = (var.frontend_ips == null ?
    true : alltrue([for k, v in var.frontend_ips : contains(["Dynamic", "Static"], v.private_ip_address_allocation)]))
    error_message = "The `private_ip_address_allocation` property can be one of \"Dynamic\", \"Static\"."
  }
  validation { # private_ip_address_version
    condition = (var.frontend_ips == null ?
    true : alltrue([for k, v in var.frontend_ips : contains(["IPv4", "IPv6"], v.private_ip_address_version)]))
    error_message = "The `private_ip_address_version` property can be one of \"IPv4\", \"IPv6\"."
  }
}

variable "health_probes" {
  description = <<-EOF
  Map of health probes configuration for the Gateway Load Balancer backends.

  Following settings are available:
  - `name`                - (`string`, optional) name of the health probe. Defaults to `name` variable value.
  - `port`                - (`number`, required) port to run the probe against
  - `protocol`            - (`string`, optional, defaults to `Tcp`) protocol used by the health probe,
                            can be one of "Tcp", "Http" or "Https".
  - `probe_threshold`     - (`number`, optional) number of consecutive probes that decide on forwarding traffic to an endpoin.
  - `request_path`        - (`string`, optional) used only for non `Tcp` probes,
                            the URI used to check the endpoint status when `protocol` is set to `Http(s)`
  - `interval_in_seconds` - (`number`, optional) interval in seconds between probes, with a minimal value of 5
  - `number_of_probes`    - (`number`, optional)
  EOF
  type = map(object({
    name                = optional(string)
    port                = number
    protocol            = optional(string, "Tcp")
    interval_in_seconds = optional(number)
    probe_threshold     = optional(number)
    request_path        = optional(string)
    number_of_probes    = optional(number)
  }))
  validation { # port
    condition = (var.health_probes == null ?
    true : alltrue([for k, v in var.health_probes : v.port != null if v.protocol == "Tcp"]))
    error_message = "The `port` property is required when protocol is set to \"Tcp\"."
  }
  validation { # port
    condition = var.health_probes == null ? true : alltrue([for k, v in var.health_probes :
      v.port >= 1 && v.port <= 65535
      if v.port != null
    ])
    error_message = "The `port` property has to be a valid TCP port."
  }
  validation { # protocol
    condition = (var.health_probes == null ?
    true : alltrue([for k, v in var.health_probes : contains(["Tcp", "Http", "Https"], v.protocol)]))
    error_message = "The `protocol` property can be one of \"Tcp\", \"Http\", \"Https\"."
  }
  validation { # interval_in_seconds
    condition = var.health_probes == null ? true : alltrue([for k, v in var.health_probes :
      v.interval_in_seconds >= 5 && v.interval_in_seconds <= 3600
      if v.interval_in_seconds != null
    ])
    error_message = "The `interval_in_seconds` property has to be between 5 and 3600 seconds (1 hour)."
  }
  validation { # probe_threshold
    condition = var.health_probes == null ? true : alltrue([for k, v in var.health_probes :
      v.probe_threshold >= 1 && v.probe_threshold <= 100
      if v.probe_threshold != null
    ])
    error_message = "The `probe_threshold` property has to be between 1 and 100."
  }
  validation { # request_path
    condition = (var.health_probes == null ?
    true : alltrue([for k, v in var.health_probes : v.request_path != null if v.protocol != "Tcp"]))
    error_message = "The `request_path` property is required when protocol is set to \"Http\" or \"Https\"."
  }
}

variable "backends" {
  description = <<-EOF
  Map with backend configurations for the Gateway Load Balancer. Azure GWLB rule can have up to two backends.

  Following settings are available:
  - `name`              - (`string`, optional) name of the backend.
                          If not specified name is generated from `name` variable and backend key.
  - `tunnel_interfaces` - (`map`, required) map with tunnel interfaces.

  Each tunnel interface specification consists of following settings:
  - `identifier` - (`number`, required) interface identifier.
  - `port`       - (`number`, required) interface port.
  - `type`       - (`string`, required) either "External" or "Internal".

  If one backend is specified, it has to have both external and internal tunnel interfaces specified.
  For two backends, each has to have exactly one.

  On GWLB inspection enabled VM-Series instance, `identifier` and `port` default to:
  - `800`/`2000` for `Internal` tunnel type
  - `801`/`2001` for `External` tunnel type

  Variable default reflects this configuration on GWLB side.
  Additionally, for VM-Series tunnel interface protocol is always VXLAN.
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
  validation { # protocol
    condition = (var.backends == null ?
      true : alltrue(flatten([for k, v in var.backends :
    [for p, r in v.tunnel_interfaces : contains(["VXLAN"], r.protocol)]])))
    error_message = "The `protocol` property can be only \"VXLAN\"."
  }
  validation { # type
    condition = (var.backends == null ?
      true : alltrue(flatten([for k, v in var.backends :
    [for p, r in v.tunnel_interfaces : contains(["Internal", "External"], r.type)]])))
    error_message = "The `type` property can be one of \"Internal\", \"External\"."
  }
}

variable "lb_rules" {
  description = <<-EOF
  Map of load balancing rules configuration.

  Available options:
  - `name`              - (`string`, optional) name for the rule.
  - `load_distribution` - (`string`, optional, defaults to `Default`) specifies the load balancing distribution type
                          to be used by the Gateway Load Balancer.
  EOF
  default = {
    default-rule = {}
  }
  type = map(object({
    name              = optional(string)
    load_distribution = optional(string, "Default")
  }))
  validation { # load_distribution
    condition = (var.lb_rules == null ?
    true : alltrue([for k, v in var.lb_rules : contains(["Default", "SourceIP", "SourceIPProtocol"], v.load_distribution)]))
    error_message = "The `load_distribution` property can be one of \"Default\", \"SourceIP\", \"SourceIPProtocol\"."
  }
}

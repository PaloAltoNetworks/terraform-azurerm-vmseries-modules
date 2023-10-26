variable "name" {
  description = "The name of the Load Balancer."
  type        = string
}

variable "resource_group_name" {
  description = "Name of a pre-existing Resource Group to place the resources in."
  type        = string
}

variable "location" {
  description = "Region to deploy the resources in."
  type        = string
}

variable "zones" {
  description = <<-EOF
  Controls zones for Load Balancer's Fronted IP configurations.

  For:

  - public IPs    - these are zones in which the public IP resource is available
  - private IPs   - this represents Zones to which Azure will deploy paths leading to Load Balancer frontend IPs
                    (all frontends are affected)

  Setting this variable to explicit `null` disables a zonal deployment.
  This can be helpful in regions where Availability Zones are not available.
  
  For public Load Balancers, since this setting controls also Availability Zones for public IPs,
  you need to specify all zones available in a region (typically 3): `["1","2","3"]`.
  EOF
  default     = ["1", "2", "3"]
  type        = list(string)
  validation {
    condition     = length(var.zones) > 0 || var.zones == null
    error_message = "The `var.zones` can either bea non empty list of Availability Zones or explicit `null`."
  }
}

variable "tags" {
  description = "Azure tags to apply to the created resources."
  default     = {}
  nullable    = false
  type        = map(string)
}

variable "frontend_ips" {
  description = <<-EOF
  Frontend IP configuration.
  EOF
  type = map(object({
    name                     = string
    public_ip_name           = optional(string)
    create_public_ip         = optional(bool, false)
    public_ip_resource_group = optional(string)
    subnet_id                = optional(string)
    private_ip_address       = optional(string)
    gwlb_fip_id              = optional(string)
  }))
}

variable "inbound_rules" {
  description = <<-EOF
  Inbound rules.
  EOF
  default     = {}
  nullable    = false
  type = map(object({
    name                = string
    frontend_ip_key     = string
    protocol            = string
    port                = number
    backend_port        = optional(number)
    health_probe_key    = optional(string, "default")
    floating_ip         = optional(bool, true)
    session_persistence = optional(string, "Default")
    nsg_priority        = optional(number)
  }))
}

variable "outbound_rules" {
  description = <<-EOF
  Outbound rules.
  EOF
  default     = {}
  nullable    = false
  type = map(object({
    name                     = string
    frontend_ip_key          = string
    protocol                 = string
    allocated_outbound_ports = optional(number)
    enable_tcp_reset         = optional(bool)
    idle_timeout_in_minutes  = optional(number)
  }))
}

variable "backend_name" {
  description = "The name of the backend pool to create. All frontends of the Load Balancer always use the same backend."
  default     = "vmseries_backend"
  nullable    = false
  type        = string
}

variable "health_probes" {
  description = <<-EOF
  Backend's health probe definition.

  When this property is either:

  - not defined at all, or
  - at least one `in_rule` has no health probe specified

  a default, TCP based probe will be created for port 80.

  Following properties are available:

  - `name`                  - (`string`, required) name of the health check probe
  - `protocol`              - (`string`, required) protocol used by the health probe, can be one of "Tcp", "Http" or "Https"
  - `port`                  - (`number`, required for `Tcp`, defaults to protocol port for `Http(s)` probes) port to run
                              the probe against
  - `probe_threshold`       - (`number`, optional, defaults to Azure defaults) number of consecutive probes that decide
                              on forwarding traffic to an endpoint
  - `interval_in_seconds`   - (`number, optional, defaults to Azure defaults) interval in seconds between probes,
                              with a minimal value of 5
  - `request_path`          - (`string`, optional, defaults to `/`) used only for non `Tcp` probes,
                              the URI used to check the endpoint status when `protocol` is set to `Http(s)`
  EOF
  default     = null
  type = map(object({
    name                = string
    protocol            = string
    port                = optional(number)
    probe_threshold     = optional(number)
    interval_in_seconds = optional(number)
    request_path        = optional(string, "/")
  }))
  validation { # keys
    condition     = var.health_probes == null ? true : !anytrue([for k, _ in var.health_probes : k == "default"])
    error_message = "The key describing a health probe cannot be \"default\"."
  }
  validation { # name
    condition     = var.health_probes == null ? true : length([for _, v in var.health_probes : v.name]) == length(distinct([for _, v in var.health_probes : v.name]))
    error_message = "The `name` property has to be unique among all health probe definitions."
  }
  validation { # name
    condition     = var.health_probes == null ? true : !anytrue([for _, v in var.health_probes : v.name == "default_vmseries_probe"])
    error_message = "The `name` property cannot be \"default_vmseries_probe\"."
  }
  validation { # protocol
    condition     = var.health_probes == null ? true : alltrue([for k, v in var.health_probes : contains(["Tcp", "Http", "Https"], v.protocol)])
    error_message = "The `protocol` property can be one of \"Tcp\", \"Http\", \"Https\"."
  }
  validation { # port
    condition     = var.health_probes == null ? true : alltrue([for k, v in var.health_probes : v.port != null if v.protocol == "Tcp"])
    error_message = "The `port` property is required when protocol is set to \"Tcp\"."
  }
  validation { # port
    condition = var.health_probes == null ? true : alltrue([for k, v in var.health_probes :
      v.port >= 1 && v.port <= 65535
      if v.port != null
    ])
    error_message = "The `port` property has to be a valid TCP port."
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
  validation { # request
    condition     = var.health_probes == null ? true : alltrue([for k, v in var.health_probes : v.request_path != null if v.protocol != "Tcp"])
    error_message = "value"
  }
}

variable "nsg_auto_rules_settings" {
  description = <<-EOF
  Controls automatic creation of NSG rules for all defined inbound rules.

  When skipped or assigned an explicit `null`, disables rules creation.

  Following properties are supported:

  - `nsg_name`                - (`string`, required) name of an existing Network Security Group
  - `nsg_resource_group_name  - (`string`, optional, defaults to Load Balancer's RG) name of a Resource Group hosting the NSG
  - `source_ips`              - (`list`, required) list of CIDRs/IP addresses from which access to the frontends will be allowed
  - `base_priority`           - (`nubmer`, optional, defaults to `1000`) minimum rule priority from which all
                                auto-generated rules grow, can take values between `100` and `4000`
  EOF
  default     = null
  type = object({
    nsg_name                = string
    nsg_resource_group_name = optional(string)
    source_ips              = list(string)
    base_priority           = optional(number, 1000)
  })
  validation { # source_ips
    condition = var.nsg_auto_rules_settings != null ? alltrue([
      for ip in var.nsg_auto_rules_settings.source_ips :
      can(regex("^(\\d{1,3}\\.){3}\\d{1,3}(\\/[12]?[0-9]|\\/3[0-2])?$", ip))
    ]) : true
    error_message = "The `source_ips` property can an IPv4 address or address space in CIDR notation."
  }
  validation { # base_priority
    condition = try(
      var.nsg_auto_rules_settings.base_priority >= 100 && var.nsg_auto_rules_settings.base_priority <= 4000,
      true
    )
    error_message = "The `base_priority` property can take only values between `100` and `4000`."
  }
}

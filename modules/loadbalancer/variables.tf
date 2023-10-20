variable "name" {
  description = "The name of the load balancer."
  type        = string
}

variable "resource_group_name" {
  description = "Name of a pre-existing Resource Group to place the resources in."
  type        = string
}

variable "location" {
  description = "Region to deploy the resources."
  type        = string
}

variable "zones" {
  description = <<-EOF
  Controls zones for load balancer's Fronted IP configurations.

  For:

  - public IPs    - these are zones in which the public IP resource is available
  - private IPs   - this represents Zones to which Azure will deploy paths leading to Load Balancer frontend IPs (all frontends are affected)

  Setting this variable to explicit `null` disables a zonal deployment.
  This can be helpful in regions where Availability Zones are not available.
  
  For public Load Balancers, since this setting controls also Availability Zones for public IPs, you need to specify all zones available in a region (typically 3): `["1","2","3"]`
  EOF
  default     = ["1", "2", "3"]
  type        = list(string)
  validation {
    condition     = length(var.zones) > 0 || var.zones == null
    error_message = "The `var.zones` can either bea non empty list of Availability Zones or `null`."
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
  A map of objects describing LB Frontend IP configurations, inbound and outbound rules.
  
  Each Frontend IP configuration can have multiple rules assigned. They are defined in a maps called `in_rules` and `out_rules` for inbound and outbound rules respectively. 

  Since this module can be used to create either a private or a public Load Balancer some properties can be mutually exclusive. To ease configuration they were grouped per Load Balancer type.

  Private Load Balancer:

  - `name`                    - (`string`, required) name of a frontend IP configuration
  - `subnet_id`               - (`string`, required) an ID of an existing subnet that will host the private Load Balancer
  - `private_ip_address`      - (`string`, optional, defaults to `null`) when assigned it will become the IP address of the Load Balancer, when skipped the IP will be assigned from DHCP.
  - `gateway_load_balancer_frontend_ip_configuration_id` - ????
  - `in_rules`                - (`map`, optional, defaults to `{}`) a map defining inbound rules, see details below

  Public Load Balancer:

  - `name`                    - (`string`, required) name of a frontend IP configuration
  - `public_ip_name`          - (`string`, required) name of a public IP resource
  - `create_public_ip`        - (`bool`, optional, defaults to `false`) when set to `true` a new public IP will be created, otherwise an existing resource will be used; in both cases the name of the resource is controled by `public_ip_name`
  - `public_ip_resource_group`  - (`string`, optional, defaults to `null`) name of a Resource Group hosting an existing public IP resource
  - `in_rules`                - (`map`, optional, defaults to `{}`) a map defining inbound rules, see details below
  - `out_rules`               - (`map`, optional, defaults to `{}`) a map defining outbound rules, see details below
 
  Below are the properties for the **inbound rules** map:

  - `name`                - (`string`, required) a name of an inbound rule
  - `protocol`            - (`string`, required) communication protocol, either 'Tcp', 'Udp' or 'All'.
  - `port`                - (`number`, required) communication port, this is both the front- and the backend port if `backend_port` is not set; value of `0` means all ports
  - `backend_port`        - (`number`, optional, defaults to `null`) this is the backend port to forward traffic to in the backend pool
  - `health_probe_key`    - (`string`, optional, defaults to `default`) a key from the `var.health_probes` map defining a health probe to use with this rule
  - `floating_ip`         - (`bool`, optional, defaults to `true`) enables floating IP for this rule.
  - `session_persistence` - (`string`, optional, defaults to `Default`) controls session persistance/load distribution, three values are possible:
    - `Default` : this is the 5 tuple hash
    - `SourceIP` : a 2 tuple hash is used
    - `SourceIPProtocol` : a 3 tuple hash is used
  - `nsg_priority`        - (number, optional, defaults to `null`) this becomes a priority of an auto-generated NSG rule, when skipped the rule priority will be auto-calculated, for more details on auto-generated NSG rules see [`nsg_auto_rules_settings`](#nsg_auto_rules_settings)

  Below are the properties for **outbound rules** map. 
  
  > [!Warning]
  > Setting at least one `out_rule` switches the outgoing traffic from SNAT to outbound rules. Keep in mind that since we use a single backend, and you cannot mix SNAT and outbound rules traffic in rules using the same backend, setting one `out_rule` switches the outgoing traffic route for **ALL** `in_rules`:

  - `name`                      - (`string`, required) a name of an outbound rule
  - `protocol`                  - (`string`, required) protocol used by the rule. One of `All`, `Tcp` or `Udp` is accepted
  - `allocated_outbound_ports`  - (`number`, optional, defaults to `null`) number of ports allocated per instance, when skipped provider defaults will be used (`1024`), when set to `0` port allocation will be set to default number (Azure defaults); maximum value is `64000`
  - `enable_tcp_reset`          - (`bool`, optional, defaults to `null`) ignored when `protocol` is set to `Udp`
  - `idle_timeout_in_minutes`   - (`number`, optional, defaults to `null`) TCP connection timeout in minutes (between 4 and 120) in case the connection is idle, ignored when `protocol` is set to `Udp`

  Examples

  ```hcl
  # rules for a public LB, reusing an existing public IP and doing port translation
  frontend_ips = {
    pip_existing = {
      create_public_ip         = false
      public_ip_name           = "my_ip"
      public_ip_resource_group = "my_rg_name"
      in_rules = {
        HTTP = {
          port         = 80
          protocol     = "Tcp"
          backend_port = 8080
        }
      }
    }
  }

  # rules for a private LB, with a static private IP address and one HA PORTs rule
  frontend_ips = {
    internal = {
      subnet_id                     = azurerm_subnet.this.id
      private_ip_address            = "192.168.0.10"
      in_rules = {
        HA_PORTS = {
          port         = 0
          protocol     = "All"
        }
      }
    }
  }

  # rules for a public LB, session persistance with 2 tuple hash outbound rule defined
  frontend_ips = {
    rule_1 = {
      create_public_ip = true
      in_rules = {
        HTTP = {
          port     = 80
          protocol = "Tcp"
          session_persistence = "SourceIP"
        }
      }
    }
    out_rules = {
      "outbound_tcp" = {
        protocol                 = "Tcp"
        allocated_outbound_ports = 2048
        enable_tcp_reset         = true
        idle_timeout_in_minutes  = 10
      }
    }
  }
  ```
  EOF
  type = map(object({
    name                                               = string
    public_ip_name                                     = optional(string)
    create_public_ip                                   = optional(bool, false)
    public_ip_resource_group                           = optional(string)
    subnet_id                                          = optional(string)
    private_ip_address                                 = optional(string)
    gateway_load_balancer_frontend_ip_configuration_id = optional(string)
    in_rules = optional(map(object({
      name                = string
      protocol            = string
      port                = number
      backend_port        = optional(number)
      health_probe_key    = optional(string, "default")
      floating_ip         = optional(bool, true)
      session_persistence = optional(string, "Default")
      nsg_priority        = optional(number)
    })), {})
    out_rules = optional(map(object({
      name                     = string
      protocol                 = string
      allocated_outbound_ports = optional(number)
      enable_tcp_reset         = optional(bool)
      idle_timeout_in_minutes  = optional(number)
    })), {})
  }))
  validation { # name
    condition     = length(flatten([for _, v in var.frontend_ips : v.name])) == length(distinct(flatten([for _, v in var.frontend_ips : v.name])))
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
  validation { # in_rule.name
    condition = length(flatten([
      for _, fip in var.frontend_ips : [
        for _, in_rule in fip.in_rules : in_rule.name
        ]])) == length(distinct(flatten([
        for _, fip in var.frontend_ips : [
          for _, in_rule in fip.in_rules : in_rule.name
    ]])))
    error_message = "The `in_rule.name` property has to be unique among all in rules definitions."
  }
  validation { # in_rule.protocol
    condition = alltrue(flatten([
      for _, fip in var.frontend_ips : [
        for _, in_rule in fip.in_rules : contains(["Tcp", "Udp", "All"], in_rule.protocol)
      ]
    ]))
    error_message = "The `in_rule.protocol` property should be one of: \"Tcp\", \"Udp\", \"All\"."
  }
  validation { # in_rule.port
    condition = alltrue(flatten([
      for _, fip in var.frontend_ips : [
        for _, in_rule in fip.in_rules : (in_rule.port >= 0 && in_rule.port <= 65535)
      ]
    ]))
    error_message = "The `in_rule.port` should be a valid TCP port number or `0` for all ports."
  }
  validation { # in_rule.backend_port
    condition = alltrue(flatten([
      for _, fip in var.frontend_ips : [
        for _, in_rule in fip.in_rules :
        (in_rule.backend_port > 0 && in_rule.backend_port <= 65535)
        if in_rule.backend_port != null
      ]
    ]))
    error_message = "The `in_rule.backend_port` should be a valid TCP port number."
  }
  validation { # in_rule.sessions_persistence
    condition = alltrue(flatten([
      for _, fip in var.frontend_ips : [
        for _, in_rule in fip.in_rules : contains(["Default", "SourceIP", "SourceIPProtocol"], in_rule.session_persistence)
      ]
    ]))
    error_message = "The `in_rule.session_persistence` property should be one of: \"Default\", \"SourceIP\", \"SourceIPProtocol\"."
  }
  validation { # in_rule.nsg_priority
    condition = alltrue(flatten([
      for _, fip in var.frontend_ips : [
        for _, in_rule in fip.in_rules :
        in_rule.nsg_priority >= 100 && in_rule.nsg_priority <= 4000
        if in_rule.nsg_priority != null
      ]
    ]))
    error_message = "The `in_rule.nsg_priority` property be a number between 100 and 4096."
  }
  validation { # out_rule.name
    condition = length(flatten([
      for _, fip in var.frontend_ips : [
        for _, out_rule in fip.out_rules : out_rule.name
        ]])) == length(distinct(flatten([
        for _, fip in var.frontend_ips : [
          for _, out_rule in fip.out_rules : out_rule.name
    ]])))
    error_message = "The `out_rule.name` property has to be unique among all in rules definitions."
  }
  validation { # out_rule.protocol
    condition = alltrue(flatten([
      for _, fip in var.frontend_ips : [
        for _, out_rule in fip.out_rules : contains(["Tcp", "Udp", "All"], out_rule.protocol)
      ]
    ]))
    error_message = "The `out_rule.protocol` property should be one of: \"Tcp\", \"Udp\", \"All\"."
  }
  validation { # out_rule.allocated_outbound_ports
    condition = alltrue(flatten([
      for _, fip in var.frontend_ips : [
        for _, out_rule in fip.out_rules :
        out_rule.allocated_outbound_ports >= 0 && out_rule.allocated_outbound_ports <= 64000
        if out_rule.allocated_outbound_ports != null
      ]
    ]))
    error_message = "The `out_rule.allocated_outbound_ports` property should can be either `0` or a valid TCP port number with the maximum value of 64000."
  }
  validation { # out_rule.idle_timeout_in_minutes
    condition = alltrue(flatten([
      for _, fip in var.frontend_ips : [
        for _, out_rule in fip.out_rules :
        out_rule.idle_timeout_in_minutes >= 4 && out_rule.idle_timeout_in_minutes <= 120
        if out_rule.idle_timeout_in_minutes != null
      ]
    ]))
    error_message = "The `out_rule.idle_timeout_in_minutes` property should can take values between 4 and 120 (minutes)."
  }
}

variable "backend_name" {
  description = "The name of the backend pool to create. All frontends of the load balancer always use the same backend."
  default     = "vmseries_backend"
  nullable    = false
  type        = string
}

variable "health_probes" {
  description = <<-EOF
  Backend's health probe definition.

  When this property is not defined, or set to `null`, a default, TCP based probe will be created for port 80.

  Following properties are available:

  - `name`                  - (`string`, optional, defaults to `"vmseries_probe"`) name of the health check probe
  - `protocol`              - (`string`, optional, defaults to `"TCP"`) protocol used by the health probe, can be one of "Tcp", "Http" or "Https"
  - `port`                  - (`number`, optional, defaults to `80`) port to run the probe against
  - `probe_threshold`       - (`number`, optional, defaults to Azure defaults) number of consecutive probes that decide on forwarding traffic to an endpoint
  - `interval_in_seconds`   - (`number, optional, defaults to Azure defaults) interval in seconds between probes, with a minimal value of 5
  - `request_path`          - (`string`, optional, defaults to Azure defaults) the URI used to check the endpoint status when `protocol` is set to `Http(s)`
  EOF
  default = {
    default = {
      name     = "vmseries_probe"
      protocol = "Tcp"
      port     = 80
    }
  }
  nullable = false
  type = map(object({
    name                = string
    protocol            = string
    port                = optional(number)
    probe_threshold     = optional(number)
    interval_in_seconds = optional(number)
    request_path        = optional(string, "/")
  }))
  validation { # name
    condition     = length(flatten([for _, v in var.health_probes : v.name])) == length(distinct(flatten([for _, v in var.health_probes : v.name])))
    error_message = "The `name` property has to be unique among all health probe definitions."
  }
  validation { # protocol
    condition     = alltrue([for k, v in var.health_probes : contains(["Tcp", "Http", "Https"], v.protocol)])
    error_message = "The `protocol` property can be one of \"Tcp\", \"Http\", \"Https\"."
  }
  validation { # port
    condition     = alltrue([for k, v in var.health_probes : v.port != null if v.protocol == "Tcp"])
    error_message = "The `port` property is required when protocol is set to \"Tcp\"."
  }
  validation { # port
    condition = alltrue([for k, v in var.health_probes :
      v.port >= 1 && v.port <= 65535
      if v.port != null
    ])
    error_message = "The `port` property has to be a valid TCP port."
  }
  validation { # interval_in_seconds
    condition = alltrue([for k, v in var.health_probes :
      v.interval_in_seconds >= 5 && v.interval_in_seconds <= 3600
      if v.interval_in_seconds != null
    ])
    error_message = "The `interval_in_seconds` property has to be between 5 and 3600 seconds (1 hour)."
  }
  validation { # probe_threshold
    condition = alltrue([for k, v in var.health_probes :
      v.probe_threshold >= 1 && v.probe_threshold <= 100
      if v.probe_threshold != null
    ])
    error_message = "The `probe_threshold` property has to be between 1 and 100."
  }
  validation { # request
    condition     = alltrue([for k, v in var.health_probes : v.request_path != null if v.protocol != "Tcp"])
    error_message = "value"
  }
}

variable "nsg_auto_rules_settings" {
  description = <<-EOF
  Controls automatic creation of NSG rules for all defined inbound rules.

  Following properties are supported:

  - `nsg_name`            - (`string`, required) name of an existing Network Security Group
  - `resource_group_name  - (`string`, optional, defaults to `var.resource_group_name`) name of a Resource Group hosting the NSG
  - `source_ips`          - (`list`, required) either `*` or a list of CIDRs/IP addresses from which access to the frontends will be allowed
  - `base_priority`       - (`nubmer`, optional, defaults to `1000`) minimum rule priority from which all auto-generated rules grow
  EOF
  default     = null
  type = object({
    nsg_name                = string
    nsg_resource_group_name = optional(string)
    source_ips              = list(string)
    base_priority           = optional(number, 1000)
  })
}

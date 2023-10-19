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
  - `protocol`                  - (`string`, required) protocol used by the rule. On of `All`, `Tcp` or `Udp` is accepted
  - `allocated_outbound_ports`  - (`number`, optional, defaults to `1024`) number of ports allocated per instance
  - `enable_tcp_reset`          - (`bool`, optional, defaults to `false`) ignored when `protocol` is set to `Udp`
  - `idle_timeout_in_minutes`   - (`number`, optional, defaults to `4`) TCP connection timeout in minutes in case the connection is idle, ignored when `protocol` is set to `Udp`

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
      floating_ip         = optional(bool, true)
      session_persistence = optional(string, "Default")
      nsg_priority        = optional(number)
    })), {})
    out_rules = optional(map(object({
      name                     = string
      protocol                 = string
      allocated_outbound_ports = optional(number, 1024)
      enable_tcp_reset         = optional(bool, false)
      idle_timeout_in_minutes  = optional(number, 4)
    })), {})
  }))
}

variable "backend_name" {
  description = "The name of the backend pool to create. All frontends of the load balancer always use the same backend."
  default     = "vmseries_backend"
  nullable    = false
  type        = string
}

variable "health_probe" {
  description = <<-EOF
  Backend's health probe definition.

  Following properties are available:

  - `name`  - (`string`, optional, defaults to `"vmseries_probe"`) name of the health check probe
  - `port`  - (`number`, optional, defaults to `80`) port to run the probe against
  EOF
  default = {
    name = "vmseries_probe"
    port = 80
  }
  nullable = false
  type = object({
    name = optional(string, "vmseries_probe")
    port = optional(number, 80)
  })
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

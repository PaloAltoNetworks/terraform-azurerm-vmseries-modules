variable "frontend_ips" {
  description = <<-EOF
  A map of objects describing LB Frontend IP configurations, inbound and outbound rules. Used for both public or private load balancers. 
  Keys of the map are names of LB Frontend IP configurations.

  Each Frontend IP configuration can have multiple rules assigned. They are defined in a maps called `in_rules` and `out_rules` for inbound and outbound rules respectively. A key in this map is the name of the rule, while value is the actual rule configuration. To understand this structure please see examples below.

  **Inbound rules.**

  Here is a list of properties supported by each `in_rule`:

  - `protocol` : required, communication protocol, either 'Tcp', 'Udp' or 'All'.
  - `port` : required, communication port, this is both the front- and the backend port if `backend_port` is not given.
  - `backend_port` : optional, this is the backend port to forward traffic to in the backend pool.
  - `floating_ip` : optional, defaults to `true`, enables floating IP for this rule.
  - `session_persistence` : optional, defaults to 5 tuple (Azure default), see `Session persistence/Load distribution` below for details.

  Public LB

  - `create_public_ip` : Optional. Set to `true` to create a public IP.
  - `public_ip_name` : Ignored if `create_public_ip` is `true`. The existing public IP resource name to use.
  - `public_ip_resource_group` : Ignored if `create_public_ip` is `true` or if `public_ip_name` is null. The name of the resource group which holds `public_ip_name`.

  Example

  ```
  frontend_ips = {
    pip_existing = {
      create_public_ip         = false
      public_ip_name           = "my_ip"
      public_ip_resource_group = "my_rg_name"
      in_rules = {
        HTTP = {
          port         = 80
          protocol     = "Tcp"
        }
      }
    }
  }
  ```

  Forward to a different port on backend pool

  ```
  frontend_ips = {
    pip_existing = {
      create_public_ip         = false
      public_ip_name           = "my_ip"
      public_ip_resource_group = "my_rg_name"
      in_rules = {
        HTTP = {
          port         = 80
          backend_port = 8080
          protocol     = "Tcp"
        }
      }
    }
  }
  ```

  Private LB

  - `subnet_id` : Identifier of an existing subnet. This also trigger creation of an internal LB.
  - `private_ip_address` : A static IP address of the Frontend IP configuration, has to be in limits of the subnet's (specified by `subnet_id`) address space. When not set, changes the address allocation from `Static` to `Dynamic`.

  Example

  ```
  frontend_ips = {
    internal_fe = {
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
  ```

  Session persistence/Load distribution

  By default the Load Balancer uses a 5 tuple hash to map traffic to available servers. This can be controlled using `session_persistence` property defined inside a rule. Available values are:

  - `Default` : this is the 5 tuple hash - this method is also used when no property is defined
  - `SourceIP` : a 2 tuple hash is used
  - `SourceIPProtocol` : a 3 tuple hash is used

  Example

  ```
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
    }
  ```

  **Outbound rules.**

  Each Frontend IP config can have outbound rules specified. Setting at least one `out_rule` switches the outgoing traffic from SNAT to Outbound rules. Keep in mind that since we use a single backend, and you cannot mix SNAT and Outbound rules traffic in rules using the same backend, setting one `out_rule` switches the outgoing traffic route for **ALL** `in_rules`.

  Following properties are available:

  - `protocol` : Protocol used by the rule. On of `All`, `Tcp` or `Udp` is accepted.
  - `allocated_outbound_ports` : Number of ports allocated per instance. Defaults to `1024`.
  - `enable_tcp_reset` : Ignored when `protocol` is set to `Udp`, defaults to `False` (Azure defaults).
  - `idle_timeout_in_minutes` : Ignored when `protocol` is set to `Udp`. TCP connection timeout in case the connection is idle. Defaults to 4 minutes (Azure defaults).

  Example:

  ```
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
      out_rules = {
        "outbound_tcp" = {
          protocol                 = "Tcp"
          allocated_outbound_ports = 2048
          enable_tcp_reset         = true
          idle_timeout_in_minutes  = 10
        }
      }
    }
  }

  EOF
}

variable "resource_group_name" {
  description = "Name of a pre-existing Resource Group to place the resources in."
  type        = string
}

variable "location" {
  description = "Region to deploy load balancer and dependencies."
  type        = string
}

variable "backend_name" {
  description = <<-EOF
    The name of the backend pool to create. All the frontends of the load balancer always use the same single backend.
  EOF
  default     = "vmseries_backend"
  type        = string
  nullable    = false
}

variable "name" {
  description = "The name of the load balancer."
  type        = string
}

variable "probe_name" {
  description = "The name of the load balancer probe."
  default     = "vmseries_probe"
  type        = string
  nullable    = false
}

variable "probe_port" {
  description = "Health check port number of the load balancer probe."
  default     = "80"
  type        = string
}

variable "network_security_allow_source_ips" {
  description = <<-EOF
    List of IP CIDR ranges (such as `["192.168.0.0/16"]` or `["*"]`) from which the inbound traffic to all frontends should be allowed.
    If it's empty, user is responsible for configuring a Network Security Group separately.
    The list cannot include Azure tags like "Internet" or "Sql.EastUS".
  EOF
  default     = []
  type        = list(string)
}

variable "network_security_resource_group_name" {
  description = "Name of the Resource Group where the `network_security_group_name` resides. If empty, defaults to `resource_group_name`."
  default     = ""
  type        = string
}

variable "network_security_group_name" {
  description = <<-EOF
    Name of the pre-existing Network Security Group (NSG) where to add auto-generated rules. Each NSG rule corresponds to a single `in_rule` on the load balancer.
    User is responsible to associate the NSG with the load balancer's subnet, the module only supplies the rules.
    If empty, user is responsible for configuring an NSG separately.
  EOF
  default     = null
  type        = string
}

variable "network_security_base_priority" {
  description = <<-EOF
    The base number from which the auto-generated priorities of the NSG rules grow.
    Ignored if `network_security_group_name` is empty or if `network_security_allow_source_ips` is empty.
  EOF
  default     = 1000
  type        = number
}

variable "enable_zones" {
  description = "If `false`, all the subnet-associated frontends and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones."
  default     = true
  type        = bool
}

variable "tags" {
  description = "Azure tags to apply to the created resources."
  default     = {}
  type        = map(string)
}

variable "avzones" {
  description = <<-EOF
  Controls zones for load balancer's Fronted IP configurations. For:

  * public IPs - these are regions in which the IP resource is available
  * private IPs - this represents Zones to which Azure will deploy paths leading to this Frontend IP.

  For public IPs, after provider version 3.x (Azure API upgrade) you need to specify all zones available in a region (typically 3), ie: for zone-redundant with 3 availability zone in current region value will be:
  ```["1","2","3"]```
  EOF
  default     = []
  type        = list(string)
}

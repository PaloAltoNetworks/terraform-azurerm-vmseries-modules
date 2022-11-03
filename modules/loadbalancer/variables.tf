variable "frontend_ips" {
  description = <<-EOF
  A map of objects describing LB frontend IP configurations. Used for both public or private load balancers. 
  Keys of the map are the names of the created load balancers.

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
      rules = {
        HTTP = {
          port         = 80
          protocol     = "Tcp"
        }
      }
    }
  }
  ```

  Private LB

  - `subnet_id` : Identifier of an existing subnet.
  - `private_ip_address_allocation` : Type of private allocation: `Static` or `Dynamic`.
  - `private_ip_address` : If `Static`, the private IP address.

  Example

  ```
  frontend_ips = {
    internal_fe = {
      subnet_id                     = azurerm_subnet.this.id
      private_ip_address_allocation = "Static"
      private_ip_address            = "192.168.0.10"
      rules = {
        HA_PORTS = {
          port         = 0
          protocol     = "All"
        }
      }
    }
  }
  ```

  Zone usage

  You can specifies a list of Availability Zones in which the IP Address for this Load Balancer should be located.

  - `zones` : Specify in which zones you want to create frontend IP address. Pass list with zone coverage, ie: `["1","2","3"]`

  Example

  ```
  frontend_ips = {
    internal = {
      subnet_id                     = azurerm_subnet.this.id
      private_ip_address_allocation = "Static"
      private_ip_address            = "192.168.0.10"
      zones                         = ["1","2","3"]
    }
  }
  ```

  Session persistence/Load distribution

  By default the Load Balancer uses a 5 tuple hash to map traffic to available servers. This can be controlled using `session_persistence` property defined inside a role. Available values are:

  - `Default` : this is the 5 tuple hash - this method is also used when no property is defined
  - `SourceIP` : a 2 tuple hash is used
  - `SourceIPProtocol` : a 3 tuple hash is used

  Example

  ```
    frontend_ips = {
      rule_1 = {
        create_public_ip = true
        rules = {
          HTTP = {
            port     = 80
            protocol = "Tcp"
            session_persistence = "SourceIP"
          }
        }
      }
    }
  ```
  EOF
}
variable "outbound_rules" {
  description = <<-EOF
  A map of objects describing LB outbound rules.

  The key is the name of a rule. If `create_public_ip` is set to `true` this will also be a name of the Public IP that will be created and used by the rule.

  This property controls also `disable_outbound_snat` property of the `azurerm_lb_rule` resource. If `outbound_rules` is present `disable_outbound_snat` is set to `true` to switch the backend pool to use the outbound rules for outgoing traffic instead of the default route. When absent (or empty) - `disable_outbound_snat` is set to `false`.

  Following properties are available:

  - `create_public_ip` : Optional. Set to `true` to create a public IP.
  - `public_ip_name` : Ignored if `create_public_ip` is `true`. The existing public IP resource name to use.
  - `public_ip_resource_group` : Ignored if `create_public_ip` is `true` or if `public_ip_name` is null. The name of the resource group which holds `public_ip_name`. When skipped Load Balancer's Resource Group will be used.
  - `protocol` : Protocol used by the rule. On of `All`, `Tcp` or `Udp` is accepted.
  - `allocated_outbound_ports` : Number of ports allocated per instance. Defaults to `1024`.
  - `enable_tcp_reset` : Ignored when `protocol` is set to `Udp`, defaults to `False` (Azure defaults).
  - `idle_timeout_in_minutes` : Ignored when `protocol` is set to `Udp`. TCP connection timeout in case the connection is idle. Defaults to 4 minutes (Azure defaults).

  Example:

  ```
  outbound_rules = {
    "outbound_tcp" = {
      create_public_ip         = true
      protocol                 = "Tcp"
      allocated_outbound_ports = 2048
      enable_tcp_reset         = true
      idle_timeout_in_minutes  = 10
    }
  }
  ```
  EOF
  default     = {}
  type        = any
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
    The name of the backend pool to create. If an empty name is provided, it will be auto-generated.
    All the frontends of the load balancer always use the same single backend.
  EOF
  default     = ""
  type        = string
}

variable "name" {
  description = "The name of the load balancer."
  type        = string
}

variable "probe_name" {
  description = "The name of the load balancer probe."
  type        = string
  default     = ""
}

variable "probe_port" {
  description = "Health check port number of the load balancer probe."
  default     = "80"
  type        = string
}

variable "network_security_allow_source_ips" {
  description = <<-EOF
    List of IP CIDR ranges (such as `["192.168.0.0/16"]` or `["*"]`) from which the inbound traffic to all frontends should be allowed.
    If it's empty, user is responsible for configuring a Network Security Group separately, possibly using the `frontend_combined_rules` output.
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
    Name of the pre-existing Network Security Group (NSG) where to add auto-generated rules, each of which allows traffic through one rule of a frontend of this load balancer.
    User is responsible to associate the NSG with the load balancer's subnet, the module only supplies the rules.
    If empty, user is responsible for configuring an NSG separately, possibly using the `frontend_combined_rules` output.
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
  description = "If false, all the subnet-associated frontends and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones."
  default     = true
}

variable "tags" {
  description = "Azure tags to apply to the created resources."
  default     = {}
  type        = map(string)
}

variable "avzones" {
  description = <<-EOF
  After provider version 3.x you need to specify in which availability zone(s) you want to place IP.
  ie: for zone-redundant with 3 availability zone in current region value will be:
  ```["1","2","3"]```
  EOF
  default     = []
  type        = list(string)
}
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

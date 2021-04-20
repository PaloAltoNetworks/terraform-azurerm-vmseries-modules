variable "frontend_ips" {
  description = <<-EOF
  A map of objects describing LB frontend IP configurations. Used for both public or private load balancers. 
  Keys of the map are the names of the created load balancers.
  ### Public loadbalancer:
  - `create_public_ip` : Set to `true` to create a public IP, otherwise use a pre-existing public IP.
  - `public_ip_name` : Ignored if `create_public_ip` is `true`. The existing public IP resource name to use.
  - `public_ip_resource_group` : Ignored if `create_public_ip` is `true`. The existing public IP resource group name.
  #### Private loadbalancer:
  - `subnet_id` : ID of an existing subnet.
  - `private_ip_address_allocation` : Type of private allocation: `Static` or `Dynamic`.
  - `private_ip_address` : If Static, the private IP address.
  Example:

  ```
  # Public load balancer example
  frontend_ips = {
    pip-existing = {
      create_public_ip         = false
      public_ip_name           = "my_ip"
      public_ip_resource_group = "my_rg"
      rules = {
        HTTP = {
          port         = 80
          protocol     = "Tcp"
        }
      }
    }
  }

  # Private load balancer example
  frontend_ips = {
    internal_fe = {
      subnet_id                     = ""
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
  description = "The name of the backend pool to create. If an empty name is provided, it will be auto-generated. All the frontends of the load balancer always use the same single backend."
  default     = ""
  type        = string
}

variable "name_lb" {
  description = "The name of the load balancer."
  type        = string
}

variable "name_probe" {
  description = "The name of the load balancer probe."
  type        = string
  default     = ""
}

variable "probe_port" {
  description = "Health check port number of the load balancer probe."
  default     = "80"
  type        = string
}

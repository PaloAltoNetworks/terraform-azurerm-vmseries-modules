variable "frontend_ips" {
  description = <<-EOF
  A map of objects describing LB Frontend IP configurations for public or private loadbalancer type. 
  Keys of the map are the names of new resources.
  # Public loadbalancer:
  - `create_public_ip` : Greenfield or Brawnfield deployment for public IP.
  - `public_ip_name` : If Brawnfield deployment - the existing ip name in Azure resource for public IP.
  - `public_ip_resource_group` : If Brawnfield deployment - the existing resource group in Azure resource for public IP.
  # Private loadbalancer:
  - `subnet_id` : ID of an existing subnet.
  - `private_ip_address_allocation` : Type of private allocation Static/Dynamic.
  - `private_ip_address` : If Static, private IP.
  Example:

  ```
  # Public loadbalancer exmple
  frontend_ips = {
    pip-existing = {
      create_public_ip         = false
      public_ip_name           = ""
      public_ip_resource_group = ""
      rules = {
        HTTP = {
          port         = 80
          protocol     = "Tcp"
          backend_name = "backend1_name"
        }
      }
    }
  }

  # Private loadbalancer exmple
  frontend_ips = {
    internal_fe = {
      subnet_id                     = ""
      private_ip_address_allocation = "Static" // Dynamic or Static
      private_ip_address = ""
      rules = {
        HA_PORTS = {
          port         = 0
          protocol     = "All"
          backend_name = "backend3_name"
        }
      }
    }
  }
  ```
  EOF
}

#  ---   #
# Naming #
#  ---   #

variable "resource_group_name" {
  description = "Name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "Region to deploy load balancer and dependencies."
  type        = string
}

variable "name_lb" {
  description = "The loadbalancer name."
  type        = string
}

variable "name_probe" {
  description = "The loadbalancer probe name."
  type        = string
  default     = ""
}

variable "probe_port" {
  description = "Health check port definition."
  default     = "80"
  type        = string
}


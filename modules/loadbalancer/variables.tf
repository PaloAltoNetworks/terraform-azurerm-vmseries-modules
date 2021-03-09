variable "frontend_ips" {
  description = <<-EOF
  A map of objects describing LB Frontend IP configurations. Keys of the map are the names and values are { create_public_ip, public_ip_address_id, rules }. Example:

  ```
  # Deploy the inbound load balancer for traffic into the azure environment
  module "inbound-lb" {
    source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/loadbalancer"

    resource_group_name = ""
    location            = ""
    name_probe          = ""
    name_lb             = ""
    frontend_ips = {
      # Map of maps (each object has one frontend to many backend relationship) 
      pip-existing = {
        create_public_ip     = false
        public_ip_address_id = ""
        rules = {
          HTTP = {
            port         = 80
            protocol     = "Tcp"
            backend_name = "backend1_name"
          }
        }
      }
    }
  }

  # Deploy the outbound load balancer for traffic into the azure environment
  module "outbound-lb" {
    source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/loadbalancer"

    resource_group_name = ""
    location            = ""
    name_probe          = ""
    name_lb             = ""
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
  default     = ""
}

variable "name_lb" {
  description = "The loadbalancer name."
  type        = string
}

variable "name_probe" {
  description = "The loadbalancer probe name."
  type        = string
}

variable "probe_port" {
  description = "Health check port definition."
  default     = "80"
}

variable "pip_suffix" {
  description = "The suffix for new public ip naming."
  default     = "pip"
  type        = string
}

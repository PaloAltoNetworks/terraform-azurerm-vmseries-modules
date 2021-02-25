variable "frontend_ips" {
  description = <<-EOF
  A map of objects describing LB Frontend IP configurations. Keys of the map are the names and values are { create_public_ip, public_ip_address_id, rules }. Example:

  ```
  //public
  {
    pip-existing = {
      create_public_ip     = false
      public_ip_address_id = azurerm_public_ip.this.id
      rules = {
        HTTP = {
          port         = 80
          protocol     = "Tcp"
          backend_name = "backend1_name"
        }
      }
    }
    pip-create = {
      create_public_ip = true
      rules = {
        HTTPS = {
          port         = 8080
          protocol     = "Tcp"
          backend_name = "backend2_name"
        }
        SSH = {
          port         = 22
          protocol     = "Tcp"
          backend_name = "backend3_name"
        }
      }
    }
  }
  //private
  {
    internal_fe = {
      subnet_id                     = subnet.id
      private_ip_address_allocation = "Dynamic" // Dynamic or Static
      #private_ip_address = "10.0.1.6" 
      rules = {
        HA_PORTS = {
          port         = 0
          protocol     = "All"
          backend_name = "backend1_name"
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

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}

# Seperator
variable "sep" {
  default = "-"
}

variable "resource_group_name" {
  default = "lb-rg"
}

variable "location" {
  description = "Region to deploy load balancer and dependencies."
  default     = ""
}

variable "name_lb" {
  default = "lb"
}

variable "name_backend" {
  default = "lb-backend"
}

variable "name_probe" {
  default = "lb-probe"
}

variable "probe_port" {
  default = "80"
}

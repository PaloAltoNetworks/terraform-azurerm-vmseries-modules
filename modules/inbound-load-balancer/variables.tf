variable "resource_group_name" {
  description = "Name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "Region to deploy load balancer and dependencies."
  type        = string
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
  type        = string
}

variable "frontend_ips" {
  description = <<-EOF
  A map of objects describing LB Frontend IP configurations. Keys of the map are the names and values are { create_public_ip, public_ip_address_id, rules }. Example:

  ```
  {
    "pip-existing" = {
      create_public_ip     = false
      public_ip_address_id = azurerm_public_ip.this.id
      rules = {
        "balancessh" = {
          protocol = "Tcp"
          port     = 22
        }
        "balancehttp" = {
          protocol = "Tcp"
          port     = 80
        }
      }
    }
    "pip-created" = {
      create_public_ip = true
      rules = {
        "balancessh" = {
          protocol = "Tcp"
          port     = 22
        }
        "balancehttp" = {
          protocol = "Tcp"
          port     = 80
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

# Seperator
variable "sep" {
  default = "-"
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

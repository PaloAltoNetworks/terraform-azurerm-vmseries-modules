variable "location" {
  description = "Region to deploy load balancer and dependencies."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
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
        "testssh" = {
          protocol = "Tcp"
          port     = 22
        }
        "testhttp" = {
          protocol = "Tcp"
          port     = 80
        }
      }
    }
    "pip-created" = {
      create_public_ip = true
      rules = {
        "testssh" = {
          protocol = "Tcp"
          port     = 22
        }
        "testhttp" = {
          protocol = "Tcp"
          port     = 80
        }
      }
    }
  }
  ```
  EOF
  # default = {
  #   "default80" = {
  #     port     = 80
  #     protocol = "Tcp"
  #   }
  # }
}

#  ---   #
# Naming #
#  ---   #

# Seperator
variable "sep" {
  default = "-"
}

variable "name_rg" {
  default = "lb-rg"
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

provider "azurerm" {
  features {}
}

# Pubic LB
module "public_lb" {
  source = "../../modules/loadbalancer"

  name_prefix         = var.name_prefix
  name_lb             = "LB-public"
  location            = var.location
  resource_group_name = var.name_rg

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
    pip-create2 = {
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
}

#  Private LB
module "private_lb" {
  source = "../../modules/loadbalancer"

  name_prefix         = var.name_prefix
  name_lb             = "LB-private"
  location            = var.location
  resource_group_name = var.name_rg

  frontend_ips = {
    internal_fe = {
      subnet_id                     = ""
      private_ip_address_allocation = "Static" // Dynamic or Static
      private_ip_address            = "10.0.1.6"
      rules = {
        HA_PORTS = {
          port         = 0
          protocol     = "All"
          backend_name = "backend1_name"
        }
      }
    }
  }
}
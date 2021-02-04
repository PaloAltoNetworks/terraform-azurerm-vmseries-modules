provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = var.name_rg
  location = var.location
}

# Pubic LB
module "public_lb" {
  source = "../../modules/loadbalancer"

  name_prefix = var.name_prefix
  name_lb     = "LB-public"

  name_rg  = var.name_rg
  location = var.location

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
  depends_on = [azurerm_resource_group.this]
}

#  Private LB
module "private_lb" {
  source = "../../modules/loadbalancer"

  name_prefix = var.name_prefix
  name_lb     = "LB-private"

  name_rg  = var.name_rg
  location = var.location

  frontend_ips = {
    internal_fe = {
      subnet_id                     = ""
      private_ip_address_allocation = "Static" // Dynamic or Static
      private_ip_address = "10.0.1.6" 
      rules = {
        HA_PORTS = {
          port         = 0
          protocol     = "All"
          backend_name = "backend1_name"
        }
      }
    }
  }
  depends_on = [azurerm_resource_group.this]
}
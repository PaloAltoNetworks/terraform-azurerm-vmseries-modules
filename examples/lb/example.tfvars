# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "lb-refactor"
name_prefix         = "fosix-"
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}


# --- VNET PART --- #
vnets = {
  "transit" = {
    name          = "transit"
    address_space = ["10.0.0.0/25"]
    network_security_groups = {
      "public" = { name = "public" }
    }
    subnets = {
      "private" = {
        name             = "private-snet"
        address_prefixes = ["10.0.0.16/28"]
      }
      "public" = {
        name                   = "public-snet"
        address_prefixes       = ["10.0.0.32/28"]
        network_security_group = "public"
      }
    }
  }
}

load_balancers = {
  "public" = {
    name = "public-lb"
    # nsg_auto_rules_settings = {
    #   nsg_name                = "fosix-existing-nsg"
    #   nsg_resource_group_name = "fosix-lb-ips"
    #   # nsg_vnet_key  = "transit"
    #   # nsg_key       = "public"
    #   source_ips    = ["0.0.0.0/0"] # Put your own public IP address here  <-- TODO to be adjusted by the customer
    #   base_priority = 200
    # }
    zones = ["1", "2", "3"]
    frontend_ips = {
      "default_front" = {
        name = "default-public-frontend"
        # public_ip_name   = "frontend-pip"
        # create_public_ip = true
        public_ip_name           = "fosix-sourced_frontend_zonal"
        public_ip_resource_group = "fosix-lb-ips"
        in_rules = {
          "balanceHttp" = {
            name     = "HTTP"
            protocol = "Tcp"
            port     = 80
          }
        }
        out_rules = {
          default = {
            name     = "default-out"
            protocol = "All"
          }
        }
      }
    }
  }
  "private" = {
    name    = "private-lb"
    avzones = null
    frontend_ips = {
      "ha-ports" = {
        name               = "HA"
        vnet_key           = "transit"
        subnet_key         = "private"
        private_ip_address = "10.0.0.21"
        in_rules = {
          HA_PORTS = {
            name                = "HA"
            port                = 0
            protocol            = "All"
            session_persistence = "SourceIP"
            nsg_priority        = 2000
          }
        }
      }
    }
  }
}
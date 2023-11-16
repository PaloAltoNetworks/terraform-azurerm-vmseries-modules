# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "lb-refactor"
name_prefix         = "example-"
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
    nsg_auto_rules_settings = {
      # nsg_name                = "fosix-existing-nsg"
      # nsg_resource_group_name = "fosix-lb-ips"
      nsg_vnet_key  = "transit"
      nsg_key       = "public"
      source_ips    = ["10.0.0.0/8"] # Put your own public IP address here  <-- TODO to be adjusted by the customer
      base_priority = 4000
    }
    zones = ["1", "2", "3"]
    health_probes = {
      "http_default" = {
        name     = "http_default_probe"
        protocol = "Http"
      }
    }
    frontend_ips = {
      "default_front" = {
        name             = "default-public-frontend"
        public_ip_name   = "frontend-pip"
        create_public_ip = true
        in_rules = {
          "balanceHttp" = {
            name             = "HTTP"
            protocol         = "Tcp"
            port             = 80
            health_probe_key = "http_default"
          }
        }
        out_rules = {
          default = {
            name                     = "default-out"
            protocol                 = "Tcp"
            allocated_outbound_ports = 20000
            enable_tcp_reset         = true
            idle_timeout_in_minutes  = 120
          }
        }
      }
      "sourced_pip" = {
        name                     = "with-sourced-pip"
        public_ip_name           = "fosix-sourced_frontend"
        public_ip_resource_group = "fosix-lb-ips"
        zones                    = null
        in_rules = {
          "balanceHttp" = {
            name     = "HTTP-elevated"
            protocol = "Tcp"
            port     = 80
            # health_probe_key = "http_default"
          }
        }
      }
      # "private" = {
      #   name               = "private"
      #   vnet_key           = "transit"
      #   subnet_key         = "private"
      #   private_ip_address = "10.0.0.22"
      #   in_rules = {
      #     "balanceHttp" = {
      #       name             = "HA"
      #       protocol         = "Tcp"
      #       port             = 80
      #       health_probe_key = "http_default"
      #     }
      #   }
      # }
    }
  }
  "private" = {
    name  = "private-lb"
    zones = ["1"]
    frontend_ips = {
      "ha-ports" = {
        name               = "HA"
        vnet_key           = "transit"
        subnet_key         = "private"
        private_ip_address = "10.0.0.21"
        in_rules = {
          HA_PORTS = {
            name     = "HA"
            port     = 0
            protocol = "All"
          }
        }
      }
    }
  }
}
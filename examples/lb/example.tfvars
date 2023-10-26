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
    nsg_auto_rules_settings = {
      nsg_vnet_key  = "transit"
      nsg_key       = "public"
      source_ips    = ["0.0.0.0/0"]
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
      default_front = {
        name             = "default-public-frontend"
        public_ip_name   = "frontend-pip"
        create_public_ip = true
      }
      sourced_pip = {
        name                     = "with-sourced-pip"
        public_ip_name           = "fosix-sourced_frontend"
        public_ip_resource_group = "fosix-lb-ips"
      }
    }
    inbound_rules = {
      default_balanceHttp = {
        name             = "HTTP"
        frontend_ip_key  = "default_front"
        protocol         = "Tcp"
        port             = 80
        health_probe_key = "http_default"
      }
      sourced_balanceHttp = {
        name            = "HTTP_sourced"
        frontend_ip_key = "sourced_pip"
        protocol        = "Tcp"
        port            = 80

      }
    }
    outbound_rules = {
      default = {
        name                     = "default-out"
        frontend_ip_key          = "default_front"
        protocol                 = "Tcp"
        allocated_outbound_ports = 20000
        enable_tcp_reset         = true
        idle_timeout_in_minutes  = 120
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
  "private" = {
    name  = "private-lb"
    zones = ["1"]
    frontend_ips = {
      "ha-ports" = {
        name               = "HA"
        vnet_key           = "transit"
        subnet_key         = "private"
        private_ip_address = "10.0.0.21"
      }
    }
    inbound_rules = {
      HA_PORTS = {
        name            = "HA"
        frontend_ip_key = "ha-ports"
        port            = 0
        protocol        = "All"
      }
    }
  }
}
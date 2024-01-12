# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "transit-vnet-dedicated"
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
      "management" = {
        name = "mgmt-nsg"
        rules = {
          mgmt_inbound = {
            name                       = "vmseries-management-allow-inbound"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_address_prefixes    = ["134.238.135.14", "134.238.135.140"]
            source_port_range          = "*"
            destination_address_prefix = "10.0.0.0/28"
            destination_port_ranges    = ["22", "443"]
          }
        }
      }
      "public" = {
        name = "public-nsg"
      }
    }
    route_tables = {
      "management" = {
        name = "mgmt-rt"
        routes = {
          "private_blackhole" = {
            name           = "private-blackhole-udr"
            address_prefix = "10.0.0.16/28"
            next_hop_type  = "None"
          }
          "public_blackhole" = {
            name           = "public-blackhole-udr"
            address_prefix = "10.0.0.32/28"
            next_hop_type  = "None"
          }
          "appgw_blackhole" = {
            name           = "appgw-blackhole-udr"
            address_prefix = "10.0.0.48/28"
            next_hop_type  = "None"
          }
        }
      }
      "private" = {
        name = "private-rt"
        routes = {
          "default" = {
            name                = "default-udr"
            address_prefix      = "0.0.0.0/0"
            next_hop_type       = "VirtualAppliance"
            next_hop_ip_address = "10.0.0.30"
          }
          "mgmt_blackhole" = {
            name           = "mgmt-blackhole-udr"
            address_prefix = "10.0.0.0/28"
            next_hop_type  = "None"
          }
          "public_blackhole" = {
            name           = "public-blackhole-udr"
            address_prefix = "10.0.0.32/28"
            next_hop_type  = "None"
          }
          "appgw_blackhole" = {
            name           = "appgw-blackhole-udr"
            address_prefix = "10.0.0.48/28"
            next_hop_type  = "None"
          }
        }
      }
      "public" = {
        name = "public-rt"
        routes = {
          "mgmt_blackhole" = {
            name           = "mgmt-blackhole-udr"
            address_prefix = "10.0.0.0/28"
            next_hop_type  = "None"
          }
          "private_blackhole" = {
            name           = "private-blackhole-udr"
            address_prefix = "10.0.0.16/28"
            next_hop_type  = "None"
          }
        }
      }
    }
    subnets = {
      "management" = {
        name                            = "mgmt-snet"
        address_prefixes                = ["10.0.0.0/28"]
        network_security_group_key      = "management"
        route_table_key                 = "management"
        enable_storage_service_endpoint = true
      }
      "private" = {
        name             = "private-snet"
        address_prefixes = ["10.0.0.16/28"]
        route_table_key  = "private"
      }
      "public" = {
        name                       = "public-snet"
        address_prefixes           = ["10.0.0.32/28"]
        network_security_group_key = "public"
        route_table_key            = "public"
      }
      "appgw" = {
        name             = "appgw-snet"
        address_prefixes = ["10.0.0.48/28"]
      }
    }
  }
}


# --- LOAD BALANCING PART --- #
load_balancers = {
  "public" = {
    name = "public-lb"
    nsg_auto_rules_settings = {
      nsg_vnet_key = "transit"
      nsg_key      = "public"
      source_ips   = ["0.0.0.0/0"]
    }
    frontend_ips = {
      "app1" = {
        name             = "app1"
        public_ip_name   = "public-lb-app1-pip"
        create_public_ip = true
        in_rules = {
          "balanceHttp" = {
            name     = "HTTP"
            protocol = "Tcp"
            port     = 80
          }
        }
      }
    }
  }
  "private" = {
    name = "private-lb"
    frontend_ips = {
      "ha-ports" = {
        name               = "private-vmseries"
        vnet_key           = "transit"
        subnet_key         = "private"
        private_ip_address = "10.0.0.30"
        in_rules = {
          HA_PORTS = {
            name     = "HA-ports"
            port     = 0
            protocol = "All"
          }
        }
      }
    }
  }
}



# --- APPLICATION GATEWAYs --- #
appgws = {
  "public" = {
    name = "appgw"
    public_ip = {
      name = "pip"
    }
    vnet_key   = "transit"
    subnet_key = "appgw"
    zones      = ["1", "2", "3"]
    capacity = {
      static = 2
    }
    listeners = {
      minimum = {
        name = "minimum-listener"
        port = 80
      }
    }
    rewrites = {
      minimum = {
        name = "minimum-set"
        rules = {
          "xff-strip-port" = {
            name     = "minimum-xff-strip-port"
            sequence = 100
            request_headers = {
              "X-Forwarded-For" = "{var_add_x_forwarded_for_proxy}"
            }
          }
        }
      }
    }
    rules = {
      minimum = {
        name     = "minimum-rule"
        priority = 1
        backend  = "minimum"
        listener = "minimum"
        rewrite  = "minimum"
      }
    }
  }
}



# --- VMSERIES PART --- #
ngfw_metrics = {
  name = "metrics"
}

bootstrap_storages = {
  "bootstrap" = {
    name = "smplngfwbtstrp"
    storage_network_security = {
      vnet_key            = "transit"
      allowed_subnet_keys = ["management"]
      allowed_public_ips  = ["134.238.135.14", "134.238.135.140"]
    }
  }
}

vmseries = {
  "fw-in-1" = {
    name = "inbound-firewall01"
    image = {
      version = "10.2.3"
    }
    virtual_machine = {
      vnet_key = "transit"
      size     = "Standard_DS3_v2"
      zone     = 1
      bootstrap_package = {
        bootstrap_storage_key  = "bootstrap"
        static_files           = { "files/init-cfg.txt" = "config/init-cfg.txt" }
        bootstrap_xml_template = "templates/bootstrap_inbound.tmpl"
        private_snet_key       = "private"
        public_snet_key        = "public"
      }
    }
    interfaces = [
      {
        name             = "vm-in-01-mgmt"
        subnet_key       = "management"
        create_public_ip = true
      },
      {
        name       = "vm-in-01-private"
        subnet_key = "private"
      },
      {
        name              = "vm-in-01-public"
        subnet_key        = "public"
        create_public_ip  = true
        load_balancer_key = "public"
      }
    ]
  }
  "fw-in-2" = {
    name = "inbound-firewall02"
    image = {
      version = "10.2.3"
    }
    virtual_machine = {
      vnet_key = "transit"
      size     = "Standard_DS3_v2"
      zone     = 2
      bootstrap_package = {
        bootstrap_storage_key  = "bootstrap"
        static_files           = { "files/init-cfg.txt" = "config/init-cfg.txt" }
        bootstrap_xml_template = "templates/bootstrap_inbound.tmpl"
        private_snet_key       = "private"
        public_snet_key        = "public"
      }
    }
    interfaces = [
      {
        name             = "vm-in-02-mgmt"
        subnet_key       = "management"
        create_public_ip = true
      },
      {
        name       = "vm-in-02-private"
        subnet_key = "private"
      },
      {
        name              = "vm-in-02-public"
        subnet_key        = "public"
        load_balancer_key = "public"
      }
    ]
  }
  "fw-obew-1" = {
    name = "obew-firewall01"
    image = {
      version = "10.2.3"
    }
    virtual_machine = {
      vnet_key = "transit"
      size     = "Standard_DS3_v2"
      zone     = 1
      bootstrap_package = {
        bootstrap_storage_key  = "bootstrap"
        static_files           = { "files/init-cfg.txt" = "config/init-cfg.txt" }
        bootstrap_xml_template = "templates/bootstrap_obew.tmpl"
        private_snet_key       = "private"
        public_snet_key        = "public"
      }
    }
    interfaces = [
      {
        name             = "vm-obew-01-mgmt"
        subnet_key       = "management"
        create_public_ip = true
      },
      {
        name              = "vm-obew-01-private"
        subnet_key        = "private"
        load_balancer_key = "private"
      },
      {
        name             = "vm-obew-01-public"
        subnet_key       = "public"
        create_public_ip = true
      }
    ]
  }
  "fw-obew-2" = {
    name = "obew-firewall02"
    image = {
      version = "10.2.3"
    }
    virtual_machine = {
      vnet_key = "transit"
      size     = "Standard_DS3_v2"
      zone     = 2
      bootstrap_package = {
        bootstrap_storage_key  = "bootstrap"
        static_files           = { "files/init-cfg.txt" = "config/init-cfg.txt" }
        bootstrap_xml_template = "templates/bootstrap_obew.tmpl"
        private_snet_key       = "private"
        public_snet_key        = "public"
      }
    }
    interfaces = [
      {
        name             = "vm-obew-02-mgmt"
        subnet_key       = "management"
        create_public_ip = true
      },
      {
        name              = "vm-obew-02-private"
        subnet_key        = "private"
        load_balancer_key = "private"
      },
      {
        name             = "vm-obew-02-public"
        subnet_key       = "public"
        create_public_ip = true
      }
    ]
  }
}

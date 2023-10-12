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
            source_address_prefixes    = ["1.2.3.4"] # TODO: whitelist public IP addresses that will be used to manage the appliances
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
        network_security_group          = "management"
        route_table                     = "management"
        enable_storage_service_endpoint = true
      }
      "private" = {
        name             = "private-snet"
        address_prefixes = ["10.0.0.16/28"]
        route_table      = "private"
      }
      "public" = {
        name                   = "public-snet"
        address_prefixes       = ["10.0.0.32/28"]
        network_security_group = "public"
        route_table            = "public"
      }
    }
  }
}


# --- LOAD BALANCING PART --- #
load_balancers = {
  "public" = {
    name                              = "public-lb"
    nsg_vnet_key                      = "transit"
    nsg_key                           = "public"
    network_security_allow_source_ips = ["0.0.0.0/0"] # Put your own public IP address here  <-- TODO to be adjusted by the customer
    avzones                           = ["1", "2", "3"]
    frontend_ips = {
      "palo-lb-app1" = {
        create_public_ip = true
        in_rules = {
          "balanceHttp" = {
            protocol = "Tcp"
            port     = 80
          }
        }
      }
    }
  }
  "private" = {
    name    = "private-lb"
    avzones = ["1", "2", "3"]
    frontend_ips = {
      "ha-ports" = {
        vnet_key           = "transit"
        subnet_key         = "private"
        private_ip_address = "10.0.0.30"
        in_rules = {
          HA_PORTS = {
            port     = 0
            protocol = "All"
          }
        }
      }
    }
  }
}



# --- VMSERIES PART --- #

bootstrap_storage = {
  bootstrap = {
    name             = "xmplbootstrapdedicated"
    public_snet_key  = "public"
    private_snet_key = "private"
    storage_acl      = true
    intranet_cidr    = "10.100.0.0/16"
    storage_allow_vnet_subnets = {
      management = {
        vnet_key   = "transit"
        subnet_key = "management"
      }
    }
    storage_allow_inbound_public_ips = ["1.2.3.4"] # TODO: whitelist public IP addresses subnets (minimum /30 CIDR) that will be used to apply the terraform code from
  }
}

vmseries_version = "10.2.3"
vmseries_vm_size = "Standard_DS3_v2"
vmseries = {
  "fw-in-1" = {
    name                 = "inbound-firewall-01"
    add_to_appgw_backend = true
    bootstrap_storage = {
      name                   = "bootstrap"
      static_files           = { "files/init-cfg.txt" = "config/init-cfg.txt" }
      template_bootstrap_xml = "templates/bootstrap_inbound.tmpl"
    }
    vnet_key = "transit"
    avzone   = 1
    interfaces = [
      {
        name       = "mgmt"
        subnet_key = "management"
        create_pip = true
      },
      {
        name       = "private"
        subnet_key = "private"
      },
      {
        name              = "public"
        subnet_key        = "public"
        load_balancer_key = "public"
        create_pip        = true
      }
    ]
  }
  "fw-in-2" = {
    name                 = "inbound-firewall-02"
    add_to_appgw_backend = true
    bootstrap_storage = {
      name                   = "bootstrap"
      static_files           = { "files/init-cfg.txt" = "config/init-cfg.txt" }
      template_bootstrap_xml = "templates/bootstrap_inbound.tmpl"
    }
    vnet_key = "transit"
    avzone   = 2
    interfaces = [
      {
        name       = "mgmt"
        subnet_key = "management"
        create_pip = true
      },
      {
        name       = "private"
        subnet_key = "private"
      },
      {
        name              = "public"
        subnet_key        = "public"
        load_balancer_key = "public"
        create_pip        = true
      }
    ]
  }
  "fw-obew-1" = {
    name = "obew-firewall-01"
    bootstrap_storage = {
      name                   = "bootstrap"
      static_files           = { "files/init-cfg.txt" = "config/init-cfg.txt" }
      template_bootstrap_xml = "templates/bootstrap_obew.tmpl"
    }
    vnet_key = "transit"
    avzone   = 1
    interfaces = [
      {
        name       = "mgmt"
        subnet_key = "management"
        create_pip = true
      },
      {
        name              = "private"
        subnet_key        = "private"
        load_balancer_key = "private"
      },
      {
        name       = "public"
        subnet_key = "public"
        create_pip = true
      }
    ]
  }
  "fw-obew-2" = {
    name = "obew-firewall-02"
    bootstrap_storage = {
      name                   = "bootstrap"
      static_files           = { "files/init-cfg.txt" = "config/init-cfg.txt" }
      template_bootstrap_xml = "templates/bootstrap_obew.tmpl"
    }
    vnet_key = "transit"
    avzone   = 2
    interfaces = [
      {
        name       = "mgmt"
        subnet_key = "management"
        create_pip = true
      },
      {
        name              = "private"
        subnet_key        = "private"
        load_balancer_key = "private"
      },
      {
        name       = "public"
        subnet_key = "public"
        create_pip = true
      }
    ]
  }
}

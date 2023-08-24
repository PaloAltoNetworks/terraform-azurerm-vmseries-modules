# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "transit-vnet-common"
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
          vmseries_mgmt_allow_inbound = {
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
            address_prefix = "10.0.0.16/28"
            next_hop_type  = "None"
          }
          "public_blackhole" = {
            address_prefix = "10.0.0.32/28"
            next_hop_type  = "None"
          }
        }
      }
      "private" = {
        name = "private-rt"
        routes = {
          "default" = {
            address_prefix         = "0.0.0.0/0"
            next_hop_type          = "VirtualAppliance"
            next_hop_in_ip_address = "10.0.0.30"
          }
          "mgmt_blackhole" = {
            address_prefix = "10.0.0.0/28"
            next_hop_type  = "None"
          }
          "public_blackhole" = {
            address_prefix = "10.0.0.32/28"
            next_hop_type  = "None"
          }
        }
      }
      "public" = {
        name = "public-rt"
        routes = {
          "mgmt_blackhole" = {
            address_prefix = "10.0.0.0/28"
            next_hop_type  = "None"
          }
          "private_blackhole" = {
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



# # --- VMSERIES PART --- #
vmseries_version = "10.2.3"
vmseries_vm_size = "Standard_DS3_v2"
vmseries = {
  "fw-1" = {
    name              = "firewall01"
    bootstrap_options = "type=dhcp-client"
    vnet_key          = "transit"
    avzone            = 1
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
        name              = "public"
        subnet_key        = "public"
        load_balancer_key = "public"
        create_pip        = true
      }
    ]
  }
  "fw-2" = {
    name              = "firewall02"
    bootstrap_options = "type=dhcp-client"
    vnet_key          = "transit"
    avzone            = 2
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
        name              = "public"
        subnet_key        = "public"
        load_balancer_key = "public"
        create_pip        = true
      }
    ]
  }
}


# # --- APPLICATION GATEWAYs --- #
appgws = {
  "public" = {
    name                     = "public-appgw"
    vnet_key                 = "transit"
    subnet_key               = "appgw"
    zones                    = ["1", "2", "3"]
    capacity                 = 2
    vmseries_public_nic_name = "public"
    rules = {
      "minimum" = {
        priority = 1
        listener = {
          port = 80
        }
        rewrite_sets = {
          "xff-strip-port" = {
            sequence = 100
            request_headers = {
              "X-Forwarded-For" = "{var_add_x_forwarded_for_proxy}"
            }
          }
        }
      }
    }
  }
}

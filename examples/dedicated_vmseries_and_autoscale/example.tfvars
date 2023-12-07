# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "autoscale-dedicated"
name_prefix         = "example-"
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}
enable_zones = false

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

natgws = {
  "natgw" = {
    name              = "public-natgw"
    vnet_key          = "transit"
    subnet_keys       = ["public", "management"]
    create_pip        = false
    create_pip_prefix = true
    pip_prefix_length = 29
  }
}



# --- LOAD BALANCING PART --- #
load_balancers = {
  "public" = {
    name                              = "public-lb"
    nsg_vnet_key                      = "transit"
    nsg_key                           = "public"
    network_security_allow_source_ips = ["0.0.0.0/0"] # Put your own public IP address here  <-- TODO to be adjusted by the customer
    zones                             = null
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
    name  = "private-lb"
    zones = null
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
application_insights = {}

vmseries_version = "10.2.3"
vmseries_vm_size = "Standard_DS3_v2"
vmss = {
  "inbound" = {
    name              = "inbound-vmss"
    vnet_key          = "transit"
    bootstrap_options = "type=dhcp-client"

    interfaces = [
      {
        name       = "management"
        subnet_key = "management"
      },
      {
        name       = "private"
        subnet_key = "private"
      },
      {
        name                    = "public"
        subnet_key              = "public"
        load_balancer_key       = "public"
        application_gateway_key = "public"
      }
    ]

    autoscale_config = {
      count_default = 2
      count_minimum = 1
      count_maximum = 3
    }
    autoscale_metrics = {
      "DataPlaneCPUUtilizationPct" = {
        scaleout_threshold = 80
        scalein_threshold  = 20
      }
    }
    scaleout_config = {
      statistic        = "Average"
      time_aggregation = "Average"
      window_minutes   = 10
      cooldown_minutes = 30
    }
    scalein_config = {
      window_minutes   = 10
      cooldown_minutes = 300
    }
  }
  "obew" = {
    name              = "obew-vmss"
    vnet_key          = "transit"
    bootstrap_options = "type=dhcp-client"

    interfaces = [
      {
        name       = "management"
        subnet_key = "management"
      },
      {
        name              = "private"
        subnet_key        = "private"
        load_balancer_key = "private"
      },
      {
        name       = "public"
        subnet_key = "public"
      }
    ]

    autoscale_config = {
      count_default = 2
      count_minimum = 1
      count_maximum = 3
    }
    autoscale_metrics = {
      "DataPlaneCPUUtilizationPct" = {
        scaleout_threshold = 70
        scalein_threshold  = 20
      }
    }
    scaleout_config = {
      statistic        = "Average"
      time_aggregation = "Average"
      window_minutes   = 10
      cooldown_minutes = 30
    }
    scalein_config = {
      window_minutes   = 10
      cooldown_minutes = 300
    }
  }
}

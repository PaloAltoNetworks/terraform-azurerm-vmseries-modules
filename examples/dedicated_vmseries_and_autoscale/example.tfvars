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
            source_address_prefixes    = ["0.0.0.0/0"] # TODO: whitelist public IP addresses that will be used to manage the appliances
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
    name  = "public-lb"
    zones = null
    nsg_auto_rules_settings = {
      nsg_vnet_key = "transit"
      nsg_key      = "public"
      source_ips   = ["0.0.0.0/0"] # Put your own public IP address here  <-- TODO to be adjusted by the customer
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

# --- VMSERIES PART --- #
ngfw_metrics = {
  name = "ngwf-log-analytics-wrksp"
}

vm_image_configuration = {
  img_version = "10.2.4"
}

authentication = {
  disable_password_authentication = false
}

scale_sets = {
  inbound = {
    name = "inbound-vmss"
    scale_set_configuration = {
      vnet_key          = "transit"
      bootstrap_options = "type=dhcp-client"
      zones             = null
    }
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
        name              = "public"
        subnet_key        = "public"
        load_balancer_key = "public"
      }
    ]
    autoscaling_profiles = [
      {
        name          = "default_profile"
        default_count = 2
        minimum_count = 1
        maximum_count = 5
        scale_rules = [
          {
            name = "DataPlaneCPUUtilizationPct"
            scale_out_config = {
              threshold                  = 70
              grain_window_minutes       = 5
              aggregation_window_minutes = 30
              cooldown_window_minutes    = 60
            }
            scale_in_config = {
              threshold               = 40
              cooldown_window_minutes = 120
            }
          },
        ]
      },
    ]
  }
  obew = {
    name = "obew-vmss"
    scale_set_configuration = {
      vnet_key          = "transit"
      bootstrap_options = "type=dhcp-client"
      zones             = null
    }
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
    autoscaling_profiles = [
      {
        name          = "default_profile"
        default_count = 2
        minimum_count = 1
        maximum_count = 5
        scale_rules = [
          {
            name = "DataPlaneCPUUtilizationPct"
            scale_out_config = {
              threshold                  = 70
              grain_window_minutes       = 5
              aggregation_window_minutes = 30
              cooldown_window_minutes    = 60
            }
            scale_in_config = {
              threshold               = 40
              cooldown_window_minutes = 120
            }
          },
        ]
      },
    ]
  }
}

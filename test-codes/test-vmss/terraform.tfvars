# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "test-vmss"
name_prefix         = "alf-"
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}
enable_zones = true

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
            source_address_prefixes    = ["34.99.193.241"]
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
          # "appgw_blackhole" = {
          #   address_prefix = "10.0.0.48/28"
          #   next_hop_type  = "None"
          # }
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
          # "appgw_blackhole" = {
          #   address_prefix = "10.0.0.48/28"
          #   next_hop_type  = "None"
          # }
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
      # "appgw" = {
      #   name             = "appgw-snet"
      #   address_prefixes = ["10.0.0.48/28"]
      # }
    }
  }
}

# natgws = {
#   "natgw" = {
#     name              = "public-natgw"
#     vnet_key          = "transit"
#     subnet_keys       = ["public", "management"]
#     create_pip        = false
#     create_pip_prefix = true
#     pip_prefix_length = 29
#   }
# }



# --- LOAD BALANCING PART --- #
load_balancers = {
  "public" = {
    name                        = "public-lb"
    network_security_group_name = "alf-public-nsg"
    network_security_allow_source_ips = [
      #  "x.x.x.x", # Put your own public IP address here  <-- TODO to be adjusted by the customer
      "0.0.0.0/0",
    ]
    frontend_ips = {
      "palo-lb-app1-pip" = {
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
    name = "private-lb"
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

# appgws = {
#   "public" = {
#     name       = "public-appgw"
#     vnet_key   = "transit"
#     subnet_key = "appgw"
#     capacity   = 2
#     rules = {
#       "minimum" = {
#         priority = 1
#         listener = {
#           port = 80
#         }
#         rewrite_sets = {
#           "xff-strip-port" = {
#             sequence = 100
#             request_headers = {
#               "X-Forwarded-For" = "{var_add_x_forwarded_for_proxy}"
#             }
#           }
#         }
#       }
#     }
#   }
# }



# --- VMSERIES PART --- #
application_insights = {}

vmseries_version = "10.2.3"
vmseries_vm_size = "Standard_DS3_v2"
vmss = {
  "inbound" = {
    name              = "inbound-vmss"
    vnet_key          = "transit"
    bootstrap_options = "type=dhcp"

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
        # application_gateway_key = "public"
      }
    ]

    # default_autoscale_profile = {
    # }

    # TODO convert to list of objects with name element, maps are not ordered!
    autoscale_profiles = [
      {
        name = "my-default"
        autoscale_count_default = 2
        autoscale_count_minimum = 1
        autoscale_count_maximum = 3

        autoscale_metrics = {
          "DataPlaneCPUUtilizationPct" = {
            scaleout_threshold = 80
            scalein_threshold  = 20

            # scaleout_window = "PT10M"
            # scaleout_cooldown = "PT30M"
            # scalein_window = "PT10M"
            # scalein_cooldown = "PT5H"
            scaleout_window_minutes   = 10
            scaleout_cooldown_minutes = 30
            scalein_window_minutes   = 10
            scalein_cooldown_minutes = 300
            statistic        = "Average"
            time_aggregation = "Average"
          }
        }

        # schedule = {
        #   timezone = "Pacific Standard Time"
        #   days     = ["Saturday", "Sunday"]
        #   # time = "12:00"  # TODO 24h format
        #   hours    = [13]
        #   minutes  = [0]
        # }
      },
      {
        name = "other-profile"
        autoscale_count_default = 2
        autoscale_count_minimum = 1
        autoscale_count_maximum = 4

        autoscale_metrics = {
          "DataPlaneCPUUtilizationPct" = {
            scaleout_threshold = 70
            scalein_threshold  = 30

            # scaleout_window = "PT20M"
            # scaleout_cooldown = "PT40M"
            # scalein_window = "PT20M"
            # scalein_cooldown = "PT40M"
            scaleout_window_minutes   = 20
            scaleout_cooldown_minutes = 40
            scalein_window_minutes   = 20
            scalein_cooldown_minutes = 40
            statistic        = "Average"
            time_aggregation = "Average"
          }
        }


        schedule = {            # start and end time must be given
          timezone = "Pacific Standard Time"
          days     = ["Saturday", "Sunday"]
          # time = "12:00"  # TODO 24h format
          hours    = [12]
          minutes  = [0]
          end_hours = [12]
          end_minutes = [59]
        }
      },
      {
        name = "3rd-profile"
        autoscale_count_default = 2
        autoscale_count_minimum = 1
        autoscale_count_maximum = 4

        schedule = {            # start and end time must be given
          timezone = "Pacific Standard Time"
          days     = ["Saturday", "Sunday"]
          # time = "12:00"  # TODO 24h format
          hours    = [13]
          minutes  = [0]
          end_hours = [14]
          end_minutes = [0]
        }
      }
    ]

  }
  # "obew" = {
  #   name              = "obew-vmss"
  #   vnet_key          = "transit"
  #   bootstrap_options = "type=dhcp"

  #   interfaces = [
  #     {
  #       name       = "management"
  #       subnet_key = "management"
  #     },
  #     {
  #       name              = "private"
  #       subnet_key        = "private"
  #       load_balancer_key = "private"
  #     },
  #     {
  #       name       = "public"
  #       subnet_key = "public"
  #     }
  #   ]


  #   # autoscale_config = {
  #   #   count_default = 2
  #   #   count_minimum = 1
  #   #   count_maximum = 3
  #   # }
  #   # autoscale_metrics = {
  #   #   "DataPlaneCPUUtilizationPct" = {
  #   #     scaleout_threshold = 70
  #   #     scalein_threshold  = 20
  #   #   }
  #   # }
  #   # scaleout_config = {
  #   #   statistic        = "Average"
  #   #   time_aggregation = "Average"
  #   #   window_minutes   = 10
  #   #   cooldown_minutes = 30
  #   # }
  #   # scalein_config = {
  #   #   window_minutes   = 10
  #   #   cooldown_minutes = 300
  #   # }
  # }
}

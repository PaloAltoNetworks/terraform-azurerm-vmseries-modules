# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "vmss-refactoring"
name_prefix         = "fosix-"
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}


# --- VNET PART --- #
vnets = {
  vmss = {
    name          = "vmss-vnet"
    address_space = ["10.0.0.0/24"]
    network_security_groups = {
      mgmt = {
        name = "management"
        rules = {
          mgmt = {
            name                       = "management-allow"
            destination_address_prefix = "10.0.0.0/25"
            destination_port_ranges    = ["22", "443"]
            source_address_prefixes    = ["134.238.135.14", "134.238.135.140"]
            source_port_range          = "*"
            access                     = "Allow"
            direction                  = "Inbound"
            protocol                   = "Tcp"
            priority                   = 100
          }
        }
      }
    }
    subnets = {
      "vmss" = {
        name                       = "vmss-snet"
        address_prefixes           = ["10.0.0.0/25"]
        network_security_group_key = "mgmt"
      }
    }
  }
}

ngfw_metrics = {
  name                      = "ngwf-log-analytics-wrksp"
  metrics_retention_in_days = 120
}

vm_image_configuration = {
  img_version = "10.2.4"
}

authentication = {
  disable_password_authentication = false
}

scale_sets = {
  vmss = {
    name = "vmss"
    interfaces = [
      {
        name             = "management"
        vnet_key         = "vmss"
        subnet_key       = "vmss"
        create_public_ip = true
      }
    ]
    autoscaling_profiles = [
      {
        name          = "default_profile"
        default_count = 2
        minimum_count = 2
        maximum_count = 4
        scale_rules = [
          {
            name = "DataPlaneCPUUtilizationPct"
            # name = "Percentage CPU"
            scale_out_config = {
              threshold                  = 85
              grain_window_minutes       = 1
              aggregation_window_minutes = 25
              cooldown_window_minutes    = 60
            }
            scale_in_config = {
              threshold               = 60
              cooldown_window_minutes = 120
            }
          }
        ]
      },
      {
        name          = "overlapping profile"
        default_count = 5
        recurrence = {
          days       = ["Friday"]
          start_time = "10:30"
          end_time   = "14:00"
        }
      },
      {
        name          = "weekday_profile"
        default_count = 2
        minimum_count = 2
        maximum_count = 10
        recurrence = {
          days       = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
          start_time = "7:30"
          end_time   = "17:00"
        }
        scale_rules = [
          {
            name = "Percentage CPU"
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
          {
            name = "Outbound Flows"
            scale_out_config = {
              threshold                  = 500
              grain_window_minutes       = 5
              aggregation_window_minutes = 30
              cooldown_window_minutes    = 60
            }
            scale_in_config = {
              threshold               = 400
              cooldown_window_minutes = 60
            }
          }
        ]
      },
    ]
  }
  outbound = {
    name = "outbound"
    interfaces = [
      {
        name             = "management"
        vnet_key         = "vmss"
        subnet_key       = "vmss"
        create_public_ip = true
      }
    ]
    autoscaling_profiles = [
      {
        name          = "default_profile"
        default_count = 2
        minimum_count = 2
        maximum_count = 4
        scale_rules = [
          {
            name = "DataPlaneCPUUtilizationPct"
            # name = "Percentage CPU"
            scale_out_config = {
              threshold                  = 85
              grain_window_minutes       = 1
              aggregation_window_minutes = 25
              cooldown_window_minutes    = 60
            }
            scale_in_config = {
              threshold               = 60
              cooldown_window_minutes = 120
            }
          }
        ]
      },
    ]
  }
}

# validations
# - minimum, maximum count required when scale_rules != []
# - operator in list of valid chars
# - days is a valid list of days
# - start time, end time are valid hours
# - maximum number of rules and profiles not exceeded 

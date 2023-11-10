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
    subnets = {
      "vmss" = {
        name             = "vmss-snet"
        address_prefixes = ["10.0.0.0/25"]
      }
    }
  }
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
            name = "Percentage CPU"
            scale_out_config = {
              grain_window_minutes       = 1 #TODO: check if this is even adjustable
              aggregation_window_minutes = 25
              cooldown_window_minutes    = 60
              threshold                  = 85
            }
            scale_in_config = {
              grain_window_minutes       = 1
              aggregation_window_minutes = 30
              cooldown_window_minutes    = 120
              threshold                  = 60
            }
          }
        ]
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
              grain_window_minutes       = 5
              operator                   = ">"
              aggregation_window_minutes = 30
              cooldown_window_minutes    = 60
              threshold                  = 70
            }
            scale_in_config = {
              grain_window_minutes       = 5
              aggregation_window_minutes = 30
              cooldown_window_minutes    = 120
              threshold                  = 40
            }
          },
          {
            name = "Outbound Flows"
            scale_out_config = {
              grain_window_minutes       = 5
              operator                   = ">"
              aggregation_window_minutes = 30
              cooldown_window_minutes    = 60
              threshold                  = 500
            }
            scale_in_config = {
              grain_window_minutes       = 5
              aggregation_window_minutes = 30
              cooldown_window_minutes    = 60
              threshold                  = 400
            }
          }
        ]
      }
    ]
  }
}
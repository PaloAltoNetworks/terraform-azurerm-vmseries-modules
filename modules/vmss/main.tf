locals {
  operator = {
    ">"  = "GreaterThan"
    ">=" = "GreaterThanOrEqual"
    "<"  = "LessThan"
    "<=" = "LessThanOrEqual"
    "==" = "Equals"
    "!=" = "NotEquals"
  }
  password = sensitive(var.authentication.password)
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set
resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                 = var.name
  computer_name_prefix = null
  location             = var.location
  resource_group_name  = var.resource_group_name

  admin_username                  = var.authentication.username
  admin_password                  = var.authentication.disable_password_authentication ? null : local.password
  disable_password_authentication = var.authentication.disable_password_authentication

  dynamic "admin_ssh_key" {
    for_each = { for v in var.authentication.ssh_keys : v => v }
    content {
      username   = var.authentication.username
      public_key = admin_ssh_key.value
    }
  }

  encryption_at_host_enabled   = var.scale_set_configuration.encryption_at_host_enabled
  overprovision                = var.scale_set_configuration.overprovision
  platform_fault_domain_count  = var.scale_set_configuration.platform_fault_domain_count
  proximity_placement_group_id = var.scale_set_configuration.proximity_placement_group_id
  single_placement_group       = var.scale_set_configuration.single_placement_group
  sku                          = var.scale_set_configuration.vm_size
  zones                        = var.scale_set_configuration.zones
  zone_balance                 = length(coalesce(var.scale_set_configuration.zones, [])) > 0
  provision_vm_agent           = false

  dynamic "plan" {
    for_each = var.vm_image_configuration.enable_marketplace_plan ? ["one"] : []
    content {
      name      = var.vm_image_configuration.img_sku
      publisher = var.vm_image_configuration.img_publisher
      product   = var.vm_image_configuration.img_offer
    }
  }

  source_image_reference {
    publisher = var.vm_image_configuration.custom_image_id == null ? var.vm_image_configuration.img_publisher : null
    offer     = var.vm_image_configuration.custom_image_id == null ? var.vm_image_configuration.img_offer : null
    sku       = var.vm_image_configuration.custom_image_id == null ? var.vm_image_configuration.img_sku : null
    version   = var.vm_image_configuration.img_version
  }

  source_image_id = var.vm_image_configuration.custom_image_id
  os_disk {
    caching                = "ReadWrite"
    disk_encryption_set_id = var.scale_set_configuration.disk_encryption_set_id #  The Disk Encryption Set must have the Reader Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault.
    storage_account_type   = var.scale_set_configuration.storage_account_type
  }


  instances = var.autoscaling_configuration.default_count

  upgrade_mode = "Manual" # See README for more details no this setting.

  custom_data = var.scale_set_configuration.bootstrap_options == null ? null : base64encode(var.scale_set_configuration.bootstrap_options)

  scale_in {
    rule                   = var.autoscaling_configuration.scale_in_policy
    force_deletion_enabled = var.autoscaling_configuration.scale_in_force_deletion
  }

  dynamic "network_interface" {
    for_each = var.interfaces
    iterator = nic

    content {
      name                          = nic.value.name
      primary                       = nic.key == 0 ? true : false
      enable_ip_forwarding          = nic.key == 0 ? false : true
      enable_accelerated_networking = nic.key == 0 ? false : var.scale_set_configuration.accelerated_networking

      ip_configuration {
        name                                         = "primary"
        primary                                      = true
        subnet_id                                    = nic.value.subnet_id
        load_balancer_backend_address_pool_ids       = nic.value.lb_backend_pool_ids
        application_gateway_backend_address_pool_ids = nic.value.appgw_backend_pool_ids

        dynamic "public_ip_address" {
          for_each = nic.value.create_public_ip ? ["one"] : []
          iterator = pip

          content {
            name              = "${nic.value.name}-public-ip"
            domain_name_label = nic.value.pip_domain_name_label
          }
        }
      }
    }
  }

  boot_diagnostics { storage_account_uri = var.scale_set_configuration.diagnostics_storage_uri }

  identity { type = "SystemAssigned" } # (Required) The type of Managed Identity which should be assigned to the Linux Virtual Machine Scale Set. Possible values are SystemAssigned, UserAssigned and SystemAssigned, UserAssigned.

  tags = var.tags
}

locals {
  # this loop will pull out all `window_minutes`-like properties from the scaling rules
  # into one map that can be fed into the `pdt_time` module
  profile_time_windows_flat = flatten([
    for profile in var.autoscaling_profiles : [
      for rule in profile.scale_rules : [
        [
          for k, v in rule.scale_out_config :
          {
            name  = "${profile.name}-${replace(lower(rule.name), " ", "_")}-scale_out-${k}"
            value = v
          }
          if strcontains(k, "window_minutes")
        ],
        [
          for k, v in rule.scale_in_config :
          {
            name  = "${profile.name}-${replace(lower(rule.name), " ", "_")}-scale_in-${k}"
            value = v
          }
          if strcontains(k, "window_minutes") && v != null
        ]
      ]
    ]
  ])
  profile_time_windows = { for v in local.profile_time_windows_flat : v.name => v.value }
}

module "ptd_time" {
  source   = "./dt_string_converter"
  for_each = local.profile_time_windows
  time     = each.value
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting
resource "azurerm_monitor_autoscale_setting" "this" {
  count = length(var.autoscaling_profiles) > 0 ? 1 : 0

  name                = "${var.name}-autoscale-settings"
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.this.id

  # the default profile or (when more then one) the profiles representing start times

  # This code covers the Microsoft logic for creating multiple autoscaling profiles.
  # From the variables point of view, the definition tries to mimic the Azure Portal interface.
  # When defining 2 and more profiles, for the 2nd and latter are specifying start and end time (in HH:MM format).
  # From the code/ARM point of view, there is nothing like end time for a profile. Instead of that the 1st (default)
  # profile is being duplicated with the start time equal to the end time of a particular profile.

  # Example. We have 3 profiles (let's skip the days part when configuring a profile window as it is not used in the logic):
  #   - profile1 - the 1st one, default
  #   - profile2 - starts at 7:00 ends at 17:00
  #   - profile3 - start at 21:00 end at 22:30
  # In this case `profile1` will never be created explicitly. Instead of that we will get 4 profiles, like the following:
  #   - vmss_profile_1 - starts at 7:00, contains configuration of `profile2`
  #   - vmss_profile_2 - starts at 21:00, contains configuration of `profile3`
  #   - vmss_profile_3 - starts at 17:00, contains configuration of `profile1`
  #   - vmss_profile_4 - starts at 22:30, contains configuration of `profile1`
  # `vmss_profile_1` and `vmss_profile_2` will have names of `profile2` and `profile3` respectively.
  # `vmss_profile_3` and `vmss_profile_4` will have auto-calculated names in the following format:
  #     `name:profile1,for:profile#`, where `profile#` will be `profile3` and `profile4` respectively.

  # Therefore, in the code below you have two dynamic `profile` blocks. The 1st one is defining the profiles with the
  # starting time.
  # The 2nd block is being run only when you have more than one profile and defines the closing profiles,
  # so the ones with the end time.

  dynamic "profile" {
    # for_each = length(var.autoscaling_profiles) == 1 ? var.autoscaling_profiles : slice(var.autoscaling_profiles, 1, length(var.autoscaling_profiles))
    for_each = slice(var.autoscaling_profiles, length(var.autoscaling_profiles) == 1 ? 0 : 1, length(var.autoscaling_profiles))
    content {
      name = profile.value.name

      capacity {
        default = profile.value.default_count
        minimum = coalesce(profile.value.minimum_count, profile.value.default_count)
        maximum = coalesce(profile.value.maximum_count, profile.value.default_count)
      }

      dynamic "recurrence" {
        for_each = profile.value.recurrence != null ? [1] : []
        content {
          days     = profile.value.recurrence.days
          hours    = [split(":", profile.value.recurrence.start_time)[0]]
          minutes  = [split(":", profile.value.recurrence.start_time)[1]]
          timezone = profile.value.recurrence.timezone
        }
      }

      # scale out rule portion
      dynamic "rule" {
        for_each = profile.value.scale_rules
        content {
          metric_trigger {
            metric_name = rule.value.name
            metric_resource_id = contains(
              [
                "DataPlanePacketBufferUtilization",
                "panSessionThroughputPps",
                "panSessionThroughputKbps",
                "panSessionActive",
                "panSessionUtilization",
                "DataPlaneCPUUtilizationPct"
              ],
              rule.value.name
            ) ? var.autoscaling_configuration.application_insights_id : azurerm_linux_virtual_machine_scale_set.this.id
            metric_namespace = contains(
              [
                "DataPlanePacketBufferUtilization",
                "panSessionThroughputPps",
                "panSessionThroughputKbps",
                "panSessionActive",
                "panSessionUtilization",
                "DataPlaneCPUUtilizationPct"
              ],
              rule.value.name
            ) ? "Azure.ApplicationInsights" : "microsoft.compute/virtualmachinescalesets"
            operator = local.operator[rule.value.scale_out_config.operator]

            threshold        = rule.value.scale_out_config.threshold
            statistic        = rule.value.scale_out_config.grain_aggregation_type
            time_aggregation = rule.value.scale_out_config.aggregation_window_type
            time_grain       = module.ptd_time["${profile.value.name}-${replace(lower(rule.value.name), " ", "_")}-scale_out-grain_window_minutes"].dt_string
            time_window      = module.ptd_time["${profile.value.name}-${replace(lower(rule.value.name), " ", "_")}-scale_out-aggregation_window_minutes"].dt_string
          }

          scale_action {
            direction = "Increase"
            value     = rule.value.scale_out_config.change_count_by
            type      = "ChangeCount"
            cooldown  = module.ptd_time["${profile.value.name}-${replace(lower(rule.value.name), " ", "_")}-scale_out-cooldown_window_minutes"].dt_string
          }
        }
      }

      # scale in rule portion
      dynamic "rule" {
        for_each = profile.value.scale_rules
        content {
          metric_trigger {
            metric_name = rule.value.name
            metric_resource_id = contains(
              [
                "DataPlanePacketBufferUtilization",
                "panSessionThroughputPps",
                "panSessionThroughputKbps",
                "panSessionActive",
                "panSessionUtilization",
                "DataPlaneCPUUtilizationPct"
              ],
              rule.value.name
            ) ? var.autoscaling_configuration.application_insights_id : azurerm_linux_virtual_machine_scale_set.this.id
            metric_namespace = contains(
              [
                "DataPlanePacketBufferUtilization",
                "panSessionThroughputPps",
                "panSessionThroughputKbps",
                "panSessionActive",
                "panSessionUtilization",
                "DataPlaneCPUUtilizationPct"
              ],
              rule.value.name
            ) ? "Azure.ApplicationInsights" : "microsoft.compute/virtualmachinescalesets"
            operator = local.operator[rule.value.scale_in_config.operator]

            threshold        = rule.value.scale_in_config.threshold
            statistic        = rule.value.scale_in_config.grain_aggregation_type
            time_aggregation = rule.value.scale_in_config.aggregation_window_type
            time_grain = try(
              module.ptd_time["${profile.value.name}-${replace(lower(rule.value.name), " ", "_")}-scale_in-grain_window_minutes"].dt_string,
              module.ptd_time["${profile.value.name}-${replace(lower(rule.value.name), " ", "_")}-scale_out-grain_window_minutes"].dt_string
            )
            time_window = try(
              module.ptd_time["${profile.value.name}-${replace(lower(rule.value.name), " ", "_")}-scale_in-aggregation_window_minutes"].dt_string,
              module.ptd_time["${profile.value.name}-${replace(lower(rule.value.name), " ", "_")}-scale_out-aggregation_window_minutes"].dt_string
            )
          }

          scale_action {
            direction = "Decrease"
            value     = rule.value.scale_in_config.change_count_by
            type      = "ChangeCount"
            cooldown  = module.ptd_time["${profile.value.name}-${replace(lower(rule.value.name), " ", "_")}-scale_in-cooldown_window_minutes"].dt_string
          }
        }
      }
    }
  }

  # for more than one profile, these are the profiles representing end times
  dynamic "profile" {
    # for_each = length(var.autoscaling_profiles) == 1 ? var.autoscaling_profiles : slice(var.autoscaling_profiles, 1, length(var.autoscaling_profiles))
    for_each = [for index, profile in var.autoscaling_profiles : profile if index != 0]
    content {
      name = "{\"name\":\"${var.autoscaling_profiles[0].name}\",\"for\":\"${profile.value.name}\"}"

      capacity {
        default = var.autoscaling_profiles[0].default_count
        minimum = coalesce(var.autoscaling_profiles[0].minimum_count, var.autoscaling_profiles[0].default_count)
        maximum = coalesce(var.autoscaling_profiles[0].maximum_count, var.autoscaling_profiles[0].default_count)
      }

      dynamic "recurrence" {
        for_each = profile.value.recurrence != null ? [1] : []
        content {
          days     = profile.value.recurrence.days
          hours    = [split(":", profile.value.recurrence.end_time)[0]]
          minutes  = [split(":", profile.value.recurrence.end_time)[1]]
          timezone = profile.value.recurrence.timezone
        }
      }

      # scale out rule portion
      dynamic "rule" {
        for_each = var.autoscaling_profiles[0].scale_rules
        content {
          metric_trigger {
            metric_name = rule.value.name
            metric_resource_id = contains(
              [
                "DataPlanePacketBufferUtilization",
                "panSessionThroughputPps",
                "panSessionThroughputKbps",
                "panSessionActive",
                "panSessionUtilization",
                "DataPlaneCPUUtilizationPct"
              ],
              rule.value.name
            ) ? var.autoscaling_configuration.application_insights_id : azurerm_linux_virtual_machine_scale_set.this.id
            metric_namespace = contains(
              [
                "DataPlanePacketBufferUtilization",
                "panSessionThroughputPps",
                "panSessionThroughputKbps",
                "panSessionActive",
                "panSessionUtilization",
                "DataPlaneCPUUtilizationPct"
              ],
              rule.value.name
            ) ? "Azure.ApplicationInsights" : "microsoft.compute/virtualmachinescalesets"
            operator = local.operator[rule.value.scale_out_config.operator]

            threshold        = rule.value.scale_out_config.threshold
            statistic        = rule.value.scale_out_config.grain_aggregation_type
            time_aggregation = rule.value.scale_out_config.aggregation_window_type
            time_grain       = module.ptd_time["${var.autoscaling_profiles[0].name}-${replace(lower(rule.value.name), " ", "_")}-scale_out-grain_window_minutes"].dt_string
            time_window      = module.ptd_time["${var.autoscaling_profiles[0].name}-${replace(lower(rule.value.name), " ", "_")}-scale_out-aggregation_window_minutes"].dt_string
          }

          scale_action {
            direction = "Increase"
            value     = rule.value.scale_out_config.change_count_by
            type      = "ChangeCount"
            cooldown  = module.ptd_time["${var.autoscaling_profiles[0].name}-${replace(lower(rule.value.name), " ", "_")}-scale_out-cooldown_window_minutes"].dt_string
          }
        }
      }

      # scale in rule portion
      dynamic "rule" {
        for_each = var.autoscaling_profiles[0].scale_rules
        content {
          metric_trigger {
            metric_name = rule.value.name
            metric_resource_id = contains(
              [
                "DataPlanePacketBufferUtilization",
                "panSessionThroughputPps",
                "panSessionThroughputKbps",
                "panSessionActive",
                "panSessionUtilization",
                "DataPlaneCPUUtilizationPct"
              ],
              rule.value.name
            ) ? var.autoscaling_configuration.application_insights_id : azurerm_linux_virtual_machine_scale_set.this.id
            metric_namespace = contains(
              [
                "DataPlanePacketBufferUtilization",
                "panSessionThroughputPps",
                "panSessionThroughputKbps",
                "panSessionActive",
                "panSessionUtilization",
                "DataPlaneCPUUtilizationPct"
              ],
              rule.value.name
            ) ? "Azure.ApplicationInsights" : "microsoft.compute/virtualmachinescalesets"
            operator = local.operator[rule.value.scale_in_config.operator]

            threshold        = rule.value.scale_in_config.threshold
            statistic        = rule.value.scale_in_config.grain_aggregation_type
            time_aggregation = rule.value.scale_in_config.aggregation_window_type
            time_grain = try(
              module.ptd_time["${var.autoscaling_profiles[0].name}-${replace(lower(rule.value.name), " ", "_")}-scale_in-grain_window_minutes"].dt_string,
              module.ptd_time["${var.autoscaling_profiles[0].name}-${replace(lower(rule.value.name), " ", "_")}-scale_out-grain_window_minutes"].dt_string
            )
            time_window = try(
              module.ptd_time["${var.autoscaling_profiles[0].name}-${replace(lower(rule.value.name), " ", "_")}-scale_in-aggregation_window_minutes"].dt_string,
              module.ptd_time["${var.autoscaling_profiles[0].name}-${replace(lower(rule.value.name), " ", "_")}-scale_out-aggregation_window_minutes"].dt_string
            )
          }

          scale_action {
            direction = "Decrease"
            value     = rule.value.scale_in_config.change_count_by
            type      = "ChangeCount"
            cooldown  = module.ptd_time["${var.autoscaling_profiles[0].name}-${replace(lower(rule.value.name), " ", "_")}-scale_in-cooldown_window_minutes"].dt_string
          }
        }
      }

    }

  }
  notification {
    email { custom_emails = var.autoscaling_configuration.notification_emails }
    dynamic "webhook" {
      for_each = var.autoscaling_configuration.webhooks_uris
      content { service_uri = webhook.value }
    }
  }

  tags = var.tags
}

# TODO: write the time_calculator module properly + a REDME and name it correctly
resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                 = var.name
  computer_name_prefix = null
  location             = var.location
  resource_group_name  = var.resource_group_name

  admin_username                  = var.authentication.username
  admin_password                  = var.authentication.disable_password_authentication ? null : var.authentication.password
  disable_password_authentication = var.authentication.disable_password_authentication

  dynamic "admin_ssh_key" {
    for_each = var.authentication.ssh_keys
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
  zone_balance                 = var.scale_set_configuration.zone_balance
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


  instances = var.autoscaling_configuration.autoscale_count_default

  upgrade_mode = "Manual" # See README for more details no this setting.

  custom_data = base64encode(var.bootstrap_options)

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


  boot_diagnostics {
    storage_account_uri = var.diagnostics_storage_uri
  }

  identity {
    type = "SystemAssigned" # (Required) The type of Managed Identity which should be assigned to the Linux Virtual Machine Scale Set. Possible values are SystemAssigned, UserAssigned and SystemAssigned, UserAssigned.
  }





  tags = var.tags

}

resource "azurerm_monitor_autoscale_setting" "this" {
  count = length(var.autoscale_metrics) > 0 ? 1 : 0

  name                = "${var.name}-autoscale"
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.this.id

  profile {
    name = "autoscale profile"

    capacity {
      default = var.autoscaling_configuration.autoscale_count_default
      minimum = var.autoscale_count_minimum
      maximum = var.autoscale_count_maximum
    }

    dynamic "rule" {
      for_each = var.autoscale_metrics

      content {
        metric_trigger {
          metric_name        = rule.key
          metric_resource_id = rule.key == "Percentage CPU" ? azurerm_linux_virtual_machine_scale_set.this.id : var.autoscaling_configuration.application_insights_id
          metric_namespace   = "Azure.ApplicationInsights"
          operator           = "GreaterThanOrEqual"
          threshold          = rule.value.scaleout_threshold

          statistic        = var.scaleout_statistic
          time_aggregation = var.scaleout_time_aggregation
          time_grain       = "PT1M" # PT1M means: Period of Time 1 Minute
          time_window      = local.scaleout_window
        }

        scale_action {
          direction = "Increase"
          value     = "1"
          type      = "ChangeCount"
          cooldown  = local.scaleout_cooldown
        }
      }
    }

    dynamic "rule" {
      for_each = var.autoscale_metrics

      content {
        metric_trigger {
          metric_name        = rule.key
          metric_resource_id = rule.key == "Percentage CPU" ? azurerm_linux_virtual_machine_scale_set.this.id : var.autoscaling_configuration.application_insights_id
          metric_namespace   = "Azure.ApplicationInsights"
          operator           = "LessThanOrEqual"
          threshold          = rule.value.scalein_threshold

          statistic        = var.scalein_statistic
          time_aggregation = var.scalein_time_aggregation
          time_grain       = "PT1M"
          time_window      = local.scalein_window
        }

        scale_action {
          direction = "Decrease"
          value     = "1"
          type      = "ChangeCount"
          cooldown  = local.scalein_cooldown
        }
      }
    }
  }

  notification {
    email {
      custom_emails = var.autoscaling_configuration.autoscale_notification_emails
    }
    dynamic "webhook" {
      for_each = var.autoscaling_configuration.autoscale_webhooks_uris

      content {
        service_uri = webhook.value
      }
    }
  }

  tags = var.tags
}

locals {
  # Azure demands Period of Time 1 day 12 hours and 30 minutes to be written as "P1DT12H30M".
  # Note the "T", which we insert only if there are non-zero hours/minutes.
  # What's worse, time periods "PT61M" and "PT1H1M" are equal for Azure, so Azure corrects them, but they are
  # considered inequal inside the `terraform plan`.
  # Using solely the number of minutes ("PT61M") causes a bad Terraform apply loop. The same happens for any string
  # that Azure decides to correct for us.
  scaleout_cooldown_minutes = "${var.scaleout_cooldown_minutes % 60}M"
  scaleout_cooldown_hours   = "${floor(var.scaleout_cooldown_minutes / 60) % 24}H"
  scaleout_cooldown_days    = "${floor(var.scaleout_cooldown_minutes / (60 * 24))}D"
  scaleout_cooldown_t       = "T${local.scaleout_cooldown_hours != "0H" ? local.scaleout_cooldown_hours : ""}${local.scaleout_cooldown_minutes != "0M" ? local.scaleout_cooldown_minutes : ""}"
  scaleout_cooldown         = "P${local.scaleout_cooldown_days != "0D" ? local.scaleout_cooldown_days : ""}${local.scaleout_cooldown_t != "T" ? local.scaleout_cooldown_t : ""}"

  scaleout_window_minutes = "${var.scaleout_window_minutes % 60}M"
  scaleout_window_hours   = "${floor(var.scaleout_window_minutes / 60) % 24}H"
  scaleout_window_days    = "${floor(var.scaleout_window_minutes / (60 * 24))}D"
  scaleout_window_t       = "T${local.scaleout_window_hours != "0H" ? local.scaleout_window_hours : ""}${local.scaleout_window_minutes != "0M" ? local.scaleout_window_minutes : ""}"
  scaleout_window         = "P${local.scaleout_window_days != "0D" ? local.scaleout_window_days : ""}${local.scaleout_window_t != "T" ? local.scaleout_window_t : ""}"

  scalein_cooldown_minutes = "${var.scalein_cooldown_minutes % 60}M"
  scalein_cooldown_hours   = "${floor(var.scalein_cooldown_minutes / 60) % 24}H"
  scalein_cooldown_days    = "${floor(var.scalein_cooldown_minutes / (60 * 24))}D"
  scalein_cooldown_t       = "T${local.scalein_cooldown_hours != "0H" ? local.scalein_cooldown_hours : ""}${local.scalein_cooldown_minutes != "0M" ? local.scalein_cooldown_minutes : ""}"
  scalein_cooldown         = "P${local.scalein_cooldown_days != "0D" ? local.scalein_cooldown_days : ""}${local.scalein_cooldown_t != "T" ? local.scalein_cooldown_t : ""}"

  scalein_window_minutes = "${var.scalein_window_minutes % 60}M"
  scalein_window_hours   = "${floor(var.scalein_window_minutes / 60) % 24}H"
  scalein_window_days    = "${floor(var.scalein_window_minutes / (60 * 24))}D"
  scalein_window_t       = "T${local.scalein_window_hours != "0H" ? local.scalein_window_hours : ""}${local.scalein_window_minutes != "0M" ? local.scalein_window_minutes : ""}"
  scalein_window         = "P${local.scalein_window_days != "0D" ? local.scalein_window_days : ""}${local.scalein_window_t != "T" ? local.scalein_window_t : ""}"


}

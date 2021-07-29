resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                            = "${var.name_prefix}${var.name_scale_set}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  admin_username                  = var.username
  admin_password                  = var.disable_password_authentication ? null : var.password
  disable_password_authentication = var.disable_password_authentication
  encryption_at_host_enabled      = var.encryption_at_host_enabled
  health_probe_id                 = var.health_probe_id
  overprovision                   = var.overprovision
  platform_fault_domain_count     = var.platform_fault_domain_count
  proximity_placement_group_id    = var.proximity_placement_group_id
  scale_in_policy                 = var.scale_in_policy
  single_placement_group          = var.single_placement_group
  instances                       = var.autoscale_count_default
  computer_name_prefix            = null
  sku                             = var.vm_size
  tags                            = var.tags
  zones                           = var.zones
  zone_balance                    = var.zone_balance
  upgrade_mode                    = "Manual"
  provision_vm_agent              = false

  custom_data = base64encode(join(
    ",",
    [
      "storage-account=${var.bootstrap_storage_account.name}",
      "access-key=${var.bootstrap_storage_account.primary_access_key}",
      "file-share=${var.bootstrap_share_name}",
      "share-directory=None"
    ]
  ))

  network_interface {
    name                          = "${var.name_prefix}${var.name_mgmt_nic_profile}"
    primary                       = true
    enable_ip_forwarding          = true
    enable_accelerated_networking = false # unsupported by PAN-OS

    ip_configuration {
      name      = "${var.name_prefix}${var.name_mgmt_nic_ip}"
      primary   = true
      subnet_id = var.subnet_mgmt.id

      dynamic "public_ip_address" {
        for_each = var.create_mgmt_pip ? ["one"] : []

        content {
          name                    = "${var.name_prefix}${var.name_fw_mgmt_pip}"
          domain_name_label       = var.mgmt_pip_domain_name_label
          idle_timeout_in_minutes = 4
        }
      }
    }
  }

  network_interface {
    name                          = "${var.name_prefix}${var.name_private_nic_profile}"
    primary                       = false
    enable_ip_forwarding          = true
    enable_accelerated_networking = var.accelerated_networking

    ip_configuration {
      name                                   = "${var.name_prefix}${var.name_private_nic_ip}"
      primary                                = true
      subnet_id                              = var.subnet_private.id
      load_balancer_backend_address_pool_ids = var.private_backend_pool_id != null ? [var.private_backend_pool_id] : []
    }
  }

  dynamic "network_interface" {
    for_each = var.create_public_interface ? ["public"] : [/* else none */]

    content {
      name                          = "${var.name_prefix}${var.name_public_nic_profile}"
      primary                       = false
      enable_ip_forwarding          = true
      enable_accelerated_networking = var.accelerated_networking

      ip_configuration {
        name                                   = "${var.name_prefix}${var.name_public_nic_ip}"
        primary                                = true
        subnet_id                              = var.subnet_public.id
        load_balancer_backend_address_pool_ids = var.public_backend_pool_id != null ? [var.public_backend_pool_id] : []

        dynamic "public_ip_address" {
          for_each = var.create_public_pip ? ["one"] : []

          content {
            name                    = "${var.name_prefix}${var.name_fw_public_pip}"
            domain_name_label       = var.public_pip_domain_name_label
            idle_timeout_in_minutes = 4
          }
        }

      }
    }
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account_uri
  }

  identity {
    type = "SystemAssigned" # (Required) The type of Managed Identity which should be assigned to the Linux Virtual Machine Scale Set. Possible values are SystemAssigned, UserAssigned and SystemAssigned, UserAssigned.
  }

  source_image_id = var.custom_image_id

  source_image_reference {
    publisher = var.use_custom_image ? null : var.img_publisher
    offer     = var.use_custom_image ? null : var.img_offer
    sku       = var.use_custom_image ? null : var.img_sku
    version   = var.use_custom_image ? null : var.img_version
  }

  os_disk {
    caching                = "ReadWrite"
    disk_encryption_set_id = var.disk_encryption_set_id #  The Disk Encryption Set must have the Reader Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault.
    storage_account_type   = var.storage_account_type
  }

  dynamic "plan" {
    for_each = var.enable_plan ? ["one"] : []

    content {
      name      = var.img_sku
      publisher = var.img_publisher
      product   = var.img_offer
    }
  }
}

resource "azurerm_application_insights" "this" {
  count = var.metrics_retention_in_days != 0 ? 1 : 0

  name                = coalesce(var.name_application_insights, "${var.name_prefix}appinsights")
  location            = var.location
  resource_group_name = var.resource_group_name # same RG, so no RBAC modification is needed
  application_type    = "other"
  retention_in_days   = var.metrics_retention_in_days
  tags                = var.tags
}

resource "azurerm_monitor_autoscale_setting" "this" {
  count = length(var.autoscale_metrics) > 0 ? 1 : 0

  name                = coalesce(var.name_autoscale, "${var.name_prefix}autoscale")
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.this.id

  profile {
    name = "${var.name_prefix}profile"

    capacity {
      default = var.autoscale_count_default
      minimum = var.autoscale_count_minimum
      maximum = var.autoscale_count_maximum
    }

    dynamic "rule" {
      for_each = var.autoscale_metrics

      content {
        metric_trigger {
          metric_name        = rule.key
          metric_resource_id = rule.key == "Percentage CPU" ? azurerm_linux_virtual_machine_scale_set.this.id : azurerm_application_insights.this[0].id
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
          metric_resource_id = rule.key == "Percentage CPU" ? azurerm_linux_virtual_machine_scale_set.this.id : azurerm_application_insights.this[0].id
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
      custom_emails = var.autoscale_notification_emails
    }
    dynamic "webhook" {
      for_each = var.autoscale_webhooks_uris

      content {
        service_uri = webhook.value
      }
    }
  }

  tags = var.tags
}

locals {
  # Azure demands Period of Time 1 day 12 hours and 30 minutes to be written as "PT1D12H30M".
  # What's worse, time periods "PT61M" and "PT1H1M" are equal to Azure, but inequal to Terraform.
  # Using solely the number of minutes ("PT61M") causes a bad Terraform apply loop.
  scaleout_cooldown_minutes = "${var.scaleout_cooldown_minutes % 60}M"
  scaleout_cooldown_hours   = "${floor(var.scaleout_cooldown_minutes / 60) % 24}H"
  scaleout_cooldown_days    = "${floor(var.scaleout_cooldown_minutes / (60 * 24))}D"
  scaleout_cooldown         = "P${local.scaleout_cooldown_days != "0D" ? local.scaleout_cooldown_days : ""}T${local.scaleout_cooldown_hours != "0H" ? local.scaleout_cooldown_hours : ""}${local.scaleout_cooldown_minutes != "0M" ? local.scaleout_cooldown_minutes : ""}"

  scaleout_window_minutes = "${var.scaleout_window_minutes % 60}M"
  scaleout_window_hours   = "${floor(var.scaleout_window_minutes / 60) % 24}H"
  scaleout_window_days    = "${floor(var.scaleout_window_minutes / (60 * 24))}D"
  scaleout_window         = "P${local.scaleout_window_days != "0D" ? local.scaleout_window_days : ""}T${local.scaleout_window_hours != "0H" ? local.scaleout_window_hours : ""}${local.scaleout_window_minutes != "0M" ? local.scaleout_window_minutes : ""}"

  scalein_cooldown_minutes = "${var.scalein_cooldown_minutes % 60}M"
  scalein_cooldown_hours   = "${floor(var.scalein_cooldown_minutes / 60) % 24}H"
  scalein_cooldown_days    = "${floor(var.scalein_cooldown_minutes / (60 * 24))}D"
  scalein_cooldown         = "P${local.scalein_cooldown_days != "0D" ? local.scalein_cooldown_days : ""}T${local.scalein_cooldown_hours != "0H" ? local.scalein_cooldown_hours : ""}${local.scalein_cooldown_minutes != "0M" ? local.scalein_cooldown_minutes : ""}"

  scalein_window_minutes = "${var.scalein_window_minutes % 60}M"
  scalein_window_hours   = "${floor(var.scalein_window_minutes / 60) % 24}H"
  scalein_window_days    = "${floor(var.scalein_window_minutes / (60 * 24))}D"
  scalein_window         = "P${local.scalein_window_days != "0D" ? local.scalein_window_days : ""}T${local.scalein_window_hours != "0H" ? local.scalein_window_hours : ""}${local.scalein_window_minutes != "0M" ? local.scalein_window_minutes : ""}"
}

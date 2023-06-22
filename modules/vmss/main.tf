resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  admin_username                  = var.username
  admin_password                  = var.disable_password_authentication ? null : var.password
  disable_password_authentication = var.disable_password_authentication
  encryption_at_host_enabled      = var.encryption_at_host_enabled
  overprovision                   = var.overprovision
  platform_fault_domain_count     = var.platform_fault_domain_count
  proximity_placement_group_id    = var.proximity_placement_group_id
  single_placement_group          = var.single_placement_group
  instances                       = var.autoscale_count_default
  computer_name_prefix            = null
  sku                             = var.vm_size
  tags                            = var.tags
  zones                           = var.zones
  zone_balance                    = var.zone_balance
  provision_vm_agent              = false
  dynamic "admin_ssh_key" {
    for_each = var.ssh_keys
    content {
      username   = var.username
      public_key = ssh_keys.value
    }
  }

  lifecycle {
    precondition {
      condition     = var.password != null || var.ssh_keys != []
      error_message = "Either password or ssh_key must be set in order to have access to the device"
    }
  }

  # Allowing upgrade_mode = "Rolling" would be actually a big architectural change. First of all:
  #
  # Error: `health_probe_id` must be set or a health extension must be specified when `upgrade_mode` is set to "Rolling"
  #
  # VM-Series do not have a health extension.
  # Having health_probe_id, as visible in the next error message below, Azure requires the first NIC to be
  # the load-balanced one. Azure complains about "inbound-nic-fw-mgmt", which in that case was the primary IP config
  # of the first NIC:
  #
  # Error: Error creating Linux Virtual Machine Scale Set "inbound-VMSS" (Resource Group "example-vmss-inbound"):
  # compute.VirtualMachineScaleSetsClient#CreateOrUpdate: Failure sending request: StatusCode=0 -- Original Error:
  # Code="CannotUseHealthProbeWithoutLoadBalancing"
  # Message="VM scale set /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/EXAMPLE-VMSS-INBOUND/providers/Microsoft.Compute/virtualMachineScaleSets/inbound-VMSS cannot use probe /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/example-vmss-inbound/providers/Microsoft.Network/loadBalancers/inbound-public-elb/probes/inbound-public-elb as a HealthProbe because primary IP configuration inbound-nic-fw-mgmt of the scale set does not use load balancing. LoadBalancerBackendAddressPools property of the IP configuration must reference backend address pool of the load balancer that contains the probe."
  # Details=[]
  # │
  # │   with module.inbound_scale_set.azurerm_linux_virtual_machine_scale_set.this,
  # │   on ../../modules/vmss/main.tf line 1, in resource "azurerm_linux_virtual_machine_scale_set" "this":
  # │    1: resource "azurerm_linux_virtual_machine_scale_set" "this" {
  #
  # Hence mgmt-interface-swap seems to be required on VM-Series, which would need a major overhaul of the
  # subnet-related inputs. Without the mgmt-interface-swap, it seems impossible to have upgrade_mode = "Rolling".
  #
  # The phony LB on a management network does not seem a viable solution. For now Azure does not support two internal
  # load balancers per VM. Also, health checking HTTP/SSH on management port would wrongly consider that unconfigured
  # VM-Series is good to use. Unconfigured VM-Series still shows HTTP/SSH on the management interface. This does not
  # happen when checking a dataplane interface, because the data only shows HTTP/SSH after the initial commit applies
  # a specific management profile.
  #
  # Also the inbound vmss would have the ethernet1/1 public and ethernet1/2 private, but outbound vmss would have
  # the ethernet1/1 private and ethernet1/2 public. That ensures the respective LB health probe works on ethernet1/1,
  # which is the first NIC.
  #
  # The automatic_instance_repair also suffers from exactly the same problem:
  # "Automatic repairs not supported for this Virtual Machine Scale Set because a health probe or health extension was not provided."
  upgrade_mode = "Manual"

  custom_data = base64encode(var.bootstrap_options)

  scale_in {
    rule                   = var.scale_in_policy
    force_deletion_enabled = var.scale_in_force_deletion
  }

  dynamic "network_interface" {
    for_each = var.interfaces
    iterator = nic

    content {
      name                          = "${var.name}-${nic.value.name}"
      primary                       = nic.key == 0 ? true : false
      enable_ip_forwarding          = nic.key == 0 ? false : true
      enable_accelerated_networking = nic.key == 0 ? false : var.accelerated_networking

      ip_configuration {
        name                                         = "primary"
        primary                                      = true
        subnet_id                                    = nic.value.subnet_id
        load_balancer_backend_address_pool_ids       = nic.key == 0 ? [] : try(nic.value.lb_backend_pool_ids, [])
        application_gateway_backend_address_pool_ids = nic.key == 0 ? [] : try(nic.value.appgw_backend_pool_ids, [])

        dynamic "public_ip_address" {
          for_each = try(nic.value.create_pip, false) ? ["one"] : []
          iterator = pip

          content {
            name              = "${var.name}-${nic.value.name}-pip"
            domain_name_label = try(nic.value.pip_domain_name_label, null)
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

resource "azurerm_monitor_autoscale_setting" "this" {
  count = length(var.autoscale_metrics) > 0 ? 1 : 0

  name                = "${var.name}-autoscale"
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.this.id

  profile {
    name = "autoscale profile"

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
          metric_resource_id = rule.key == "Percentage CPU" ? azurerm_linux_virtual_machine_scale_set.this.id : var.application_insights_id
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
          metric_resource_id = rule.key == "Percentage CPU" ? azurerm_linux_virtual_machine_scale_set.this.id : var.application_insights_id
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

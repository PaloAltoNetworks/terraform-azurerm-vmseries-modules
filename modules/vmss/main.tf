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
  instances                       = var.vm_count
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

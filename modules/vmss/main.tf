resource "azurerm_virtual_machine_scale_set" "this" {
  name                = "${var.name_prefix}${var.name_scale_set}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  zones               = var.zones
  upgrade_policy_mode = "Manual"

  network_profile {
    name                   = "${var.name_prefix}${var.name_mgmt_nic_profile}"
    primary                = true
    ip_forwarding          = true
    accelerated_networking = false # unsupported by PAN-OS

    ip_configuration {
      name      = "${var.name_prefix}${var.name_mgmt_nic_ip}"
      primary   = true
      subnet_id = var.subnet_mgmt.id

      public_ip_address_configuration {
        idle_timeout      = 4
        name              = "${var.name_prefix}${var.name_fw_mgmt_pip}"
        domain_name_label = "${var.name_prefix}${var.name_domain_name_label}"
      }
    }
  }

  network_profile {
    name                   = "${var.name_prefix}${var.name_private_nic_profile}"
    primary                = false
    ip_forwarding          = true
    accelerated_networking = var.accelerated_networking

    ip_configuration {
      name                                   = "${var.name_prefix}${var.name_private_nic_ip}"
      primary                                = false
      subnet_id                              = var.subnet_private.id
      load_balancer_backend_address_pool_ids = var.private_backend_pool_id != null ? [var.private_backend_pool_id] : []
    }
  }

  dynamic "network_profile" {
    for_each = var.enable_public_interface ? ["public"] : [/* else none */]

    content {
      name                   = "${var.name_prefix}${var.name_public_nic_profile}"
      primary                = false
      ip_forwarding          = true
      accelerated_networking = var.accelerated_networking

      ip_configuration {
        name                                   = "${var.name_prefix}${var.name_public_nic_ip}"
        primary                                = false
        subnet_id                              = var.subnet_public.id
        load_balancer_backend_address_pool_ids = var.public_backend_pool_id != null ? [var.public_backend_pool_id] : []
      }
    }
  }

  os_profile {
    admin_username       = var.username
    computer_name_prefix = "${var.name_prefix}${var.name_fw}"
    admin_password       = var.password

    custom_data = join(
      ",",
      [
        "storage-account=${var.bootstrap_storage_account.name}",
        "access-key=${var.bootstrap_storage_account.primary_access_key}",
        "file-share=${var.bootstrap_share_name}",
        "share-directory=None"
      ]
    )
  }

  storage_profile_image_reference {
    id        = var.custom_image_id
    publisher = var.custom_image_id == null ? var.img_publisher : null
    offer     = var.custom_image_id == null ? var.img_offer : null
    sku       = var.custom_image_id == null ? var.img_sku : null
    version   = var.custom_image_id == null ? var.img_version : null
  }

  sku {
    capacity = var.vm_count
    name     = var.vm_size
  }

  storage_profile_os_disk {
    create_option     = "FromImage"
    managed_disk_type = var.managed_disk_type
    os_type           = "Linux"
    caching           = "ReadWrite"
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

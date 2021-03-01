# Base resource group
resource "azurerm_resource_group" "vmss" {
  name     = "${var.name_prefix}${var.sep}${var.name_rg}"
  location = var.location
}

# inbound
resource "azurerm_virtual_machine_scale_set" "this" {
  name                = "${var.name_prefix}${var.sep}${var.name_scale_set}"
  location            = azurerm_resource_group.vmss.location
  resource_group_name = azurerm_resource_group.vmss.name
  upgrade_policy_mode = "Manual"

  network_profile {
    name          = "${var.name_prefix}${var.sep}${var.name_mgmt_nic_profile}"
    primary       = true
    ip_forwarding = true

    ip_configuration {
      name      = "${var.name_prefix}${var.sep}${var.name_mgmt_nic_ip}"
      primary   = true
      subnet_id = var.subnet_mgmt.id

      public_ip_address_configuration {
        idle_timeout      = 4
        name              = "${var.name_prefix}${var.sep}${var.name_fw_mgmt_pip}"
        domain_name_label = "${var.name_prefix}${var.sep}${var.name_domain_name_label}"
      }
    }
  }

  network_profile {
    name          = "${var.name_prefix}${var.sep}${var.name_public_nic_profile}"
    primary       = false
    ip_forwarding = true

    ip_configuration {
      name                                   = "${var.name_prefix}${var.sep}${var.name_public_nic_ip}"
      primary                                = false
      subnet_id                              = var.subnet_public.id
      load_balancer_backend_address_pool_ids = [var.lb_backend_pool_id]
    }
  }

  network_profile {
    name          = "${var.name_prefix}${var.sep}${var.name_private_nic_profile}"
    primary       = false
    ip_forwarding = true

    ip_configuration {
      name      = "${var.name_prefix}${var.sep}${var.name_private_nic_ip}"
      primary   = false
      subnet_id = var.subnet_private.id
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
    publisher = "paloaltonetworks"
    offer     = "vmseries1"
    sku       = var.vm_series_sku
    version   = var.vm_series_version
  }

  sku {
    capacity = 1
    name     = var.vm_size
  }

  storage_profile_os_disk {
    create_option  = "FromImage"
    name           = "${var.name_prefix}-vhd-profile"
    caching        = "ReadWrite"
    vhd_containers = [var.vhd_container]
  }

  plan {
    name      = var.vm_series_sku
    publisher = "paloaltonetworks"
    product   = "vmseries1"
  }
}

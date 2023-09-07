locals {
  img_publisher                   = element(split(",", lookup(var.standard_os, var.vm_os_simple, "")), 0)
  img_offer                       = element(split(",", lookup(var.standard_os, var.vm_os_simple, "")), 1)
  img_sku                         = element(split(",", lookup(var.standard_os, var.vm_os_simple, "")), 2)
  disable_password_authentication = var.password == null ? true : false
}

resource "azurerm_public_ip" "this" {
  for_each = { for k, v in var.interfaces : k => v if try(v.create_public_ip, false) }

  location            = var.location
  resource_group_name = var.resource_group_name
  name                = "${each.value.name}-pip"
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.enable_zones ? var.avzones : null
  tags                = try(each.value.tags, var.tags)
}

resource "azurerm_network_interface" "this" {
  count = length(var.interfaces)

  name                          = var.interfaces[count.index].name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.accelerated_networking
  enable_ip_forwarding          = true
  tags                          = try(var.interfaces[count.index].tags, var.tags)

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.interfaces[count.index].subnet_id
    private_ip_address_allocation = try(var.interfaces[count.index].private_ip_address, null) != null ? "Static" : "Dynamic"
    private_ip_address            = try(var.interfaces[count.index].private_ip_address, null)
    public_ip_address_id          = try(azurerm_public_ip.this[count.index].id, var.interfaces[count.index].public_ip_address_id, null)
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "this" {
  for_each = { for k, v in var.interfaces : k => v if try(v.enable_backend_pool, false) }

  backend_address_pool_id = each.value.lb_backend_pool_id
  ip_configuration_name   = azurerm_network_interface.this[each.key].ip_configuration[0].name
  network_interface_id    = azurerm_network_interface.this[each.key].id

  depends_on = [
    azurerm_network_interface.this,
    azurerm_virtual_machine.this
  ]
}

resource "azurerm_virtual_machine" "this" {
  name                         = var.name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  tags                         = var.tags
  vm_size                      = var.vm_size
  zones                        = var.enable_zones && var.avzone != null && var.avzone != "" ? [var.avzone] : null
  availability_set_id          = var.avset_id
  primary_network_interface_id = azurerm_network_interface.this[0].id

  network_interface_ids = [for k, v in azurerm_network_interface.this : v.id]

  storage_image_reference {
    id        = var.custom_image_id
    publisher = var.custom_image_id == null ? coalesce(var.img_publisher, local.img_publisher) : null
    offer     = var.custom_image_id == null ? coalesce(var.img_offer, local.img_offer) : null
    sku       = var.custom_image_id == null ? coalesce(var.img_sku, local.img_sku) : null
    version   = var.custom_image_id == null ? var.img_version : null
  }

  dynamic "plan" {
    for_each = var.enable_plan ? ["one"] : []

    content {
      name      = var.img_sku
      publisher = var.img_publisher
      product   = var.img_offer
    }
  }

  storage_os_disk {
    create_option     = "FromImage"
    name              = coalesce(var.os_disk_name, "${var.name}-vhd")
    managed_disk_type = var.managed_disk_type
    os_type           = "Linux"
    caching           = "ReadWrite"
  }

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = var.name
    admin_username = var.username
    admin_password = local.disable_password_authentication == true ? null : var.password
    custom_data    = var.custom_data
  }

  os_profile_linux_config {
    disable_password_authentication = local.disable_password_authentication
    dynamic "ssh_keys" {
      for_each = var.ssh_keys
      content {
        key_data = ssh_keys.value
        path     = "/home/${var.username}/.ssh/authorized_keys"
      }
    }
  }

  lifecycle {
    precondition {
      condition     = var.password != null || var.ssh_keys != []
      error_message = "Either password or ssh_keys must be set in order to have access to the device"
    }
  }

  # After converting to azurerm_linux_virtual_machine, an empty block boot_diagnostics {} will use managed storage. Want.
  # 2.36 in required_providers per https://github.com/terraform-providers/terraform-provider-azurerm/pull/8917
  dynamic "boot_diagnostics" {
    for_each = var.bootstrap_storage_account != null ? ["one"] : []

    content {
      enabled     = true
      storage_uri = var.bootstrap_storage_account.primary_blob_endpoint
    }
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }
}
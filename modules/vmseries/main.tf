resource "azurerm_public_ip" "this" {
  for_each = { for v in var.interfaces : v.name => v if try(v.create_public_ip, false) }

  location            = var.location
  resource_group_name = var.resource_group_name
  name                = "${each.value.name}-pip"
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.enable_zones ? var.avzones : null
  tags                = try(each.value.tags, var.tags)
}

data "azurerm_public_ip" "this" {
  for_each = { for v in var.interfaces : v.name => v
    if(!try(v.create_public_ip, false) && try(v.public_ip_name, null) != null)
  }

  name                = each.value.public_ip_name
  resource_group_name = try(each.value.public_ip_resource_group, null) != null ? each.value.public_ip_resource_group : var.resource_group_name
}

resource "azurerm_network_interface" "this" {
  for_each = { for k, v in var.interfaces : v.name => merge(v, { index = k }) }

  name                          = "${each.value.name}-nic"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = each.value.index == 0 ? false : var.accelerated_networking                 # for interface 0 it is unsupported by PAN-OS
  enable_ip_forwarding          = try(each.value.enable_ip_forwarding, each.value.index == 0 ? false : true) # for interface 0 use false per Reference Arch
  tags                          = try(each.value.tags, var.tags)

  ip_configuration {
    name                          = "primary"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = try(each.value.private_ip_address, null) != null ? "Static" : "Dynamic"
    private_ip_address            = try(each.value.private_ip_address, null)
    public_ip_address_id          = try(azurerm_public_ip.this[each.value.name].id, data.azurerm_public_ip.this[each.value.name].id, null)
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "this" {
  for_each = { for v in var.interfaces : v.name => v if try(v.enable_backend_pool, false) }

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
  primary_network_interface_id = azurerm_network_interface.this[var.interfaces[0].name].id

  network_interface_ids = [for v in var.interfaces : azurerm_network_interface.this[v.name].id]

  storage_image_reference {
    id        = var.custom_image_id
    publisher = var.custom_image_id == null ? var.img_publisher : null
    offer     = var.custom_image_id == null ? var.img_offer : null
    sku       = var.custom_image_id == null ? var.img_sku : null
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
    name              = coalesce(var.os_disk_name, "${var.name}-disk")
    managed_disk_type = var.managed_disk_type
    os_type           = "Linux"
    caching           = "ReadWrite"
  }

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = var.name
    admin_username = var.username
    admin_password = var.password
    custom_data    = var.bootstrap_options
  }

  os_profile_linux_config {
    disable_password_authentication = var.password == null ? true : false
    dynamic "ssh_keys" {
      for_each = var.ssh_keys
      content {
        key_data = ssh_keys.value
        path     = "/home/${var.username}/.ssh/authorized_keys"
      }
    }
  }

  # After converting to azurerm_linux_virtual_machine, an empty block boot_diagnostics {} will use managed storage. Want.
  # 2.36 in required_providers per https://github.com/terraform-providers/terraform-provider-azurerm/pull/8917
  dynamic "boot_diagnostics" {
    for_each = var.diagnostics_storage_uri != null ? ["one"] : []

    content {
      enabled     = true
      storage_uri = var.diagnostics_storage_uri
    }
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }
}

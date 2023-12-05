# Create a public IP for management
resource "azurerm_public_ip" "this" {
  for_each = { for v in var.interfaces : v.name => v if try(v.create_public_ip, false) }

  location            = var.location
  resource_group_name = var.resource_group_name
  name                = "${each.value.name}-pip"
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.enable_zones ? var.avzones : null

  tags = var.tags
}

data "azurerm_public_ip" "this" {
  for_each = { for v in var.interfaces : v.name => v
    if(!try(v.create_public_ip, false) && try(v.public_ip_name, null) != null)
  }

  name                = each.value.public_ip_name
  resource_group_name = try(each.value.public_ip_resource_group, null) != null ? each.value.public_ip_resource_group : var.resource_group_name
}

# Build Panorama interface
resource "azurerm_network_interface" "this" {
  for_each = { for k, v in var.interfaces : v.name => merge(v, { index = k }) }

  name                          = "${each.value.name}-nic"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = false
  enable_ip_forwarding          = false
  tags                          = var.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = try(each.value.private_ip_address, null) != null ? "Static" : "Dynamic"
    private_ip_address            = try(each.value.private_ip_address, null)
    public_ip_address_id          = try(azurerm_public_ip.this[each.value.name].id, data.azurerm_public_ip.this[each.value.name].id, null)
  }
}

# Build the Panorama VM
resource "azurerm_virtual_machine" "panorama" {
  name                         = var.name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  primary_network_interface_id = azurerm_network_interface.this[var.interfaces[0].name].id
  vm_size                      = var.panorama_size
  network_interface_ids        = [for v in var.interfaces : azurerm_network_interface.this[v.name].id]

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id        = var.custom_image_id
    publisher = var.custom_image_id == null ? var.panorama_publisher : null
    offer     = var.custom_image_id == null ? var.panorama_offer : null
    sku       = var.custom_image_id == null ? var.panorama_sku : null
    version   = var.custom_image_id == null ? var.panorama_version : null
  }

  storage_os_disk {
    name              = coalesce(var.os_disk_name, "${var.name}-disk")
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.panorama_disk_type
  }

  os_profile {
    computer_name  = var.name
    admin_username = var.username
    admin_password = var.password
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostic_storage_uri != null ? [1] : []
    content {
      enabled     = true
      storage_uri = var.boot_diagnostic_storage_uri
    }
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

  dynamic "plan" {
    for_each = var.enable_plan ? ["one"] : []

    content {
      name      = var.panorama_sku
      publisher = var.panorama_publisher
      product   = var.panorama_offer
    }
  }
  zones = var.enable_zones && var.avzone != null && var.avzone != "" ? [var.avzone] : null
  tags  = var.tags
}

# Panorama managed disk
resource "azurerm_managed_disk" "this" {
  for_each = var.logging_disks

  name                 = "${var.name}-disk-${each.key}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = try(each.value.disk_type, "Standard_LRS")
  create_option        = "Empty"
  disk_size_gb         = try(each.value.size, "2048")
  zone                 = var.enable_zones ? try(var.avzone, null) : null

  tags = var.tags
}

# Attach logging disk to Panorama VM
resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  for_each = azurerm_managed_disk.this

  managed_disk_id    = each.value.id
  virtual_machine_id = azurerm_virtual_machine.panorama.id
  lun                = var.logging_disks[each.key].lun
  caching            = "ReadWrite"
}

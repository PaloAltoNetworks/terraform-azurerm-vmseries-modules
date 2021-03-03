# Base resource group
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

# Create a public IP for management
resource "azurerm_public_ip" "this" {
  for_each = { for k, v in var.interfaces : k => v if v.public_ip == "true" }

  name                = "${var.name_prefix}${var.sep}${var.name_panorama_pip}${var.sep}${each.key}"
  location            = coalesce(var.location, data.azurerm_resource_group.this.location)
  resource_group_name = data.azurerm_resource_group.this.name
  allocation_method   = "Static"

  tags = var.tags
}

# Build the management interface
resource "azurerm_network_interface" "this" {
  for_each = var.interfaces

  name                 = "${var.name_prefix}${var.sep}${each.key}"
  location             = coalesce(var.location, data.azurerm_resource_group.this.location)
  resource_group_name  = data.azurerm_resource_group.this.name
  enable_ip_forwarding = lookup(each.value, "enable_ip_forwarding", "false")

  ip_configuration {
    name                          = "${var.name_prefix}${each.key}"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = lookup(each.value, "private_ip_address", null) != null ? "static" : "dynamic"
    private_ip_address            = lookup(each.value, "private_ip_address", null) != null ? each.value.private_ip_address : null
    public_ip_address_id          = lookup(each.value, "public_ip", "false") != "false" ? try(azurerm_public_ip.this[each.key].id) : null
  }

  tags = var.tags
}

locals {
  primary_interface = [for k, v in var.interfaces : k if lookup(v, "primary_interface", false) == "true"][0]
}

# Build the Panorama VM
resource "azurerm_virtual_machine" "panorama" {
  name                         = "${var.name_prefix}${var.sep}${var.panorama_name}"
  location                     = coalesce(var.location, data.azurerm_resource_group.this.location)
  resource_group_name          = data.azurerm_resource_group.this.name
  network_interface_ids        = [for k, v in azurerm_network_interface.this : azurerm_network_interface.this[k].id]
  primary_network_interface_id = azurerm_network_interface.this[local.primary_interface].id
  vm_size                      = var.panorama_size

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
    name              = "${var.name_prefix}PanoramaDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  dynamic "plan" {
    for_each = var.enable_plan ? ["one"] : []

    content {
      name      = var.panorama_sku
      publisher = var.panorama_publisher
      product   = var.panorama_offer
    }
  }
  zones = var.avzone != null ? [var.avzone] : null
  tags  = var.tags
}

# Panorama managed disk
resource "azurerm_managed_disk" "this" {
  for_each             = var.logging_disks
  name                 = "${var.name_prefix}${var.sep}${var.panorama_name}-disk-${each.key}"
  location             = coalesce(var.location, data.azurerm_resource_group.this.location)
  resource_group_name  = data.azurerm_resource_group.this.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = lookup(each.value, "size", "100")
  zones                = [lookup(each.value, "zone", "")]

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

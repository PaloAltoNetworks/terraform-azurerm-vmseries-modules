# Create a public IP for management
resource "azurerm_public_ip" "this" {
  count = var.interface[0].public_ip == "true" ? 1 : 0

  name                = var.interface[0].public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"

  tags = var.tags
}

# Build Panorama interface
resource "azurerm_network_interface" "this" {
  name                 = var.interface[0].name
  location             = var.location
  resource_group_name  = var.resource_group_name
  enable_ip_forwarding = lookup(var.interface[0], "enable_ip_forwarding", "false")

  ip_configuration {
    name                          = var.interface[0].name
    subnet_id                     = var.interface[0].subnet_id
    private_ip_address_allocation = lookup(var.interface[0], "private_ip_address", null) != null ? "static" : "dynamic"
    private_ip_address            = lookup(var.interface[0], "private_ip_address", null) != null ? var.interface[0].private_ip_address : null
    public_ip_address_id          = lookup(var.interface[0], "public_ip", false) ? azurerm_public_ip.this[0].id : null
  }

  tags = var.tags
}

# Build the Panorama VM
resource "azurerm_virtual_machine" "panorama" {
  name                         = var.panorama_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  network_interface_ids        = [azurerm_network_interface.this.id]
  primary_network_interface_id = azurerm_network_interface.this.id
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
    name              = coalesce(var.os_disk_name, "${var.panorama_name}-disk")
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.panorama_name
    admin_username = var.username
    admin_password = var.password
  }

  boot_diagnostics {
    enabled     = var.boot_diagnostic_storage_uri != null ? true : false
    storage_uri = var.boot_diagnostic_storage_uri
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
  for_each = var.logging_disks

  name                 = "${var.panorama_name}-disk-${each.key}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = lookup(each.value, "size", "2048")
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

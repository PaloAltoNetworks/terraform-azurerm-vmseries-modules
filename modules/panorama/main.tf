# Base resource group
resource "azurerm_resource_group" "panorama" {
  name     = "${var.name_prefix}${var.sep}${var.name_rg}"
  location = var.location
}

# Create a public IP for management
resource "azurerm_public_ip" "panorama-pip-mgmt" {
  count               = var.panorama_ha ? 2 : 1
  name                = "${var.name_prefix}${var.sep}${var.name_panorama_pip_mgmt}-${element(var.panorama_ha_suffix_map, count.index)}"
  location            = azurerm_resource_group.panorama.location
  resource_group_name = azurerm_resource_group.panorama.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["${count.index + 1}"]
}

# Build the management interface
resource "azurerm_network_interface" "mgmt" {
  count               = var.panorama_ha ? 2 : 1
  name                = "${var.name_prefix}${var.sep}${var.name_mgmt}-${element(var.panorama_ha_suffix_map, count.index)}"
  location            = azurerm_resource_group.panorama.location
  resource_group_name = azurerm_resource_group.panorama.name

  ip_configuration {
    name                          = "${var.name_prefix}-ip-mgmt-${element(var.panorama_ha_suffix_map, count.index)}"
    subnet_id                     = var.subnet_mgmt.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.panorama-pip-mgmt[count.index].id
  }
}

# Build the Panorama VM
resource "azurerm_virtual_machine" "panorama" {
  count                 = var.panorama_ha ? 2 : 1
  name                  = "${var.name_prefix}${var.sep}${var.name_panorama}-${element(var.panorama_ha_suffix_map, count.index)}"
  location              = azurerm_resource_group.panorama.location
  resource_group_name   = azurerm_resource_group.panorama.name
  network_interface_ids = [azurerm_network_interface.mgmt[count.index].id]
  vm_size               = var.panorama_size
  zones                 = ["${count.index + 1}"]

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "paloaltonetworks"
    offer     = "panorama"
    sku       = var.panorama_sku
    version   = var.panorama_version
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

  plan {
    publisher = "paloaltonetworks"
    product   = "panorama"
    name      = var.panorama_sku
  }
}


locals {

}

# Panorama managed disk
resource "azurerm_managed_disk" "this" {
  count                = var.panorama_ha && var.enable_logging_disk ? 2 : var.enable_logging_disk ? 1 : 0
  name                 = "${var.name_prefix}${var.sep}${var.name_panorama}-disk-${element(var.panorama_ha_suffix_map, count.index)}"
  location             = azurerm_resource_group.panorama.location
  resource_group_name  = azurerm_resource_group.panorama.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.logging_disk_size
  zones                = ["${count.index + 1}"]
}

# Attach logging disk to Panorama VM
resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  count              = var.panorama_ha ? 2 : 1
  managed_disk_id    = azurerm_managed_disk.this[count.index].id
  virtual_machine_id = azurerm_virtual_machine.panorama[count.index].id
  lun                = var.Logical_unit_number
  caching            = "ReadWrite"
}

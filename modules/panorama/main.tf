data "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

# Create a public IP for management
resource "azurerm_public_ip" "panorama-pip-mgmt" {
  name                = "${var.name_prefix}${var.sep}${var.name_panorama_pip_mgmt}"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  allocation_method   = "Static"
}

# Build the management interface
resource "azurerm_network_interface" "mgmt" {
  name                = "${var.name_prefix}${var.sep}${var.name_mgmt}"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  ip_configuration {
    name                          = "${var.name_prefix}-ip-mgmt"
    subnet_id                     = var.subnet_mgmt.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.panorama-pip-mgmt.id
  }
}

# Build the Panorama VM
resource "azurerm_virtual_machine" "panorama" {
  name                  = "${var.name_prefix}${var.sep}${var.name_panorama}"
  location              = data.azurerm_resource_group.this.location
  resource_group_name   = data.azurerm_resource_group.this.name
  network_interface_ids = [azurerm_network_interface.mgmt.id]
  vm_size               = var.panorama_size

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

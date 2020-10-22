
resource "azurerm_availability_set" "ib-az" {
  location                    = var.location
  name                        = "${var.name_prefix}${var.sep}${var.name_ib_az}"
  resource_group_name         = var.resource_group.name
  platform_fault_domain_count = 2
  managed                     = false

}

# Create a public IP for management
resource "azurerm_public_ip" "ib-pip-fw-mgmt" {
  count               = var.vm_count
  allocation_method   = "Static"
  location            = var.resource_group.location
  name                = "${var.name_prefix}${var.sep}${var.name_ib_pip_fw_mgmt}${var.sep}${count.index}"
  sku                 = "standard"
  resource_group_name = var.resource_group.name
}
# Create another PIP for the outside interface so we can talk outbound
resource "azurerm_public_ip" "ib-pip-fw-public" {
  count               = var.vm_count
  allocation_method   = "Static"
  location            = var.resource_group.location
  name                = "${var.name_prefix}${var.sep}${var.name_ib_pip_fw_public}${var.sep}${count.index}"
  sku                 = "standard"
  resource_group_name = var.resource_group.name
}

resource "azurerm_network_interface" "ib-nic-fw-mgmt" {
  count               = var.vm_count
  location            = var.resource_group.location
  name                = "${var.name_prefix}${var.sep}${var.name_ib_nic_fw_mgmt}${var.sep}${count.index}"
  resource_group_name = var.resource_group.name
  ip_configuration {
    subnet_id                     = var.subnet-mgmt.id
    name                          = "${var.name_prefix}${var.sep}${var.name_ib_pip_fw_public}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.ib-pip-fw-mgmt[count.index].id
  }
}

resource "azurerm_network_interface" "ib-nic-fw-private" {
  count               = var.vm_count
  location            = var.resource_group.location
  name                = "${var.name_prefix}${var.sep}${var.name_ib_nic_fw_private}${var.sep}${count.index}"
  resource_group_name = var.resource_group.name
  ip_configuration {
    subnet_id                     = var.subnet-private.id
    name                          = "${var.name_prefix}${var.sep}${var.name_ib_fw_ip_private}${var.sep}${count.index}"
    private_ip_address_allocation = "dynamic"
    //private_ip_address = "172.16.1.10"
  }
  enable_ip_forwarding = true
}

resource "azurerm_network_interface" "ib-nic-fw-public" {
  count               = var.vm_count
  location            = var.resource_group.location
  name                = "${var.name_prefix}${var.sep}${var.name_ib_nic_fw_public}${var.sep}${count.index}"
  resource_group_name = var.resource_group.name
  ip_configuration {
    subnet_id                     = var.subnet-public.id
    name                          = "${var.name_prefix}${var.sep}${var.name_ib_fw_ip_public}${var.sep}${count.index}"
    private_ip_address_allocation = "dynamic"
    //private_ip_address = "172.16.2.10"
    public_ip_address_id = azurerm_public_ip.ib-pip-fw-public[count.index].id

  }
  enable_ip_forwarding = true

}

resource "azurerm_network_interface_backend_address_pool_association" "inbound-pool-assoc" {
  count                   = var.vm_count
  backend_address_pool_id = var.inbound_lb_backend_pool_id
  ip_configuration_name   = azurerm_network_interface.ib-nic-fw-public[count.index].ip_configuration[0].name
  network_interface_id    = azurerm_network_interface.ib-nic-fw-public[count.index].id
}

resource "azurerm_virtual_machine" "inbound-fw" {
  count    = var.vm_count
  location = var.resource_group.location
  name     = "${var.name_prefix}${var.sep}${var.name_inbound_fw}${var.sep}${count.index}"
  network_interface_ids = [
    azurerm_network_interface.ib-nic-fw-mgmt[count.index].id,
    azurerm_network_interface.ib-nic-fw-public[count.index].id,
    azurerm_network_interface.ib-nic-fw-private[count.index].id
  ]
  resource_group_name = var.resource_group.name
  vm_size             = var.vmseries_size
  storage_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries1"
    sku       = var.vm_series_sku
    version   = var.vm_series_version

  }

  storage_os_disk {
    create_option = "FromImage"
    name          = "${var.name_prefix}-ib-vhd-fw-${count.index}"
    caching       = "ReadWrite"
    vhd_uri       = "${var.bootstrap-storage-account.primary_blob_endpoint}vhds/${var.name_prefix}-ib-fw-${count.index}.vhd"
  }


  primary_network_interface_id = azurerm_network_interface.ib-nic-fw-mgmt[count.index].id
  os_profile {
    admin_username = var.username
    computer_name  = "${var.name_prefix}-fw-${count.index}"
    admin_password = var.password
    custom_data = join(
      ",",
      [
        "storage-account=${var.bootstrap-storage-account.name}",
        "access-key=${var.bootstrap-storage-account.primary_access_key}",
        "file-share=${var.inbound-bootstrap-share-name}",
        "share-directory=None"
      ]
    )
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  plan {
    name      = var.vm_series_sku
    publisher = "paloaltonetworks"
    product   = "vmseries1"
  }
  availability_set_id = azurerm_availability_set.ib-az.id
}

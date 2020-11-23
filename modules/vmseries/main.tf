


# Create the public IP address
resource "azurerm_public_ip" "pip" {
  for_each = {
    for i in flatten([
      for f in var.firewalls :
      f.interfaces
    ]) :
    i.name => i
    if lookup(i, "public_ip", null) != null ? lookup(i, "public_ip", null) != true ? false : true : false
  }

  name                = "${each.key}-pip"
  location            = var.region
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "nic" {
  for_each = {
    for i in flatten([
      for f in var.firewalls :
      f.interfaces
    ]) :
    i.name => i
  }

  name                          = each.key
  location                      = var.region
  resource_group_name           = var.resource_group
  enable_ip_forwarding          = each.value.enable_ip_forwarding
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = each.key
    subnet_id                     = var.subnet[each.value.subnet]
    private_ip_address_allocation = lookup(each.value, "private_ip_address_allocation", "Dynamic")
    private_ip_address            = lookup(each.value, "private_ip_address", null) == "" ? null : each.value.private_ip_address
    public_ip_address_id          = lookup(each.value, "public_ip", null) != null ? lookup(each.value, "public_ip", null) != true ? null : azurerm_public_ip.pip[each.key].id : null
  }


  tags = var.tags
}



# Create the virtual machine. Use the "count" variable to define how many to create.

resource "azurerm_virtual_machine" "firewall" {
  for_each = {
    for f in var.firewalls :
    f.name => f
  }

  name                = each.key
  location            = var.region
  resource_group_name = var.resource_group

  network_interface_ids = [
    for i in each.value.interfaces :
    azurerm_network_interface.nic[i.name].id
  ]

  primary_network_interface_id = [
    for i in each.value.interfaces :
    azurerm_network_interface.nic[i.name].id
  ][0]

  vm_size             = var.fw_size
  availability_set_id = var.avsetid

  storage_image_reference {
    publisher = var.vm_publisher
    offer     = var.vm_series
    sku       = var.fw_sku
    version   = var.fw_version
  }

  plan {
    name      = var.fw_sku
    product   = var.vm_series
    publisher = var.vm_publisher
  }

  storage_os_disk {
    # name              = "${var.fw_hostname_prefix}${count.index+1}-pa-vm-os-disk"
    name              = "${each.key}${var.managed_disk_prefix}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.os_disk_type
  }

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = each.key
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = "storage-account=${var.bootstrap_storage_account},access-key=${var.bootstrap_storage_account_access_key},file-share=${var.bootstrap_storage_share},share-directory=firewalls"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = var.primary_blob_endpoint
  }

  tags = var.tags
}


#############################
# Create NSG

resource "azurerm_network_security_group" "nsg" {
  name                = "ANY-ALLOW"
  location            = var.region
  resource_group_name = var.rg_nsg
  tags                = var.tags
}


#############################
#  Detailed security rules  #
#############################

resource "azurerm_network_security_rule" "custom_rules" {
  name                        = "default_rule_name"
  resource_group_name         = azurerm_network_security_group.nsg.resource_group_name
  priority                    = "100"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  description                 = "default_rule_name"
  network_security_group_name = azurerm_network_security_group.nsg.name
}


#############################
# Attach NSG to interface

resource "azurerm_network_interface_security_group_association" "example" {

  for_each = {
    for f in var.firewalls :
    f.name => f
  }

  network_interface_id = [
    for i in each.value.interfaces :
    azurerm_network_interface.nic[i.name].id
  ][0]
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on                = [azurerm_network_interface.nic]
}

//resource "azurerm_network_interface_security_group_association" "exmple2" {
//
//    for_each = {
//    for f in var.firewalls :
//    f.name => f
//  }
//
//  network_interface_id      = [
//    for i in each.value.interfaces :
//    azurerm_network_interface.nic[i.name].id
//    ][1]
//  network_security_group_id = azurerm_network_security_group.nsg.id
//  depends_on = [azurerm_network_interface.nic]
//}
//
//resource "azurerm_network_interface_security_group_association" "example3" {
//
//    for_each = {
//    for f in var.firewalls :
//    f.name => f
//  }
//
//  network_interface_id      = [
//    for i in each.value.interfaces :
//    azurerm_network_interface.nic[i.name].id
//    ][2]
//  network_security_group_id = azurerm_network_security_group.nsg.id
//  depends_on = [azurerm_network_interface.nic]
//}
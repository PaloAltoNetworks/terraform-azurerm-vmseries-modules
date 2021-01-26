resource "azurerm_resource_group" "rg" {
  name     = "${var.name_prefix}${var.sep}${var.name_rg}"
  location = var.location
}

# Create the out-of-band network for managing Panorama.
resource "azurerm_virtual_network" "vnet-panorama-mgmt" {
  address_space       = ["${var.management_vnet_prefix}0.0/16"]
  name                = "${var.name_prefix}${var.sep}${var.name_vnet_panorama_mgmt}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "sg-panorama-mgmt" {
  name                = "${var.name_prefix}${var.sep}${var.name_panorama_sg}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "panorama-mgmt-sa" {
  network_security_group_id = azurerm_network_security_group.sg-panorama-mgmt.id
  subnet_id                 = azurerm_subnet.subnet-panorama-mgmt.id
}

resource "azurerm_subnet" "subnet-panorama-mgmt" {
  name                 = "${var.name_prefix}${var.sep}${var.name_panorama_subnet_mgmt}"
  address_prefixes     = ["${var.management_vnet_prefix}${var.management_subnet}"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-panorama-mgmt.name
}

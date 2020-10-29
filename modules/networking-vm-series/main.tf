/*
* networking terraform module
* ===========
* 
* A terraform module for creating all the networking components required for VM series firewalls in Azure.
* 
* Usage
* -----
* 
* ```hcl
* module "networks" {
*   source         = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/networking-vm-series"
*   location    = "Australia Central"
*   name_prefix = "panostf"
*   management_ips = {
*       "124.171.153.28" : 100,
*     }
* }
* ```
*/
resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "${var.name_prefix}${var.sep}${var.name_rg}"
}

### Now build the main networks
resource "azurerm_virtual_network" "vnet-vmseries" {
  address_space       = ["${var.firewall_vnet_prefix}0.0/16"]
  location            = azurerm_resource_group.rg.location
  name                = "${var.name_prefix}${var.sep}${var.name_vnet_vmseries}"
  resource_group_name = azurerm_resource_group.rg.name
}
# Management for VM-series
resource "azurerm_subnet" "subnet-mgmt" {
  name                 = "${var.name_prefix}${var.sep}${var.name_subnet_mgmt}"
  address_prefixes     = ["${var.firewall_vnet_prefix}${var.vm_management_subnet}"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-vmseries.name
}
resource "azurerm_network_security_group" "sg-mgmt" {
  location            = azurerm_resource_group.rg.location
  name                = "${var.name_prefix}${var.sep}${var.name_sg_mgmt}"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet_network_security_group_association" "mgmt-sa" {
  network_security_group_id = azurerm_network_security_group.sg-mgmt.id
  subnet_id                 = azurerm_subnet.subnet-mgmt.id
}

# private network - don't need NSG here?
resource "azurerm_subnet" "subnet-inside" {
  name                 = "${var.name_prefix}${var.sep}${var.name_subnet_inside}"
  address_prefixes     = ["${var.firewall_vnet_prefix}${var.private_subnet}"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-vmseries.name
}

# Public network
resource "azurerm_network_security_group" "sg-allowall" {
  location            = azurerm_resource_group.rg.location
  name                = "${var.name_prefix}${var.sep}${var.name_sg_allowall}"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "subnet-outside" {
  name                 = "${var.name_prefix}${var.sep}${var.name_subnet_outside}"
  address_prefixes     = ["${var.firewall_vnet_prefix}${var.public_subnet}"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-vmseries.name
}
resource "azurerm_subnet_network_security_group_association" "sg-outside-associate" {
  network_security_group_id = azurerm_network_security_group.sg-allowall.id
  subnet_id                 = azurerm_subnet.subnet-outside.id
}

resource "azurerm_subnet_network_security_group_association" "sg-inside-associate" {
  network_security_group_id = azurerm_network_security_group.sg-allowall.id
  subnet_id                 = azurerm_subnet.subnet-inside.id
}

resource "azurerm_route_table" "udr-inside" {
  location            = var.location
  name                = "${var.name_prefix}${var.sep}${var.name_udr_inside}"
  resource_group_name = azurerm_resource_group.rg.name
  route {
    address_prefix         = "0.0.0.0/0"
    name                   = "default"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.olb_private_ip
  }
}

# asssign the route table to the remote/spoke VNET
resource "azurerm_subnet_route_table_association" "rta" {
  route_table_id = azurerm_route_table.udr-inside.id
  subnet_id      = azurerm_subnet.subnet-inside.id
}



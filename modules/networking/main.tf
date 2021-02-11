data "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

### Build the Panorama networks first
# Create the out of band network for panorama
resource "azurerm_virtual_network" "vnet-panorama-mgmt" {
  name                = "${var.name_prefix}${var.sep}${var.name_vnet_panorama_mgmt}"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  address_space       = ["${var.management_vnet_prefix}0.0/16"]
}

# Security group for the Panorama MGMT network
resource "azurerm_network_security_group" "sg-panorama-mgmt" {
  name                = "${var.name_prefix}${var.sep}${var.name_panorama_sg}"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "panorama-mgmt-sa" {
  network_security_group_id = azurerm_network_security_group.sg-panorama-mgmt.id
  subnet_id                 = azurerm_subnet.subnet-panorama-mgmt.id
}

resource "azurerm_subnet" "subnet-panorama-mgmt" {
  name                 = "${var.name_prefix}${var.sep}${var.name_panorama_subnet_mgmt}"
  resource_group_name  = data.azurerm_resource_group.this.name
  address_prefixes     = ["${var.management_vnet_prefix}${var.management_subnet}"]
  virtual_network_name = azurerm_virtual_network.vnet-panorama-mgmt.name
}

### Now build the main networks
resource "azurerm_virtual_network" "vnet-vmseries" {
  name                = "${var.name_prefix}${var.sep}${var.name_vnet_vmseries}"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  address_space       = ["${var.firewall_vnet_prefix}0.0/16"]
}

# Management for VM-series
resource "azurerm_subnet" "subnet-mgmt" {
  name                 = "${var.name_prefix}${var.sep}${var.name_subnet_mgmt}"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["${var.firewall_vnet_prefix}${var.vm_management_subnet}"]
  virtual_network_name = azurerm_virtual_network.vnet-vmseries.name

}

resource "azurerm_network_security_group" "sg-mgmt" {
  name                = "${var.name_prefix}${var.sep}${var.name_sg_mgmt}"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "mgmt-sa" {
  network_security_group_id = azurerm_network_security_group.sg-mgmt.id
  subnet_id                 = azurerm_subnet.subnet-mgmt.id
}

# Private network - don't need NSG here?
resource "azurerm_subnet" "subnet-inside" {
  name                 = "${var.name_prefix}${var.sep}${var.name_subnet_inside}"
  resource_group_name  = data.azurerm_resource_group.this.name
  address_prefixes     = ["${var.firewall_vnet_prefix}${var.private_subnet}"]
  virtual_network_name = azurerm_virtual_network.vnet-vmseries.name
}

# Public network.
resource "azurerm_network_security_group" "sg-allowall" {
  name                = "${var.name_prefix}${var.sep}${var.name_sg_allowall}"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_subnet" "subnet-outside" {
  name                 = "${var.name_prefix}${var.sep}${var.name_subnet_outside}"
  resource_group_name  = data.azurerm_resource_group.this.name
  address_prefixes     = ["${var.firewall_vnet_prefix}${var.public_subnet}"]
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
  name                = "${var.name_prefix}${var.sep}${var.name_udr_inside}"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  route {
    address_prefix         = "0.0.0.0/0"
    name                   = "default"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.olb_private_ip
  }
}

# Assign the route table to the remote/spoke VNET.
resource "azurerm_subnet_route_table_association" "rta" {
  route_table_id = azurerm_route_table.udr-inside.id
  subnet_id      = azurerm_subnet.subnet-inside.id
}

# Peer the VNETs from the vm-series and panorama module.
resource "azurerm_virtual_network_peering" "panorama-fw-peer" {
  name                      = "${var.name_prefix}${var.sep}${var.name_panorama_fw_peer}"
  resource_group_name       = data.azurerm_resource_group.this.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-panorama-mgmt.id
  virtual_network_name      = azurerm_virtual_network.vnet-vmseries.name
}

resource "azurerm_virtual_network_peering" "fw-panorama-peer" {
  name                      = "${var.name_prefix}${var.sep}${var.name_fw_panorama_peer}"
  resource_group_name       = data.azurerm_resource_group.this.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-vmseries.id
  virtual_network_name      = azurerm_virtual_network.vnet-panorama-mgmt.name
}

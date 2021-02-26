data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  address_space       = var.address_space
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_network_security_group" "this" {
  for_each = var.network_security_groups

  name                = each.key
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_network_security_rule" "this" {
  for_each = var.network_security_rules

  name                        = each.key
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = each.value.network_security_group_name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix

  depends_on = [azurerm_network_security_group.this]
}

resource "azurerm_route_table" "this" {
  for_each = var.route_tables

  name                = each.key
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_route" "this" {
  for_each = var.routes

  name                = each.key
  resource_group_name = data.azurerm_resource_group.this.name
  route_table_name    = each.value.route_table_name
  address_prefix      = each.value.address_prefix
  next_hop_type       = each.value.next_hop_type

  depends_on = [azurerm_route_table.this]
}

locals {
  subnet_id = {
    for subnet in azurerm_subnet.this : subnet.name => subnet.id
  }
  nsg_id = {
    for nsg in azurerm_network_security_group.this : nsg.name => nsg.id
  }
  rt_id = {
    for rt in azurerm_route_table.this : rt.name => rt.id
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = var.nsg_ids
  subnet_id                 = local.subnet_id[each.key]
  network_security_group_id = local.nsg_id[each.value]
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = var.rt_ids

  subnet_id      = local.subnet_id[each.key]
  route_table_id = local.rt_id[each.value]
}

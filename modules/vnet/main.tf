data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  location            = coalesce(var.location, data.azurerm_resource_group.this.location)
  resource_group_name = data.azurerm_resource_group.this.name
  address_space       = var.address_space
  tags                = var.tags
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
  location            = try(each.value.location, data.azurerm_resource_group.this.location)
  resource_group_name = data.azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "this" {
  for_each = var.network_security_rules

  name                        = each.key
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.this[each.value.network_security_group_name].name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
}

resource "azurerm_route_table" "this" {
  for_each = var.route_tables

  name                = each.key
  location            = try(each.value.location, data.azurerm_resource_group.this.location)
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_route" "this" {
  for_each = var.routes

  name                = each.key
  resource_group_name = data.azurerm_resource_group.this.name
  route_table_name    = each.value.route_table_name # fixme
  address_prefix      = each.value.address_prefix
  next_hop_type       = each.value.next_hop_type

  depends_on = [azurerm_route_table.this] # remove?
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.value.network_security_group_id].id
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = var.subnets

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = azurerm_route_table.this[each.value.route_table_id].id
}

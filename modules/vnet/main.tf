resource "azurerm_virtual_network" "this" {
  count = var.create_virtual_network ? 1 : 0

  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

data "azurerm_virtual_network" "this" {
  count = var.create_virtual_network == false ? 1 : 0

  resource_group_name = var.resource_group_name
  name                = var.virtual_network_name
}

locals {
  virtual_network = var.create_virtual_network ? azurerm_virtual_network.this[0] : data.azurerm_virtual_network.this[0]
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_network_security_group" "this" {
  for_each = var.network_security_groups

  name                = each.key
  location            = try(each.value.location, var.location)
  resource_group_name = var.resource_group_name
  tags                = var.tags


  dynamic "security_rule" {
    for_each = each.value.rules

    content {
      name                         = security_rule.key
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      source_port_range            = security_rule.value.source_port_range
      destination_port_range       = security_rule.value.destination_port_range
      source_address_prefix        = lookup(security_rule.value, "source_address_prefix", null)
      source_address_prefixes      = lookup(security_rule.value, "source_address_prefixes", null)
      destination_address_prefix   = lookup(security_rule.value, "destination_address_prefix", null)
      destination_address_prefixes = lookup(security_rule.value, "destination_address_prefixes", null)
    }
  }

}

resource "azurerm_route_table" "this" {
  for_each = var.route_tables

  name                = each.key
  location            = try(each.value.location, var.location)
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

locals {
  route = flatten([
    for route_table_name, route_table in var.route_tables : [
      for route_name, route in route_table.routes : {
        route_table_name = route_table_name
        name             = route_name
        route            = route
      }
    ]
  ])
}

resource "azurerm_route" "this" {
  for_each = {
    for route in local.route : "${route.route_table_name}-${route.name}" => route
  }

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.this[each.value.route_table_name].name
  address_prefix         = each.value.route.address_prefix
  next_hop_type          = each.value.route.next_hop_type
  next_hop_in_ip_address = try(each.value.route.next_hop_in_ip_address, null)
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = { for k, v in var.subnets : k => v if lookup(v, "network_security_group", "") != "" }

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.value.network_security_group].id
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = { for k, v in var.subnets : k => v if lookup(v, "route_table", "") != "" }

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = azurerm_route_table.this[each.value.route_table].id
}

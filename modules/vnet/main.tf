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

locals {
  nsg_rules = flatten([
    for nsg_name, nsg in var.network_security_groups : [
      for rule_name, rule in nsg.rules : {
        nsg_name = nsg_name
        name     = rule_name
        rule     = rule
      }
    ]
  ])
}

resource "azurerm_network_security_rule" "this" {
  for_each = {
    for nsg in local.nsg_rules : "${nsg.nsg_name}-${nsg.name}" => nsg
  }

  name                        = each.value.name
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.this[each.value.nsg_name].name
  priority                    = each.value.rule.priority
  direction                   = each.value.rule.direction
  access                      = each.value.rule.access
  protocol                    = each.value.rule.protocol
  source_port_range           = each.value.rule.source_port_range
  destination_port_range      = each.value.rule.destination_port_range
  source_address_prefix       = each.value.rule.source_address_prefix
  destination_address_prefix  = each.value.rule.destination_address_prefix
}

resource "azurerm_route_table" "this" {
  for_each = var.route_tables

  name                = each.key
  location            = try(each.value.location, data.azurerm_resource_group.this.location)
  resource_group_name = data.azurerm_resource_group.this.name
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

  name                = each.value.name
  resource_group_name = data.azurerm_resource_group.this.name
  route_table_name    = azurerm_route_table.this[each.value.route_table_name].name
  address_prefix      = each.value.route.address_prefix
  next_hop_type       = each.value.route.next_hop_type
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

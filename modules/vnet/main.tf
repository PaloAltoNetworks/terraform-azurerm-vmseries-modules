resource "azurerm_virtual_network" "this" {
  count = var.create_virtual_network ? 1 : 0

  name                = "${var.name_prefix}${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

data "azurerm_virtual_network" "this" {
  count = var.create_virtual_network == false ? 1 : 0

  resource_group_name = var.resource_group_name
  name                = var.name
}

locals {
  virtual_network = var.create_virtual_network ? azurerm_virtual_network.this[0] : data.azurerm_virtual_network.this[0]
}

resource "azurerm_subnet" "this" {
  for_each = { for k, v in var.subnets : k => v if var.create_subnets }

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = try(each.value.enable_storage_service_endpoint, false) ? ["Microsoft.Storage"] : null
}

data "azurerm_subnet" "this" {
  for_each = { for k, v in var.subnets : k => v if var.create_subnets == false }

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = local.virtual_network.name
}

locals {
  subnets = var.create_subnets ? azurerm_subnet.this : data.azurerm_subnet.this
}

resource "azurerm_network_security_group" "this" {
  for_each = var.network_security_groups

  name                = "${var.name_prefix}${each.value.name}"
  location            = try(each.value.location, var.location)
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

locals {
  nsg_rules = flatten([
    for nsg_key, nsg in var.network_security_groups : [
      for rule_name, rule in lookup(nsg, "rules", {}) : {
        nsg_key   = nsg_key
        nsg_name  = nsg.name
        rule_name = rule_name
        rule      = rule
      }
    ]
  ])
}

resource "azurerm_network_security_rule" "this" {
  for_each = {
    for nsg in local.nsg_rules : "${nsg.nsg_key}-${nsg.rule_name}" => nsg
  }

  name                         = each.value.rule_name
  resource_group_name          = var.resource_group_name
  network_security_group_name  = azurerm_network_security_group.this[each.value.nsg_key].name
  priority                     = each.value.rule.priority
  direction                    = each.value.rule.direction
  access                       = each.value.rule.access
  protocol                     = each.value.rule.protocol
  source_port_range            = try(each.value.rule.source_port_range, null)
  source_port_ranges           = try(each.value.rule.source_port_ranges, null)
  destination_port_range       = try(each.value.rule.destination_port_range, null)
  destination_port_ranges      = try(each.value.rule.destination_port_ranges, null)
  source_address_prefix        = try(each.value.rule.source_address_prefix, null)
  source_address_prefixes      = try(each.value.rule.source_address_prefixes, null)
  destination_address_prefix   = try(each.value.rule.destination_address_prefix, null)
  destination_address_prefixes = try(each.value.rule.destination_address_prefixes, null)

  depends_on = [azurerm_network_security_group.this]
}

resource "azurerm_route_table" "this" {
  for_each = var.route_tables

  name                = "${var.name_prefix}${each.value.name}"
  location            = try(each.value.location, var.location)
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

locals {
  route = flatten([
    for route_table_key, route_table in var.route_tables : [
      for route_name, route in route_table.routes : {
        route_table_name = route_table.name
        route_table_key  = route_table_key
        route_name       = route_name
        route            = route
      }
    ]
  ])
}

resource "azurerm_route" "this" {
  for_each = {
    for route in local.route : "${route.route_table_key}-${route.route_name}" => route
  }

  name                   = each.value.route_name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.this[each.value.route_table_key].name
  address_prefix         = each.value.route.address_prefix
  next_hop_type          = each.value.route.next_hop_type
  next_hop_in_ip_address = try(each.value.route.next_hop_in_ip_address, null)
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = { for k, v in var.subnets : k => v if can(v.network_security_group) }

  subnet_id                 = local.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.value.network_security_group].id
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = { for k, v in var.subnets : k => v if can(v.route_table) }

  subnet_id      = local.subnets[each.key].id
  route_table_id = azurerm_route_table.this[each.value.route_table].id
}

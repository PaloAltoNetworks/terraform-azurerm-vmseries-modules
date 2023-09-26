# Create or source the Resource Group.
resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = "${var.name_prefix}${var.resource_group_name}"
  location = var.location

  tags = var.tags
}

data "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

locals {
  resource_group = var.create_resource_group ? azurerm_resource_group.this[0] : data.azurerm_resource_group.this[0]
}

# Manage the network required for the topology.
module "vnet" {
  source = "../../modules/vnet"

  for_each = var.vnets

  name                   = "${var.name_prefix}${each.value.name}"
  create_virtual_network = try(each.value.create_virtual_network, true)
  resource_group_name    = try(each.value.resource_group_name, local.resource_group.name)
  location               = var.location

  address_space = try(each.value.create_virtual_network, true) ? each.value.address_space : []

  create_subnets = try(each.value.create_subnets, true)
  subnets = try(each.value.create_subnets, true) ? {
    for k, v in each.value.subnets : k => merge(v, { name = "${var.name_prefix}${v.name}" })
  } : each.value.subnets

  network_security_groups = { for k, v in try(each.value.network_security_groups, {}) :
    k => merge(v, { name = "${var.name_prefix}${v.name}" })
  }
  route_tables = { for k, v in try(each.value.route_tables, {}) :
    k => merge(v, { name = "${var.name_prefix}${v.name}" })
  }

  tags = var.tags
}

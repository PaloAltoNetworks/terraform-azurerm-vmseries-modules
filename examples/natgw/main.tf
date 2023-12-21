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

  name                   = each.value.create_virtual_network ? "${var.name_prefix}${each.value.name}" : each.value.name
  create_virtual_network = each.value.create_virtual_network
  resource_group_name    = coalesce(each.value.resource_group_name, local.resource_group.name)
  location               = var.location

  address_space = each.value.address_space

  create_subnets = each.value.create_subnets
  subnets        = each.value.subnets

  network_security_groups = { for k, v in each.value.network_security_groups : k => merge(v, { name = "${var.name_prefix}${v.name}" })
  }
  route_tables = { for k, v in each.value.route_tables : k => merge(v, { name = "${var.name_prefix}${v.name}" })
  }

  tags = var.tags
}

module "natgw" {
  source = "../../modules/natgw"

  for_each = var.natgws

  create_natgw        = each.value.create_natgw
  name                = each.value.create_natgw ? "${var.name_prefix}${each.value.name}" : each.value.name
  resource_group_name = coalesce(each.value.resource_group_name, local.resource_group.name)
  location            = var.location
  zone                = try(each.value.zone, null)
  idle_timeout        = each.value.idle_timeout
  subnet_ids          = { for v in each.value.subnet_keys : v => module.vnet[each.value.vnet_key].subnet_ids[v] }

  public_ip        = try(merge(each.value.public_ip, { name = "${each.value.public_ip.create ? var.name_prefix : ""}${each.value.public_ip.name}" }), null)
  public_ip_prefix = try(merge(each.value.public_ip_prefix, { name = "${each.value.public_ip_prefix.create ? var.name_prefix : ""}${each.value.public_ip_prefix.name}" }), null)

  tags       = var.tags
  depends_on = [module.vnet]
}
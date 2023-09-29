# Create or source the Resource Group.
resource "azurerm_resource_group" "this" {
  name     = "${var.name_prefix}${var.resource_group_name}"
  location = var.location

  tags = var.tags
}

# Manage the network required for the topology.
module "vnet" {
  source = "../../../modules/vnet"

  for_each = var.vnets

  name                   = "${var.name_prefix}${each.value.name}"
  create_virtual_network = each.value.create_virtual_network
  resource_group_name    = coalesce(each.value.resource_group_name, azurerm_resource_group.this.name)
  location               = var.location

  address_space = each.value.address_space

  create_subnets = each.value.create_subnets
  subnets = each.value.create_subnets ? {
    for k, v in each.value.subnets : k => merge(v, { name = "${var.name_prefix}${v.name}" })
  } : each.value.subnets

  network_security_groups = { for k, v in each.value.network_security_groups : k => merge(v, { name = "${var.name_prefix}${v.name}" })
  }
  route_tables = { for k, v in each.value.route_tables : k => merge(v, { name = "${var.name_prefix}${v.name}" })
  }

  tags = var.tags
}

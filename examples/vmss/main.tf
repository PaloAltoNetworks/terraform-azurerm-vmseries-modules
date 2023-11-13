resource "random_password" "this" {
  count = var.authentication.password == null ? 1 : 0

  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "_%@"
}

locals {
  password       = coalesce(var.authentication.password, try(random_password.this[0].result, null))
  authentication = merge(var.authentication, { password = local.password })
}

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
  create_virtual_network = each.value.create_virtual_network
  resource_group_name    = coalesce(each.value.resource_group_name, local.resource_group.name)
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

module "vmss" {
  source = "../../modules/vmss"

  for_each = coalesce(var.scale_sets, {})

  name                = "${var.name_prefix}${each.value.name}"
  resource_group_name = local.resource_group.name
  location            = var.location

  authentication          = local.authentication
  scale_set_configuration = each.value.scale_set_configuration
  vm_image_configuration  = var.vm_image_configuration
  interfaces = [
    for v in each.value.interfaces : {
      name                  = v.name
      subnet_id             = module.vnet[v.vnet_key].subnet_ids[v.subnet_key]
      create_public_ip      = v.create_public_ip
      pip_domain_name_label = v.pip_domain_name_label
      # lb_backend_pool_ids    = try([module.load_balancer[v.load_balancer_key].backend_pool_id], [])
      # appgw_backend_pool_ids = try([module.appgw[v.application_gateway_key].backend_pool_id], [])
    }
  ]

  autoscaling_configuration = each.value.autoscaling_configuration
  autoscaling_profiles      = each.value.autoscaling_profiles

  tags = var.tags
}

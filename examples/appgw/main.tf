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

# Create public IP in order to reuse it in 1 of the application gateways
resource "azurerm_public_ip" "this" {
  name                = "pip-existing"
  resource_group_name = local.resource_group.name
  location            = var.location

  sku               = "Standard"
  allocation_method = "Static"
  zones             = ["1", "2", "3"]
  tags              = var.tags
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

# Create Application Gateay
module "appgw" {
  source = "../../modules/appgw"

  for_each = var.appgws

  name                = "${var.name_prefix}${each.value.name}"
  resource_group_name = local.resource_group.name
  location            = var.location

  application_gateway = merge(
    each.value.application_gateway,
    {
      subnet_id = module.vnet[each.value.application_gateway.vnet_key].subnet_ids[each.value.application_gateway.subnet_key]
      public_ip = merge(
        each.value.application_gateway.public_ip,
        {
          name = "${each.value.application_gateway.public_ip.create ? var.name_prefix : ""}${each.value.application_gateway.public_ip.name}"
        }
      )
    }
  )


  listeners     = each.value.listeners
  backends      = each.value.backends
  probes        = each.value.probes
  rewrites      = each.value.rewrites
  rules         = each.value.rules
  redirects     = each.value.redirects
  url_path_maps = each.value.url_path_maps
  ssl_profiles  = each.value.ssl_profiles

  tags       = var.tags
  depends_on = [module.vnet, azurerm_public_ip.this]
}
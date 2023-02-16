# Generate a random password.
resource "random_password" "this" {
  count = var.vmseries_password == null ? 1 : 0

  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "_%@"
}

locals {
  vmseries_password = coalesce(var.vmseries_password, try(random_password.this[0].result, null))
}


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

  create_virtual_network = try(each.value.create_virtual_network, true)
  virtual_network_name   = "${var.name_prefix}${each.key}"
  address_space          = each.value.address_space
  resource_group_name    = try(each.value.resource_group_name, local.resource_group.name)
  location               = var.location

  create_subnets = try(each.value.create_subnets, true)
  subnets        = each.value.subnets

  network_security_groups = each.value.network_security_groups
  route_tables            = each.value.route_tables

  tags = var.tags
}


# create load balancers, both internal and external
module "load_balancer" {
  source = "../../modules/loadbalancer"

  for_each = var.load_balancers

  name                = "${var.name_prefix}${each.key}"
  location            = var.location
  resource_group_name = local.resource_group.name
  enable_zones        = var.enable_zones
  avzones             = try(each.value.avzones, null)

  network_security_resource_group_name = try(var.vnets[each.value.vnet_name].resource_group_name, local.resource_group.name)
  network_security_group_name          = try(each.value.network_security_group_name, null)
  network_security_allow_source_ips    = try(each.value.network_security_allow_source_ips, [])

  frontend_ips = {
    for k, v in each.value.frontend_ips : k => {
      create_public_ip              = try(v.create_public_ip, false)
      public_ip_name                = try(v.public_ip_name, null)
      public_ip_resource_group      = try(v.public_ip_resource_group, null)
      private_ip_address            = try(v.private_ip_address, null)
      private_ip_address_allocation = can(v.private_ip_address) ? "Static" : null
      subnet_id                     = try(module.vnet[v.vnet_name].subnet_ids[v.subnet_name], null)
      rules                         = v.rules
      zones                         = var.enable_zones ? try(v.zones, null) : null # For the regions without AZ support.
    }
  }

  tags       = var.tags
  depends_on = [module.vnet]
}


# create the actual VMSeries VMs
resource "azurerm_availability_set" "this" {
  for_each = var.availability_set

  name                         = "${var.name_prefix}${each.key}"
  resource_group_name          = local.resource_group.name
  location                     = var.location
  platform_update_domain_count = try(each.value.update_domain_count, null)
  platform_fault_domain_count  = try(each.value.fault_domain_count, null)

  tags = var.tags
}


module "vmseries" {
  source = "../../modules/vmseries"

  for_each = var.vmseries

  location            = var.location
  resource_group_name = local.resource_group.name

  name                  = "${var.name_prefix}${each.key}"
  username              = var.vmseries_username
  password              = local.vmseries_password
  img_version           = var.vmseries_version
  img_sku               = var.vmseries_sku
  vm_size               = var.vmseries_vm_size
  avset_id              = try(azurerm_availability_set.this[each.value.availability_set_name].id, null)
  app_insights_settings = try(each.value.app_insights_settings, null)

  enable_zones      = var.enable_zones
  avzone            = try(each.value.avzone, 1)
  bootstrap_options = try(each.value.bootstrap_options, "")

  interfaces = [for v in each.value.interfaces : {
    name                = "${var.name_prefix}${each.key}-${v.name}"
    subnet_id           = lookup(module.vnet[each.value.vnet_name].subnet_ids, v.subnet_name, null)
    create_public_ip    = try(v.create_pip, false)
    enable_backend_pool = can(v.backend_pool_lb_name) ? true : false
    lb_backend_pool_id  = try(module.load_balancer[v.backend_pool_lb_name].backend_pool_id, null)
    private_ip_address  = try(v.private_ip_address, null)
  }]

  tags       = var.tags
  depends_on = [module.vnet, azurerm_availability_set.this]
}

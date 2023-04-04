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
  source = "../modules/vnet"

  for_each = var.vnets

  virtual_network_name   = each.value.name
  name_prefix            = var.name_prefix
  create_virtual_network = try(each.value.create_virtual_network, true)
  resource_group_name    = try(each.value.resource_group_name, local.resource_group.name)
  location               = var.location

  address_space = try(each.value.create_virtual_network, true) ? each.value.address_space : []

  create_subnets = try(each.value.create_subnets, true)
  subnets        = each.value.subnets

  network_security_groups = try(each.value.network_security_groups, {})
  route_tables            = try(each.value.route_tables, {})

  tags = var.tags
}

module "panorama" {
  source  = "PaloAltoNetworks/vmseries-modules/azurerm//modules/panorama"
  version = "0.5.4"

  for_each = var.panoramas

  panorama_name               = "${var.name_prefix}${each.value.name}"
  resource_group_name         = local.resource_group.name
  location                    = var.location
  avzone                      = try(each.value.avzone, null)
  avzones                     = try(each.value.avzones, ["1", "2", "3"])
  enable_zones                = var.enable_zones
  custom_image_id             = try(each.value.custom_image_id, null)
  panorama_sku                = var.panorama_sku
  panorama_size               = var.panorama_size
  panorama_version            = var.panorama_version
  boot_diagnostic_storage_uri = ""

  interface = [{
    name               = "${var.name_prefix}management"
    subnet_id          = lookup(module.vnet[each.value.vnet_name].subnet_ids, each.value.subnet_name, null)
    private_ip_address = try(each.value.private_ip_address, null)
    public_ip          = true
    public_ip_name     = "${var.name_prefix}${each.key}-pip"
  }]

  logging_disks = {
    logs-1 = {
      size : "2048"
      lun : "1"
    }
  }

  username = var.vmseries_username
  password = local.vmseries_password

  tags       = var.tags
  depends_on = [module.vnet]
}
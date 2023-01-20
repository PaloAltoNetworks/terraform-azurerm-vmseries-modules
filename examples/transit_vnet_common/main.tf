# Create the Resource Group.
resource "azurerm_resource_group" "this" {
  name     = "${var.name_prefix}${var.resource_group_name}"
  location = var.location
}

# Generate a random password.
resource "random_password" "this" {
  count = var.password == null ? 1 : 0

  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  special          = true
  override_special = "_%@"
}

locals {
  password = coalesce(var.password, try(random_password.this[0].result, null))
}

# Create the network required for the topology.
module "vnet" {
  source = "../../modules/vnet"

  virtual_network_name    = var.virtual_network_name
  location                = var.location
  resource_group_name     = azurerm_resource_group.this.name
  address_space           = var.address_space
  network_security_groups = var.network_security_groups
  route_tables            = var.route_tables
  subnets                 = var.subnets

  tags = var.tags
}

module "load_balancer" {
  source = "../../modules/loadbalancer"

  for_each = var.load_balancers

  name                = "${var.name_prefix}${each.key}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  enable_zones        = var.enable_zones
  avzones             = try(each.value.avzones, null)

  network_security_resource_group_name = azurerm_resource_group.this.name
  network_security_group_name          = try(each.value.network_security_group_name, null)
  network_security_allow_source_ips    = try(each.value.network_security_allow_source_ips, [])

  frontend_ips = {
    for k, v in each.value.frontend_ips : k => {
      create_public_ip              = try(v.create_public_ip, false)
      public_ip_name                = try(v.public_ip_name, null)
      public_ip_resource_group      = try(v.public_ip_resource_group, null)
      private_ip_address            = try(v.private_ip_address, null)
      private_ip_address_allocation = can(v.private_ip_address) ? "Static" : null
      subnet_id                     = try(module.vnet.subnet_ids[v.subnet_name], null)
      rules                         = v.rules
      zones                         = var.enable_zones ? try(v.zones, null) : null # For the regions without AZ support.
    }
  }

  tags       = var.tags
  depends_on = [module.vnet]
}


# # Common VM-Series for handling:
# #   - inbound traffic from the Internet
# #   - outbound traffic to the Internet
# #   - internal traffic (also known as "east-west" traffic)
module "vmseries" {
  source = "../../modules/vmseries"

  for_each = var.vmseries

  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  name                  = "${var.name_prefix}${each.key}"
  username              = var.username
  password              = local.password
  img_version           = var.vmseries_version
  img_sku               = var.vmseries_sku
  vm_size               = var.vmseries_vm_size
  app_insights_settings = try(each.value.app_insights_settings, null)

  enable_zones      = var.enable_zones
  avzone            = try(each.value.avzone, 1)
  bootstrap_options = try(each.value.bootstrap_options, "")

  interfaces = [for v in each.value.interfaces : {
    name                = "${each.key}-${v.name}"
    subnet_id           = lookup(module.vnet.subnet_ids, v.subnet_name, null)
    create_public_ip    = try(v.create_pip, false)
    enable_backend_pool = can(v.backend_pool_lb_name) ? true : false
    lb_backend_pool_id  = try(module.load_balancer[v.backend_pool_lb_name].backend_pool_id, null)
    private_ip_address  = try(v.private_ip_address, null)
  }]

  tags       = var.tags
  depends_on = [module.vnet, module.load_balancer]
}
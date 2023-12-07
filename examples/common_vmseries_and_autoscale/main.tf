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
  vmseries_password               = coalesce(var.vmseries_password, try(random_password.this[0].result, null))
  disable_password_authentication = local.vmseries_password == null ? true : false
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

  create_natgw        = try(each.value.create_natgw, true)
  name                = "${var.name_prefix}${each.value.name}"
  resource_group_name = try(each.value.resource_group_name, local.resource_group.name)
  location            = var.location
  zone                = try(each.value.zone, null)
  idle_timeout        = try(each.value.idle_timeout, null)
  subnet_ids          = { for v in each.value.subnet_keys : v => module.vnet[each.value.vnet_key].subnet_ids[v] }

  create_pip                       = try(each.value.create_pip, true)
  existing_pip_name                = try(each.value.existing_pip_name, null)
  existing_pip_resource_group_name = try(each.value.existing_pip_resource_group_name, null)

  create_pip_prefix                       = try(each.value.create_pip_prefix, false)
  pip_prefix_length                       = try(each.value.create_pip_prefix, false) ? try(each.value.pip_prefix_length, null) : null
  existing_pip_prefix_name                = try(each.value.existing_pip_prefix_name, null)
  existing_pip_prefix_resource_group_name = try(each.value.existing_pip_prefix_resource_group_name, null)


  tags       = var.tags
  depends_on = [module.vnet]
}



# create load balancers, both internal and external
module "load_balancer" {
  source = "../../modules/loadbalancer"

  for_each = var.load_balancers

  name                = "${var.name_prefix}${each.value.name}"
  location            = var.location
  resource_group_name = local.resource_group.name
  zones               = each.value.zones

  health_probes = each.value.health_probes

  nsg_auto_rules_settings = try(
    {
      nsg_name = try(
        "${var.name_prefix}${var.vnets[each.value.nsg_auto_rules_settings.nsg_vnet_key].network_security_groups[each.value.nsg_auto_rules_settings.nsg_key].name}",
        each.value.nsg_auto_rules_settings.nsg_name
      )
      nsg_resource_group_name = try(
        var.vnets[each.value.nsg_auto_rules_settings.nsg_vnet_key].resource_group_name,
        each.value.nsg_auto_rules_settings.nsg_resource_group_name,
        null
      )
      source_ips    = each.value.nsg_auto_rules_settings.source_ips
      base_priority = each.value.nsg_auto_rules_settings.base_priority
    },
    null
  )

  frontend_ips = {
    for k, v in each.value.frontend_ips : k => merge(
      v,
      {
        public_ip_name = v.create_public_ip ? "${var.name_prefix}${v.public_ip_name}" : "${v.public_ip_name}",
        subnet_id      = try(module.vnet[v.vnet_key].subnet_ids[v.subnet_key], null)
      }
    )
  }

  tags       = var.tags
  depends_on = [module.vnet]
}


# Create the scale sets and related resources.
module "ai" {
  source = "../../modules/application_insights"

  for_each = { for k, v in var.vmss : k => "${v.name}-ai" if can(v.autoscale_metrics) }

  name                = "${var.name_prefix}${each.value}"
  resource_group_name = local.resource_group.name
  location            = var.location

  workspace_mode            = try(var.application_insights.workspace_mode, null)
  workspace_name            = try(var.application_insights.workspace_name, "${var.name_prefix}${each.key}-wrkspc")
  workspace_sku             = try(var.application_insights.workspace_sku, null)
  metrics_retention_in_days = try(var.application_insights.metrics_retention_in_days, null)

  tags = var.tags
}

module "appgw" {
  source = "../../modules/appgw"

  for_each = var.appgws

  name                = each.value.name
  public_ip           = each.value.public_ip
  resource_group_name = local.resource_group.name
  location            = var.location
  subnet_id           = module.vnet[each.value.vnet_key].subnet_ids[each.value.subnet_key]

  managed_identities = each.value.managed_identities
  capacity           = each.value.capacity
  waf                = each.value.waf
  enable_http2       = each.value.enable_http2
  zones              = each.value.zones

  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  listeners                      = each.value.listeners
  backend_pool                   = each.value.backend_pool
  backends                       = each.value.backends
  probes                         = each.value.probes
  rewrites                       = each.value.rewrites
  rules                          = each.value.rules
  redirects                      = each.value.redirects
  url_path_maps                  = each.value.url_path_maps

  ssl_global   = each.value.ssl_global
  ssl_profiles = each.value.ssl_profiles

  tags       = var.tags
  depends_on = [module.vnet]
}

module "vmss" {
  source = "../../modules/vmss"

  for_each = var.vmss

  name                = "${var.name_prefix}${each.value.name}"
  resource_group_name = local.resource_group.name
  location            = var.location

  username                        = var.vmseries_username
  password                        = local.vmseries_password
  disable_password_authentication = local.disable_password_authentication
  img_sku                         = var.vmseries_sku
  img_version                     = try(each.value.version, var.vmseries_version)
  vm_size                         = try(each.value.vm_size, var.vmseries_vm_size)
  zone_balance                    = var.enable_zones
  zones                           = var.enable_zones ? try(each.value.zones, null) : []

  encryption_at_host_enabled   = try(each.value.encryption_at_host_enabled, null)
  overprovision                = try(each.value.overprovision, null)
  platform_fault_domain_count  = try(each.value.platform_fault_domain_count, null)
  proximity_placement_group_id = try(each.value.proximity_placement_group_id, null)
  scale_in_policy              = try(each.value.scale_in_policy, null)
  scale_in_force_deletion      = try(each.value.scale_in_force_deletion, null)
  single_placement_group       = try(each.value.single_placement_group, null)
  storage_account_type         = try(each.value.storage_account_type, null)
  disk_encryption_set_id       = try(each.value.disk_encryption_set_id, null)
  use_custom_image             = try(each.value.use_custom_image, false)
  custom_image_id              = try(each.value.use_custom_image, false) ? each.value.custom_image_id : null

  accelerated_networking = try(each.value.accelerated_networking, null)
  interfaces = [
    for v in each.value.interfaces : {
      name                   = v.name
      subnet_id              = module.vnet[each.value.vnet_key].subnet_ids[v.subnet_key]
      create_pip             = try(v.create_pip, false)
      pip_domain_name_label  = try(v.pip_domain_name_label, null)
      lb_backend_pool_ids    = try([module.load_balancer[v.load_balancer_key].backend_pool_id], [])
      appgw_backend_pool_ids = try([module.appgw[v.application_gateway_key].backend_pool_id], [])
    }
  ]

  bootstrap_options = each.value.bootstrap_options

  application_insights_id = can(each.value.autoscale_metrics) ? module.ai[each.key].application_insights_id : null

  autoscale_count_default       = try(each.value.autoscale_config.count_default, null)
  autoscale_count_minimum       = try(each.value.autoscale_config.count_minimum, null)
  autoscale_count_maximum       = try(each.value.autoscale_config.count_maximum, null)
  autoscale_notification_emails = try(each.value.autoscale_config.notification_emails, null)

  autoscale_metrics = try(each.value.autoscale_metrics, {})

  scaleout_statistic        = try(each.value.scaleout_config.statistic, null)
  scaleout_time_aggregation = try(each.value.scaleout_config.time_aggregation, null)
  scaleout_window_minutes   = try(each.value.scaleout_config.window_minutes, null)
  scaleout_cooldown_minutes = try(each.value.scaleout_config.cooldown_minutes, null)

  scalein_statistic        = try(each.value.scalein_config.statistic, null)
  scalein_time_aggregation = try(each.value.scalein_config.time_aggregation, null)
  scalein_window_minutes   = try(each.value.scalein_config.window_minutes, null)
  scalein_cooldown_minutes = try(each.value.scalein_config.cooldown_minutes, null)

  tags = var.tags

  depends_on = [
    module.ai,
    module.vnet,
    module.appgw
  ]
}

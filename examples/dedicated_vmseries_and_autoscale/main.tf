# Generate a random password.
resource "random_password" "this" {
  count = anytrue([
    for _, v in var.scale_sets : v.authentication.password == null
  ]) ? 1 : 0

  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "_%@"
}

locals {
  authentication = {
    for k, v in var.scale_sets : k =>
    merge(
      v.authentication,
      { password = coalesce(v.authentication.password, try(random_password.this[0].result, null)) }
    )
  }
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

module "ngfw_metrics" {
  source = "../../modules/ngfw_metrics"

  count = var.ngfw_metrics != null && anytrue([for _, v in var.scale_sets : length(v.autoscaling_profiles) > 0]) ? 1 : 0

  create_workspace = var.ngfw_metrics.create_workspace

  name                = "${var.ngfw_metrics.create_workspace ? var.name_prefix : ""}${var.ngfw_metrics.name}"
  resource_group_name = var.ngfw_metrics.create_workspace ? local.resource_group.name : coalesce(var.ngfw_metrics.resource_group_name, local.resource_group.name)
  location            = var.location

  log_analytics_config = {
    sku                       = var.ngfw_metrics.sku
    metrics_retention_in_days = var.ngfw_metrics.metrics_retention_in_days
  }

  application_insights = { for k, v in var.scale_sets : k => { name = "${var.name_prefix}${v.name}-ai" } }

  tags = var.tags
}

module "appgw" {
  source = "../../modules/appgw"

  for_each = var.appgws

  name                = "${var.name_prefix}${each.value.name}"
  resource_group_name = local.resource_group.name
  location            = var.location
  subnet_id           = module.vnet[each.value.vnet_key].subnet_ids[each.value.subnet_key]

  managed_identities = try(each.value.managed_identities, null)
  waf_enabled        = try(each.value.waf_enabled, false)
  capacity           = try(each.value.capacity, null)
  capacity_min       = try(each.value.capacity_min, null)
  capacity_max       = try(each.value.capacity_max, null)
  enable_http2       = try(each.value.enable_http2, null)
  zones              = try(each.value.zones, null)

  rules = each.value.rules

  ssl_policy_type                 = try(each.value.ssl_policy_type, null)
  ssl_policy_name                 = try(each.value.ssl_policy_name, null)
  ssl_policy_min_protocol_version = try(each.value.ssl_policy_min_protocol_version, null)
  ssl_policy_cipher_suites        = try(each.value.ssl_policy_cipher_suites, [])
  ssl_profiles                    = try(each.value.ssl_profiles, {})

  tags       = var.tags
  depends_on = [module.vnet]
}

module "vmss" {
  source = "../../modules/vmss"

  for_each = var.scale_sets

  name                = "${var.name_prefix}${each.value.name}"
  resource_group_name = local.resource_group.name
  location            = var.location

  authentication            = local.authentication[each.key]
  virtual_machine_scale_set = each.value.virtual_machine_scale_set
  image                     = each.value.image

  interfaces = [
    for v in each.value.interfaces : {
      name                   = v.name
      subnet_id              = module.vnet[each.value.virtual_machine_scale_set.vnet_key].subnet_ids[v.subnet_key]
      create_public_ip       = v.create_public_ip
      pip_domain_name_label  = v.pip_domain_name_label
      lb_backend_pool_ids    = try([module.load_balancer[v.load_balancer_key].backend_pool_id], [])
      appgw_backend_pool_ids = try([module.appgw[v.application_gateway_key].backend_pool_id], [])
    }
  ]

  autoscaling_configuration = merge(
    each.value.autoscaling_configuration,
    { application_insights_id = try(module.ngfw_metrics[0].application_insights_ids[each.key], null) }
  )
  autoscaling_profiles = each.value.autoscaling_profiles

  tags = var.tags
}

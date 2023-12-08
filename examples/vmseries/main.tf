# Generate a random password.
resource "random_password" "this" {
  count = anytrue([
    for _, v in var.vmseries : v.authentication.password == null
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
    for k, v in var.vmseries : k =>
    merge(
      v.authentication,
      {
        ssh_keys = [for ssh_key in v.authentication.ssh_keys : file(ssh_key)]
        password = coalesce(v.authentication.password, try(random_password.this[0].result, null))
      }
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



# create the actual VMSeries VMs and resources
# module "ai" {
#   source = "../../modules/application_insights"

#   for_each = toset(
#     var.application_insights != null ? flatten(
#       try([var.application_insights.name], [for _, v in var.vmseries : "${v.name}-ai"])
#     ) : []
#   )

#   name                = "${var.name_prefix}${each.key}"
#   resource_group_name = local.resource_group.name
#   location            = var.location

#   workspace_mode            = try(var.application_insights.workspace_mode, null)
#   workspace_name            = try(var.application_insights.workspace_name, "${var.name_prefix}${each.key}-wrkspc")
#   workspace_sku             = try(var.application_insights.workspace_sku, null)
#   metrics_retention_in_days = try(var.application_insights.metrics_retention_in_days, null)

#   tags = var.tags
# }

# resource "local_file" "bootstrap_xml" {
#   for_each = { for k, v in var.vmseries : k => v if can(v.bootstrap_storage.template_bootstrap_xml) }

#   filename = "files/${each.value.name}-bootstrap.xml"
#   content = templatefile(
#     each.value.bootstrap_storage.template_bootstrap_xml,
#     {
#       private_azure_router_ip = cidrhost(
#         try(
#           module.vnet[each.value.vnet_key].subnet_cidrs[each.value.bootstrap_storage.private_snet_key],
#           module.vnet[each.value.vnet_key].subnet_cidrs[var.bootstrap_storage[each.value.bootstrap_storage.name].private_snet_key]
#         ),
#         1
#       )

#       public_azure_router_ip = cidrhost(
#         try(
#           module.vnet[each.value.vnet_key].subnet_cidrs[each.value.bootstrap_storage.public_snet_key],
#           module.vnet[each.value.vnet_key].subnet_cidrs[var.bootstrap_storage[each.value.bootstrap_storage.name].public_snet_key]
#         ),
#         1
#       )

#       ai_instr_key = try(module.ai[try(var.application_insights.name, "${each.value.name}-ai")].metrics_instrumentation_key, null)

#       ai_update_interval = try(
#         each.value.bootstrap_storage.ai_update_interval,
#         var.bootstrap_storage[each.value.bootstrap_storage.name].ai_update_interval,
#         5
#       )

#       private_network_cidr = try(
#         each.value.bootstrap_storage.intranet_cidr,
#         var.bootstrap_storage[each.value.bootstrap_storage.name].intranet_cidr,
#         module.vnet[each.value.vnet_key].vnet_cidr[0]
#       )

#       mgmt_profile_appgw_cidr = flatten([
#         for _, v in var.appgws : var.vnets[v.vnet_key].subnets[v.subnet_key].address_prefixes
#       ])
#     }
#   )

#   depends_on = [
#     module.ai,
#     module.vnet
#   ]
# }




resource "azurerm_availability_set" "this" {
  for_each = var.availability_sets

  name                         = "${var.name_prefix}${each.value.name}"
  resource_group_name          = local.resource_group.name
  location                     = var.location
  platform_update_domain_count = try(each.value.update_domain_count, null)
  platform_fault_domain_count  = try(each.value.fault_domain_count, null)

  tags = var.tags
}

module "vmseries" {
  source = "../../modules/vmseries"

  for_each = var.vmseries

  name                = "${var.name_prefix}${each.value.name}"
  location            = var.location
  resource_group_name = local.resource_group.name

  authentication = local.authentication[each.key]
  image          = each.value.image
  virtual_machine = merge(
    each.value.virtual_machine,
    {
      disk_name = coalesce(each.value.virtual_machine.disk_name, "${var.name_prefix}${each.value.name}-osdisk")
      avset_id  = try(azurerm_availability_set.this[each.value.virtual_machine.avset_key].id, null)
    }
  )

  interfaces = [for v in each.value.interfaces : {
    name                     = "${var.name_prefix}-${v.name}"
    subnet_id                = module.vnet[each.value.virtual_machine.vnet_key].subnet_ids[v.subnet_key]
    create_public_ip         = v.create_public_ip
    public_ip_name           = v.create_public_ip ? coalesce(v.public_ip_name, "${var.name_prefix}${each.value.name}-pip") : v.public_ip_name
    public_ip_resource_group = v.public_ip_resource_group
    lb_backend_pool_id       = try(module.load_balancer[v.load_balancer_key].backend_pool_id, null)
    private_ip_address       = v.private_ip_address
  }]

  tags = var.tags
  depends_on = [
    module.vnet,
    azurerm_availability_set.this,
    # module.bootstrap,
    # module.bootstrap_share
  ]
}


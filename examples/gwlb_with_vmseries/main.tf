locals {
  resource_group    = var.create_resource_group ? azurerm_resource_group.this[0] : data.azurerm_resource_group.this[0]
  vmseries_password = try(var.vmseries_common.password, random_password.vmseries[0].result)
  appvms_password   = try(var.appvms_common.password, random_password.appvms[0].result)
}

# Obtain Public IP address of deployment machine
data "http" "this" {
  count = length(var.bootstrap_storages) > 0 && anytrue([for v in values(var.bootstrap_storages) : try(v.storage_acl, false)]) ? 1 : 0
  url   = "https://ifconfig.me"
}

resource "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 1 : 0

  name     = "${var.name_prefix}${var.resource_group_name}"
  location = var.location

  tags = var.tags
}

data "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 0 : 1

  name = "${var.name_prefix}${var.resource_group_name}"
}

# VNets
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

# Gateway Load Balancers
module "gwlb" {
  for_each = var.gateway_load_balancers
  source   = "../../modules/gwlb"

  name                = "${var.name_prefix}${each.value.name}"
  resource_group_name = try(each.value.resource_group_name, local.resource_group.name)
  location            = var.location

  backends      = each.value.backends
  health_probes = each.value.health_probes

  zones = var.enable_zones ? try(each.value.zones, null) : null
  frontend_ip = {
    name                          = try(each.value.frontend_ip.name, "${var.name_prefix}${each.value.name}")
    private_ip_address_allocation = try(each.value.frontend_ip.private_ip_address_allocation, null)
    private_ip_address_version    = try(each.value.frontend_ip.private_ip_address_version, null)
    private_ip_address            = try(each.value.frontend_ip.private_ip_address, null)
    subnet_id                     = module.vnet[each.value.vnet_key].subnet_ids[each.value.subnet_key]
  }

  tags = var.tags
}

# VM-Series
module "ai" {
  source = "../../modules/application_insights"

  for_each = toset(
    var.application_insights != null ? flatten(
      try([var.application_insights.name], [for _, v in var.vmseries : "${v.name}-ai"])
    ) : []
  )

  name                = "${var.name_prefix}${each.key}"
  resource_group_name = local.resource_group.name
  location            = var.location

  workspace_mode            = try(var.application_insights.workspace_mode, null)
  workspace_name            = try(var.application_insights.workspace_name, "${var.name_prefix}${each.key}-wrkspc")
  workspace_sku             = try(var.application_insights.workspace_sku, null)
  metrics_retention_in_days = try(var.application_insights.metrics_retention_in_days, null)

  tags = var.tags
}

resource "local_file" "bootstrap_xml" {
  for_each = { for k, v in var.vmseries : k => v if can(v.bootstrap_storage.template_bootstrap_xml) }

  filename = "files/${each.key}-bootstrap.xml"
  content = templatefile(
    each.value.bootstrap_storage.template_bootstrap_xml,
    {
      data_gateway_ip = cidrhost(
        module.vnet[var.vmseries_common.vnet_key].subnet_cidrs[each.value.interfaces[1].subnet_key],
        1
      )

      ai_instr_key = try(module.ai[try(var.application_insights.name, "${var.name_prefix}${each.value.name}-ai")].metrics_instrumentation_key, null)

      ai_update_interval = try(
        each.value.ai_update_interval,
        var.vmseries_common.ai_update_interval,
        5
      )
    }
  )

  depends_on = [
    module.ai,
    module.vnet
  ]
}

module "bootstrap" {
  for_each = var.bootstrap_storages
  source   = "../../modules/bootstrap"

  name                   = each.value.name
  create_storage_account = try(each.value.create_storage, true)
  resource_group_name    = try(each.value.resource_group_name, local.resource_group.name)
  location               = var.location

  storage_acl                      = try(each.value.storage_acl, false)
  storage_allow_vnet_subnet_ids    = try([for v in each.value.storage_allow_vnet_subnets : module.vnet[v.vnet_key].subnet_ids[v.subnet_key]], [])
  storage_allow_inbound_public_ips = concat(try(each.value.storage_allow_inbound_public_ips, []), try([data.http.this[0].response_body], []))

  tags = var.tags
}

module "bootstrap_share" {
  source = "../../modules/bootstrap"

  for_each = { for k, v in var.vmseries : k => v if can(v.bootstrap_storage) }

  create_storage_account = false
  name                   = module.bootstrap[each.value.bootstrap_storage.key].storage_account.name
  resource_group_name    = try(var.bootstrap_storages[each.value.bootstrap_storage.key].resource_group_name, local.resource_group.name)
  location               = var.location
  storage_share_name     = "${var.name_prefix}${each.value.name}"

  files = merge(
    each.value.bootstrap_storage.static_files,
    can(each.value.bootstrap_storage.template_bootstrap_xml) ? {
      "files/${each.key}-bootstrap.xml" = "config/bootstrap.xml"
    } : {}
  )
  files_md5 = can(each.value.bootstrap_storage.template_bootstrap_xml) ? {
    "files/${each.key}-bootstrap.xml" = local_file.bootstrap_xml[each.key].content_md5
  } : {}

  tags = var.tags

  depends_on = [
    local_file.bootstrap_xml,
    module.bootstrap
  ]
}

resource "random_password" "vmseries" {
  count = try(var.vmseries_common.password, null) == null ? 1 : 0

  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "_%@"
}

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
  for_each = var.vmseries
  source   = "../../modules/vmseries"

  name                = "${var.name_prefix}${each.value.name}"
  location            = var.location
  resource_group_name = local.resource_group.name
  enable_zones        = var.enable_zones
  avzone              = try(each.value.avzone, 1)
  avset_id            = try(azurerm_availability_set.this[each.value.availability_set_key].id, null)

  username    = var.vmseries_common.username
  password    = local.vmseries_password
  ssh_keys    = var.vmseries_common.ssh_keys
  img_version = try(each.value.img_version, var.vmseries_common.img_version)
  img_sku     = try(each.value.img_sku, var.vmseries_common.img_sku)
  vm_size     = try(each.value.vm_size, var.vmseries_common.vm_size)

  bootstrap_options = try(
    each.value.bootstrap_options,
    var.vmseries_common.bootstrap_options,
    join(",", [
      "storage-account=${module.bootstrap[each.value.bootstrap_storage.key].storage_account.name}",
      "access-key=${module.bootstrap[each.value.bootstrap_storage.key].storage_account.primary_access_key}",
      "file-share=${var.name_prefix}${each.value.name}",
      "share-directory=None"
    ]),
    ""
  )

  interfaces = [for interface in each.value.interfaces :
    {
      name                     = "${var.name_prefix}${each.value.name}-${interface.name}"
      subnet_id                = module.vnet[var.vmseries_common.vnet_key].subnet_ids[interface.subnet_key]
      create_public_ip         = try(interface.create_public_ip, false)
      public_ip_name           = try(interface.public_ip_name, null)
      public_ip_resource_group = try(interface.public_ip_resource_group, null)
      private_ip_address       = try(interface.private_ip_address, null)
      enable_backend_pool      = try(interface.enable_backend_pool, false)
      lb_backend_pool_id       = try(interface.enable_backend_pool, false) ? module.gwlb[interface.gwlb_key].backend_pool_ids[interface.gwlb_backend_key] : null
      tags                     = try(interface.tags, null)
    }
  ]

  tags = var.tags

  depends_on = [
    module.vnet,
    module.bootstrap,
    module.bootstrap_share,
    azurerm_availability_set.this
  ]
}

# Sample application VMs and Load Balancers
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
        gwlb_fip_id    = try(module.gwlb[v.gwlb_key].frontend_ip_config_id, null)
      }
    )
  }

  tags       = var.tags
  depends_on = [module.vnet]
}



resource "random_password" "appvms" {
  count = try(var.appvms_common.password, null) == null ? 1 : 0

  length      = 16
  min_lower   = 16 - 4
  min_numeric = 1
  min_special = 1
  min_upper   = 1
}

module "appvm" {
  for_each = var.appvms
  source   = "../../modules/virtual_machine"

  name                = "${var.name_prefix}${each.value.name}"
  location            = var.location
  resource_group_name = local.resource_group.name
  avzone              = each.value.avzone

  interfaces = [
    {
      name                = "${var.name_prefix}${each.value.name}"
      subnet_id           = module.vnet[each.value.vnet_key].subnet_ids[each.value.subnet_key]
      enable_backend_pool = true
      lb_backend_pool_id  = module.load_balancer[each.value.load_balancer_key].backend_pool_id
    },
  ]

  username    = try(var.appvms_common.username, null)
  password    = try(local.appvms_password)
  ssh_keys    = try(var.appvms_common.ssh_keys, [])
  custom_data = try(var.appvms_common.custom_data, null)

  vm_size                = try(var.appvms_common.vm_size, "Standard_B1ls")
  managed_disk_type      = try(var.appvms_common.disk_type, "Standard_LRS")
  accelerated_networking = try(var.appvms_common.accelerated_networking, false)

  tags = var.tags
}

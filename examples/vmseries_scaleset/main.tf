# Create the Resource Group for inbound VM-Series.
resource "azurerm_resource_group" "inbound" {
  count = var.create_inbound_resource_group ? 1 : 0

  name     = coalesce(var.inbound_resource_group_name, "${var.name_prefix}inbound")
  location = var.location
}

data "azurerm_resource_group" "inbound" {
  count = var.create_inbound_resource_group == false ? 1 : 0

  name = var.inbound_resource_group_name
}

locals {
  inbound_resource_group = var.create_inbound_resource_group ? azurerm_resource_group.inbound[0] : data.azurerm_resource_group.inbound[0]
}

# Create the Resource Group for outbound VM-Series.
resource "azurerm_resource_group" "outbound" {
  count = var.create_outbound_resource_group ? 1 : 0

  name     = coalesce(var.outbound_resource_group_name, "${var.name_prefix}outbound")
  location = var.location
}

data "azurerm_resource_group" "outbound" {
  count = var.create_outbound_resource_group == false ? 1 : 0

  name = var.outbound_resource_group_name
}

locals {
  outbound_resource_group = var.create_outbound_resource_group ? azurerm_resource_group.outbound[0] : data.azurerm_resource_group.outbound[0]
}

# Generate a random password.
resource "random_password" "this" {
  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  special          = true
  override_special = "_%@"
}

# Create the transit network which holds the VM-Series
# (both inbound and outbound ones).
module "vnet" {
  source = "../../modules/vnet"

  create_virtual_network = var.create_virtual_network
  virtual_network_name   = var.virtual_network_name
  # We have two Resource Groups: inbound and outbound. The Virtual Net is used for both the inbound and the outbound
  # flow, so in which RG to put it in? Just to avoid creating a third RG (common), let's assume we use the inbound RG.
  resource_group_name     = local.inbound_resource_group.name
  location                = var.location
  address_space           = var.address_space
  network_security_groups = var.network_security_groups
  route_tables            = var.route_tables
  subnets                 = var.subnets
  tags                    = merge(var.tags, var.panorama_tags, var.vnet_tags)
}

# Allow access from outside to Management interfaces of VM-Series.
resource "azurerm_network_security_rule" "mgmt" {
  name                        = "vmseries-mgmt-allow-inbound"
  resource_group_name         = local.inbound_resource_group.name
  network_security_group_name = "sg_mgmt"
  access                      = "Allow"
  direction                   = "Inbound"
  priority                    = 1000
  protocol                    = "*"
  source_port_range           = "*"
  source_address_prefixes     = var.allow_inbound_mgmt_ips
  destination_address_prefix  = "*"
  destination_port_range      = "*"

  depends_on = [module.vnet]
}

### LOAD BALANCERS ###
# Create the inbound load balancer.
module "inbound_lb" {
  source = "../../modules/loadbalancer"

  name                              = var.inbound_lb_name
  resource_group_name               = local.inbound_resource_group.name
  location                          = var.location
  frontend_ips                      = var.public_frontend_ips
  enable_zones                      = var.enable_zones
  avzones                           = var.avzones
  tags                              = merge(var.tags, var.panorama_tags)
  network_security_group_name       = "sg_pub_inbound"
  network_security_allow_source_ips = coalescelist(var.allow_inbound_data_ips, var.allow_inbound_mgmt_ips)
}

# Create the outbound load balancer.
module "outbound_lb" {
  source = "../../modules/loadbalancer"

  name                = var.outbound_lb_name
  resource_group_name = local.outbound_resource_group.name
  location            = var.location
  enable_zones        = var.enable_zones
  tags                = merge(var.tags, var.panorama_tags)
  avzones             = var.avzones
  frontend_ips = {
    outbound = {
      subnet_id                     = lookup(module.vnet.subnet_ids, "outbound_private", null)
      private_ip_address_allocation = "Static"
      private_ip_address            = var.olb_private_ip
      rules = {
        HA_PORTS = {
          port     = 0
          protocol = "All"
        }
      }
    }
  }
}

# Outbound Azure NATGW (all-AZ)
resource "azurerm_nat_gateway" "outbound" {
  name                    = "${var.outbound_name_prefix}NATGW"
  location                = var.location
  resource_group_name     = local.outbound_resource_group.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  tags                    = var.tags
}

resource "azurerm_public_ip" "outbound" {
  name                = "${var.outbound_name_prefix}NATPIP"
  location            = var.location
  resource_group_name = local.outbound_resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.enable_zones ? var.avzones : null
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "outbound" {
  nat_gateway_id       = azurerm_nat_gateway.outbound.id
  public_ip_address_id = azurerm_public_ip.outbound.id
}

resource "azurerm_subnet_nat_gateway_association" "outbound_public" {
  subnet_id      = module.vnet.subnet_ids["outbound_public"]
  nat_gateway_id = azurerm_nat_gateway.outbound.id
}

resource "azurerm_subnet_nat_gateway_association" "outbound_private" {
  subnet_id      = module.vnet.subnet_ids["outbound_private"] # remove it?
  nat_gateway_id = azurerm_nat_gateway.outbound.id
}

# Management Azure NATGW (all-AZ)
resource "azurerm_nat_gateway" "mgmt" {
  name                    = "${var.name_prefix}NATGW"
  location                = var.location
  resource_group_name     = local.inbound_resource_group.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  tags                    = var.tags
}

resource "azurerm_public_ip" "mgmt" {
  name                = "${var.name_prefix}NATPIP"
  location            = var.location
  resource_group_name = local.inbound_resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.enable_zones ? var.avzones : null
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "mgmt" {
  nat_gateway_id       = azurerm_nat_gateway.mgmt.id
  public_ip_address_id = azurerm_public_ip.mgmt.id
}

resource "azurerm_subnet_nat_gateway_association" "mgmt" {
  subnet_id      = module.vnet.subnet_ids["management"]
  nat_gateway_id = azurerm_nat_gateway.mgmt.id
}

### BOOTSTRAPPING ###

# Create File Share and put there files for initial boot of inbound VM-Series.
module "inbound_bootstrap" {
  source = "../../modules/bootstrap"

  resource_group_name              = local.inbound_resource_group.name
  location                         = var.location
  storage_share_name               = var.inbound_storage_share_name
  storage_account_name             = var.storage_account_name
  files                            = var.inbound_files
  storage_acl                      = var.storage_acl
  storage_allow_inbound_public_ips = var.storage_allow_inbound_public_ips
  storage_allow_vnet_subnets       = [module.vnet.subnet_ids["management"]]
}

# Create File Share and put there files for initial boot of outbound VM-Series.
module "outbound_bootstrap" {
  source = "../../modules/bootstrap"

  resource_group_name    = local.inbound_resource_group.name
  create_storage_account = false
  storage_account_name   = module.inbound_bootstrap.storage_account.name
  storage_share_name     = var.outbound_storage_share_name
  files                  = var.outbound_files

  depends_on = [module.inbound_bootstrap]
}

### SCALE SETS ###

# Create the inbound scale set.
module "inbound_scale_set" {
  source = "../../modules/vmss"

  resource_group_name             = local.inbound_resource_group.name
  location                        = var.location
  name_prefix                     = var.inbound_name_prefix
  name_scale_set                  = var.name_scale_set
  img_sku                         = var.common_vmseries_sku
  img_version                     = var.inbound_vmseries_version
  tags                            = merge(var.tags, var.panorama_tags, var.outbound_vmseries_tags)
  vm_size                         = var.inbound_vmseries_vm_size
  autoscale_count_default         = var.inbound_count_minimum
  autoscale_count_minimum         = var.inbound_count_minimum
  autoscale_count_maximum         = var.inbound_count_maximum
  autoscale_notification_emails   = var.autoscale_notification_emails
  autoscale_metrics               = var.autoscale_metrics
  scaleout_statistic              = var.scaleout_statistic
  scaleout_time_aggregation       = var.scaleout_time_aggregation
  scaleout_window_minutes         = var.scaleout_window_minutes
  scaleout_cooldown_minutes       = var.scaleout_cooldown_minutes
  scalein_statistic               = var.scalein_statistic
  scalein_time_aggregation        = var.scalein_time_aggregation
  scalein_window_minutes          = var.scalein_window_minutes
  scalein_cooldown_minutes        = var.scalein_cooldown_minutes
  username                        = var.username
  password                        = coalesce(var.password, random_password.this.result)
  disable_password_authentication = var.disable_password_authentication
  ssh_key                         = var.ssh_key
  subnet_mgmt                     = { id = module.vnet.subnet_ids["management"] }
  subnet_private                  = { id = module.vnet.subnet_ids["inbound_private"] }
  subnet_public                   = { id = module.vnet.subnet_ids["inbound_public"] }
  app_insights_settings           = var.app_insights_settings
  bootstrap_options = (join(",",
    [
      "storage-account=${module.inbound_bootstrap.storage_account.name}",
      "access-key=${module.inbound_bootstrap.storage_account.primary_access_key}",
      "file-share=${module.inbound_bootstrap.storage_share.name}",
      "share-directory=None"
    ]
  ))
  public_backend_pool_id  = module.inbound_lb.backend_pool_id
  create_mgmt_pip         = false
  create_public_pip       = false
  diagnostics_storage_uri = module.inbound_bootstrap.storage_account.primary_blob_endpoint
}

# Create the outbound scale set.
module "outbound_scale_set" {
  source = "../../modules/vmss"

  resource_group_name             = local.outbound_resource_group.name
  location                        = var.location
  name_prefix                     = var.outbound_name_prefix
  name_scale_set                  = var.name_scale_set
  img_sku                         = var.common_vmseries_sku
  img_version                     = var.outbound_vmseries_version
  tags                            = merge(var.tags, var.panorama_tags, var.outbound_vmseries_tags)
  vm_size                         = var.outbound_vmseries_vm_size
  autoscale_count_default         = var.outbound_count_minimum
  autoscale_count_minimum         = var.outbound_count_minimum
  autoscale_count_maximum         = var.outbound_count_maximum
  autoscale_notification_emails   = var.autoscale_notification_emails
  autoscale_metrics               = var.autoscale_metrics
  scaleout_statistic              = var.scaleout_statistic
  scaleout_time_aggregation       = var.scaleout_time_aggregation
  scaleout_window_minutes         = var.scaleout_window_minutes
  scaleout_cooldown_minutes       = var.scaleout_cooldown_minutes
  scalein_statistic               = var.scalein_statistic
  scalein_time_aggregation        = var.scalein_time_aggregation
  scalein_window_minutes          = var.scalein_window_minutes
  scalein_cooldown_minutes        = var.scalein_cooldown_minutes
  username                        = var.username
  password                        = coalesce(var.password, random_password.this.result)
  disable_password_authentication = var.disable_password_authentication
  ssh_key                         = var.ssh_key
  subnet_mgmt                     = { id = module.vnet.subnet_ids["management"] }
  subnet_private                  = { id = module.vnet.subnet_ids["outbound_private"] }
  subnet_public                   = { id = module.vnet.subnet_ids["outbound_public"] }
  app_insights_settings           = var.app_insights_settings
  bootstrap_options = (join(",",
    [
      "storage-account=${module.outbound_bootstrap.storage_account.name}",
      "access-key=${module.outbound_bootstrap.storage_account.primary_access_key}",
      "file-share=${module.outbound_bootstrap.storage_share.name}",
      "share-directory=None"
    ]
  ))
  private_backend_pool_id = module.outbound_lb.backend_pool_id
  create_mgmt_pip         = false
  create_public_pip       = false
  diagnostics_storage_uri = module.outbound_bootstrap.storage_account.primary_blob_endpoint
}

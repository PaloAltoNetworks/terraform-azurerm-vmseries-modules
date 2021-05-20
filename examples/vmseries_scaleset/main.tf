# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Create new Resource Group
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

# Generate random password than meets our requirements
resource "random_password" "this" {
  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "_%@"
}

# Setup all the networks required for the topology
module "vnet" {
  source = "../../modules/vnet"

  virtual_network_name    = var.virtual_network_name
  resource_group_name     = azurerm_resource_group.this.name
  location                = var.location
  address_space           = var.address_space
  network_security_groups = var.network_security_groups
  route_tables            = var.route_tables
  subnets                 = var.subnets
}

### LOAD BALANCERS ###
# Create the inbound load balancer
module "inbound_lb" {
  source = "../../modules/loadbalancer"

  name                = var.lb_public_name
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  frontend_ips        = var.public_frontend_ips
}

locals {
  private_frontend_ips = { for k, v in var.private_frontend_ips : k => {
    subnet_id                     = module.vnet.subnet_ids["private"]
    private_ip_address_allocation = "Static"
    private_ip_address            = var.olb_private_ip
    rules                         = v.rules
    }
  }
}

# Create the outbound load balancer
module "outbound_lb" {
  source = "../../modules/loadbalancer"

  name                = var.lb_private_name
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  frontend_ips        = local.private_frontend_ips
}

### BOOTSTRAPPING ###
# Inbound
module "inbound_bootstrap" {
  source = "../../modules/bootstrap"

  resource_group_name  = azurerm_resource_group.this.name
  location             = var.location
  storage_share_name   = "ibbootstrapshare"
  storage_account_name = var.storage_account_name
  files                = var.files
}

# Outbound
module "outbound_bootstrap" {
  source = "../../modules/bootstrap"

  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  storage_share_name       = "obbootstrapshare"
  create_storage_account   = false
  existing_storage_account = module.inbound_bootstrap.storage_account.name
  files                    = var.files
}

# Create a storage container for storing VM disks provisioned via VMSS
resource "azurerm_storage_container" "this" {
  name                 = "${var.name_prefix}vm-container"
  storage_account_name = module.inbound_bootstrap.storage_account.name
}

### SCALE SETS ###
# Create the inbound scale set
module "inbound_scale_set" {
  source = "../../modules/vmss"

  location                  = var.location
  name_prefix               = "${var.name_prefix}-inbound"
  username                  = var.username
  password                  = coalesce(var.password, random_password.this.result)
  subnet_mgmt               = { id = module.vnet.subnet_ids["management"] }
  subnet_private            = { id = module.vnet.subnet_ids["private"] }
  subnet_public             = { id = module.vnet.subnet_ids["public"] }
  bootstrap_storage_account = module.inbound_bootstrap.storage_account
  bootstrap_share_name      = module.inbound_bootstrap.storage_share.name
  vhd_container             = "${module.inbound_bootstrap.storage_account.primary_blob_endpoint}${azurerm_storage_container.this.name}"
  lb_public_backend_pool_id = module.inbound_lb.backend_pool_id
  vm_count                  = var.vmseries_count
  img_sku                   = var.common_vmseries_sku
}

# Create the outbound scale set
module "outbound_scale_set" {
  source = "../../modules/vmss"

  location                   = var.location
  name_prefix                = "${var.name_prefix}-outbound"
  username                   = var.username
  password                   = coalesce(var.password, random_password.this.result)
  subnet_mgmt                = { id = module.vnet.subnet_ids["management"] }
  subnet_private             = { id = module.vnet.subnet_ids["private"] }
  subnet_public              = { id = module.vnet.subnet_ids["public"] }
  bootstrap_storage_account  = module.outbound_bootstrap.storage_account
  bootstrap_share_name       = module.outbound_bootstrap.storage_share.name
  vhd_container              = "${module.outbound_bootstrap.storage_account.primary_blob_endpoint}${azurerm_storage_container.this.name}"
  lb_private_backend_pool_id = module.outbound_lb.backend_pool_id
  vm_count                   = var.vmseries_count
  img_sku                    = var.common_vmseries_sku
}

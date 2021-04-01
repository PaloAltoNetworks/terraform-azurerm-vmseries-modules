# Configure the Azure provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = {}
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Setup all the networks required for the topology
module "networks" {
  source = "../../modules/networking"

  location               = var.location
  management_ips         = var.management_ips
  name_prefix            = var.name_prefix
  management_vnet_prefix = var.management_vnet_prefix
  management_subnet      = var.management_subnet
  olb_private_ip         = var.olb_private_ip
  firewall_vnet_prefix   = var.firewall_vnet_prefix
  private_subnet         = var.private_subnet
  public_subnet          = var.public_subnet
  vm_management_subnet   = var.vm_management_subnet
}

# Create a panorama instance
module "panorama" {
  source = "../../modules/panorama"

  location         = var.location
  name_prefix      = var.name_prefix
  subnet_mgmt      = module.networks.panorama_mgmt_subnet
  username         = var.username
  password         = coalesce(var.password, random_password.password.result)
  panorama_sku     = var.panorama_sku
  panorama_version = var.panorama_version
}

module "inbound-lb" {
  source = "../../modules/inbound-load-balancer"

  location     = var.location
  name_prefix  = var.name_prefix
  frontend_ips = var.frontend_ips
}

module "outbound-lb" {
  source = "../../modules/outbound-load-balancer"

  location       = var.location
  name_prefix    = var.name_prefix
  backend-subnet = module.networks.subnet_private.id
}

module "bootstrap" {
  source = "../../modules/bootstrap"

  resource_group_name  = azurerm_resource_group.this.name
  location             = var.location
  storage_account_name = var.storage_account_name
  storage_share_name   = "ibbootstrapshare"
  files                = var.files
}

# Create a storage container for storing VM disks provisioned via VMSS
resource "azurerm_storage_container" "this" {
  name                 = "${var.name_prefix}vm-container"
  storage_account_name = module.bootstrap.storage_account.name
}

# Create the inbound Scaleset
module "inbound-scaleset" {
  source = "../../modules/vmss"

  location                  = var.location
  name_prefix               = var.name_prefix
  username                  = var.username
  password                  = coalesce(var.password, random_password.password.result)
  subnet_mgmt               = module.networks.subnet_mgmt
  subnet_private            = module.networks.subnet_private
  subnet_public             = module.networks.subnet_public
  bootstrap_storage_account = module.bootstrap.storage_account
  bootstrap_share_name      = module.bootstrap.storage_share.name
  vhd_container             = "${module.bootstrap.storage_account.primary_blob_endpoint}${azurerm_storage_container.this.name}"
  lb_backend_pool_id        = module.inbound-lb.backend-pool-id
  vm_count                  = var.vmseries_count
  depends_on                = [module.panorama]
}

# Outbound
module "outbound_bootstrap" {
  source = "../../modules/bootstrap"

  create_storage_account   = false
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  existing_storage_account = module.bootstrap.storage_account.name
  storage_share_name       = "obbootstrapshare"
  files                    = var.files
}

module "outbound-scaleset" {
  source = "../../modules/vmss"

  location                  = var.location
  name_prefix               = var.name_prefix
  username                  = var.username
  password                  = coalesce(var.password, random_password.password.result)
  subnet_mgmt               = module.networks.subnet_mgmt
  subnet_private            = module.networks.subnet_private
  subnet_public             = module.networks.subnet_public
  bootstrap_storage_account = module.outbound_bootstrap.storage_account
  bootstrap_share_name      = module.outbound_bootstrap.storage_share.name
  vhd_container             = "${module.outbound_bootstrap.storage_account.primary_blob_endpoint}${azurerm_storage_container.this.name}"
  lb_backend_pool_id        = module.outbound-lb.backend-pool-id
  vm_count                  = var.vmseries_count
  depends_on                = [module.panorama]
}

# Configure the Azure provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = ">=2.24.0"
  features {}
}

resource "random_password" "password" {
  length = 16
  special = true
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
  subnet_mgmt      = module.networks.panorama-mgmt-subnet
  username         = var.username
  password         = coalesce(var.password, random_password.password.result)
  panorama_sku     = var.panorama_sku
  panorama_version = var.panorama_version
}

module "inbound-lb" {
  source = "../../modules/inbound-load-balancer"

  location    = var.location
  name_prefix = var.name_prefix
}

module "outbound-lb" {
  source = "../../modules/outbound-load-balancer"

  location       = var.location
  name_prefix    = var.name_prefix
  backend-subnet = module.networks.subnet-private.id
}

module "bootstrap" {
  source = "../../modules/vm-bootstrap"

  location    = var.location
  name_prefix = var.name_prefix
}

# Create the inbound Scaleset
module "inbound-scaleset" {
  source = "../../modules/vmss"

  location                      = var.location
  name_prefix                   = var.name_prefix
  username                      = var.username
  password                      = coalesce(var.password, random_password.password.result)
  subnet-mgmt                   = module.networks.subnet-mgmt
  subnet-private                = module.networks.subnet-private
  subnet-public                 = module.networks.subnet-public
  bootstrap-storage-account     = module.bootstrap.bootstrap-storage-account
  bootstrap-share-name          = module.bootstrap.inbound-bootstrap-share-name
  vhd-container                 = module.bootstrap.storage-container-name
  lb_backend_pool_id            = module.inbound-lb.backend-pool-id
  vm_count                      = var.vm_series_count
  depends_on                    = [module.panorama]
}

# Create the inbound Scaleset
module "outbound-scaleset" {
  source = "../../modules/vmss"

  location                      = var.location
  name_prefix                   = var.name_prefix
  username                      = var.username
  password                      = coalesce(var.password, random_password.password.result)
  subnet-mgmt                   = module.networks.subnet-mgmt
  subnet-private                = module.networks.subnet-private
  subnet-public                 = module.networks.subnet-public
  bootstrap-storage-account     = module.bootstrap.bootstrap-storage-account
  bootstrap-share-name          = module.bootstrap.outbound-bootstrap-share-name
  vhd-container                 = module.bootstrap.storage-container-name
  lb_backend_pool_id            = module.outbound-lb.backend-pool-id
  vm_count                      = var.vm_series_count
  depends_on                    = [module.panorama]
}
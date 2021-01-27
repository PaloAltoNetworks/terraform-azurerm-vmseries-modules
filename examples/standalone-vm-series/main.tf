# Configure the Azure provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = ">=2.24.0"
  features {}
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

# Create the vm-series RG outside of the module and pass it in.
## All the config required for a single VM series Firewall in Azure
# Base resource group
resource "azurerm_resource_group" "vmseries" {
  location = var.location
  name     = "${var.name_prefix}-vmseries-rg"
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
  files = {
    "bootstrap_files/authcodes"    = "license/authcodes"
    "bootstrap_files/init-cfg.txt" = "config/init-cfg.txt"
  }
}

# Create inbound vm-series
module "inbound-vm-series" {
  source = "../../modules/vm-series"

  resource_group            = azurerm_resource_group.vmseries
  location                  = var.location
  name_prefix               = var.name_prefix
  username                  = var.username
  password                  = coalesce(var.password, random_password.password.result)
  vm_series_version         = "9.1.3"
  vm_series_sku             = "byol"
  subnet-mgmt               = module.networks.subnet-mgmt
  subnet-private            = module.networks.subnet-private
  subnet-public             = module.networks.subnet-public
  bootstrap-storage-account = module.bootstrap.bootstrap-storage-account
  bootstrap-share-name      = module.bootstrap.inbound-bootstrap-share-name
  lb_backend_pool_id        = module.inbound-lb.backend-pool-id
  instances = {
    "fw00" = {}
  }
  depends_on = [module.bootstrap]
}

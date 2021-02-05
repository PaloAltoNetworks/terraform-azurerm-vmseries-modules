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

# Create the VM-Series RG outside of the module and pass it in.
resource "azurerm_resource_group" "this" {
  count = var.existing_resource_group_name == null ? 1 : 0

  location = var.location
  name     = coalesce(var.create_resource_group_name, "${var.name_prefix}-vmseries-rg")
}

locals {
  resource_group_name = coalesce(var.existing_resource_group_name, azurerm_resource_group.this[0].name)
}

# Create a public IP for management
resource "azurerm_public_ip" "mgmt" {
  for_each = var.instances

  name                = "${var.name_prefix}${each.key}-mgmt"
  location            = var.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "standard"
}

# Create another PIP for the outside interface so we can talk outbound
resource "azurerm_public_ip" "public" {
  for_each = var.instances

  name                = "${var.name_prefix}${each.key}-public"
  location            = var.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "standard"
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
  backend-subnet = module.networks.subnet-private.id
}

module "bootstrap" {
  source = "../../modules/vm-bootstrap"

  location           = var.location
  storage_share_name = "ibbootstrapshare"
  name_prefix        = var.name_prefix
  files = {
    "bootstrap_files/authcodes"    = "license/authcodes"
    "bootstrap_files/init-cfg.txt" = "config/init-cfg.txt"
  }
}

# Create inbound vm-series
module "inbound-vm-series" {
  source = "../../modules/vm-series"

  resource_group_name       = local.resource_group_name
  location                  = var.location
  name_prefix               = var.name_prefix
  username                  = var.username
  password                  = coalesce(var.password, random_password.password.result)
  vm_series_version         = "9.1.3"
  vm_series_sku             = "byol"
  subnet-mgmt               = module.networks.subnet-mgmt
  subnet-private            = module.networks.subnet-private
  subnet-public             = module.networks.subnet-public
  bootstrap_storage_account = module.bootstrap.storage_account
  bootstrap-share-name      = module.bootstrap.storage_share_name
  lb_backend_pool_id        = module.inbound-lb.backend-pool-id
  instances = { for k, v in var.instances : k => {
    mgmt_public_ip_address_id = azurerm_public_ip.mgmt[k].id
    nic1_public_ip_address_id = azurerm_public_ip.public[k].id
  } }

  depends_on = [module.bootstrap]
}

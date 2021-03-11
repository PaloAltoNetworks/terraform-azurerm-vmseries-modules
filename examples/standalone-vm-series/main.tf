# Configure the Azure provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.42.0"
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
  backend-subnet = module.networks.subnet_private.id
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

resource "azurerm_availability_set" "this" {
  count = contains([for k, v in var.instances : try(v.zone, null) != null], true) ? 0 : 1

  name                        = "${var.name_prefix}avset"
  resource_group_name         = local.resource_group_name
  location                    = var.location
  platform_fault_domain_count = 2
}

# Common VM-Series for handling:
#   - inbound traffic from the Internet
#   - outbound traffic to the Internet
#   - internal traffic (also known as "east-west" traffic)
module "common_vmseries" {
  source = "../../modules/vmseries"
  for_each = { for k, v in var.instances : k => {
    mgmt_public_ip_address_id = azurerm_public_ip.mgmt[k].id
    nic1_public_ip_address_id = azurerm_public_ip.public[k].id
  } }

  resource_group_name       = local.resource_group_name
  location                  = var.location
  name                      = "${var.name_prefix}-${each.key}"
  avset_id                  = azurerm_availability_set.this[0].id
  username                  = var.username
  password                  = coalesce(var.password, random_password.password.result)
  vm_series_version         = "9.1.3"
  vm_series_sku             = "byol"
  bootstrap_storage_account = module.bootstrap.storage_account
  bootstrap_share_name      = module.bootstrap.storage_share_name
  data_nics = [
    {
      name                = "${each.key}-mgmt"
      subnet              = module.networks.subnet_mgmt
      enable_backend_pool = false
    },
    {
      name                = "${each.key}-public"
      subnet              = module.networks.subnet_public
      lb_backend_pool_id  = module.inbound-lb.backend-pool-id
      enable_backend_pool = true
    },
    {
      name                = "${each.key}-private"
      subnet              = module.networks.subnet_private
      enable_backend_pool = false
    },
  ]

  depends_on = [module.bootstrap]
}

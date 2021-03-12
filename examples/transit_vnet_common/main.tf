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

# Create the VM-Series RG only if an existing one has not been already provided.
resource "azurerm_resource_group" "this" {
  count = var.existing_resource_group_name == null ? 1 : 0

  location = var.location
  name     = coalesce(var.create_resource_group_name, "${var.name_prefix}-vmseries-rg")
}

locals {
  resource_group_name = coalesce(var.existing_resource_group_name, azurerm_resource_group.this[0].name)
}

# Create public IPs for management (https or ssh).
resource "azurerm_public_ip" "mgmt" {
  for_each = var.vmseries

  name                = "${var.name_prefix}${each.key}-mgmt"
  location            = var.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "standard"
}

# Create public IPs for the Internet-facing data interfaces so they could talk outbound.
resource "azurerm_public_ip" "public" {
  for_each = var.vmseries

  name                = "${var.name_prefix}${each.key}-public"
  location            = var.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "standard"
}

# The Inbound Load Balancer for handling the traffic from the Internet.
module "inbound-lb" {
  source = "../../modules/inbound-load-balancer"

  location     = var.location
  name_prefix  = var.name_prefix
  frontend_ips = var.frontend_ips
}

# The Outbound Load Balancer for handling the traffic from the private networks.
module "outbound-lb" {
  source = "../../modules/outbound-load-balancer"

  location       = var.location
  name_prefix    = var.name_prefix
  backend-subnet = module.networks.subnet_private.id
}

# The storage account for VM-Series initialization.
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

# Create the Availability Set only if we do not use Availability Zones.
# Each of these two mechanisms improves availability of the VM-Series.
resource "azurerm_availability_set" "this" {
  count = contains([for k, v in var.vmseries : try(v.avzone, null) != null], true) ? 0 : 1

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
  source   = "../../modules/vmseries"
  for_each = var.vmseries

  resource_group_name       = local.resource_group_name
  location                  = var.location
  name                      = "${var.name_prefix}${each.key}"
  avset_id                  = try(azurerm_availability_set.this[0].id, null)
  avzone                    = try(each.value.avzone, null)
  username                  = var.username
  password                  = coalesce(var.password, random_password.password.result)
  vm_series_version         = "9.1.3"
  vm_series_sku             = "byol"
  bootstrap_storage_account = module.bootstrap.storage_account
  bootstrap_share_name      = module.bootstrap.storage_share_name
  data_nics = [
    {
      name   = "${each.key}-mgmt"
      subnet = module.networks.subnet_mgmt
      # FIXME untested
      public_ip_address_id = azurerm_public_ip.mgmt[each.key].id
      enable_backend_pool  = false
    },
    {
      name                 = "${each.key}-public"
      subnet               = module.networks.subnet_public
      public_ip_address_id = azurerm_public_ip.public[each.key].id
      lb_backend_pool_id   = module.inbound-lb.backend-pool-id
      enable_backend_pool  = true
    },
    {
      name                = "${each.key}-private"
      subnet              = module.networks.subnet_private
      enable_backend_pool = false
    },
  ]

  depends_on = [module.bootstrap]
}

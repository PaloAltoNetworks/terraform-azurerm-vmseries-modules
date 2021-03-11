
provider "azurerm" {
  version = ">=2.24.0"
  features {}
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = {}
}

module "vnet" {
  source = "../../modules/vnet"

  for_each = var.vnets

  virtual_network_name    = each.key
  resource_group_name     = azurerm_resource_group.this.name
  address_space           = each.value.address_space
  network_security_groups = each.value.network_security_groups
  route_tables            = each.value.route_tables
  subnets                 = each.value.subnets

  depends_on = [azurerm_resource_group.this]
}

# Create a public IP for management
resource "azurerm_public_ip" "mgmt" {
  for_each = var.instances

  name                = "${var.name_prefix}${each.key}-mgmt"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "standard"
}

# Create another PIP for the outside interface so we can talk outbound
resource "azurerm_public_ip" "public" {
  for_each = var.instances

  name                = "${var.name_prefix}${each.key}-public"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
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
  backend-subnet = module.vnet["vnet-vmseries"].subnet_ids["subnet-inside"]
  # backend-subnet = module.networks.subnet_private.id
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

  resource_group_name       = azurerm_resource_group.this.name
  location                  = var.location
  name_prefix               = var.name_prefix
  username                  = var.username
  password                  = coalesce(var.password, random_password.password.result)
  vm_series_version         = "9.1.3"
  vm_series_sku             = "byol"
  bootstrap_storage_account = module.bootstrap.storage_account
  bootstrap_share_name      = module.bootstrap.storage_share_name
  subnet_mgmt               = module.vnet["vnet-vmseries"].subnet_ids["subnet_mgmt"]
  # subnet_mgmt               = module.networks.subnet_mgmt
  data_nics = [
    {
      subnet              = module.vnet["vnet-vmseries"].subnet_ids["subnet-outside"]
      lb_backend_pool_id  = module.inbound-lb.backend-pool-id
      enable_backend_pool = true
    },
    {
      subnet              = module.vnet["vnet-vmseries"].subnet_ids["subnet-inside"]
      enable_backend_pool = false
    },
  ]
  instances = { for k, v in var.instances : k => {
    mgmt_public_ip_address_id = azurerm_public_ip.mgmt[k].id
    nic1_public_ip_address_id = azurerm_public_ip.public[k].id
  } }

  depends_on = [module.bootstrap]
}

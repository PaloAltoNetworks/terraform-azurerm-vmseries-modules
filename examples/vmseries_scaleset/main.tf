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

resource "azurerm_public_ip" "lb" {
  name                = var.lb_public_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "standard"
}

locals {
  public_frontend_ips = {
    pip-existing = {
      create_public_ip         = false
      public_ip_name           = azurerm_public_ip.lb.name
      public_ip_resource_group = azurerm_resource_group.this.name
      rules = {
        HTTP = {
          port         = 80
          protocol     = "Tcp"
          backend_name = "backend1_name"
        }
      }
    }
  }
}

### LOAD BALANCERS ###
# Create the inbound load balancer
module "inbound-lb" {
  source = "../../modules/loadbalancer"

  name_lb             = var.lb_private_name
  frontend_ips        = local.public_frontend_ips
  resource_group_name = azurerm_resource_group.this.name

  depends_on = [azurerm_resource_group.this, azurerm_public_ip.lb]
}

locals {
  private_frontend_ips = {
    internal_fe = {
      subnet_id                     = module.vnet.subnet_ids["private"]
      private_ip_address_allocation = "Static" // Dynamic or Static
      private_ip_address            = "10.112.1.100"
      rules = {
        HA_PORTS = {
          port         = 0
          protocol     = "All"
          backend_name = "backend3_name"
        }
      }
    }
  }
}

# Create the outbound load balancer
module "outbound-lb" {
  source = "../../modules/loadbalancer"

  name_lb             = "outboundLB"
  frontend_ips        = local.private_frontend_ips
  resource_group_name = azurerm_resource_group.this.name

  depends_on = [azurerm_resource_group.this]
}



### BOOTSTRAPPING ###
# Inbound
module "inbound-bootstrap" {
  source = "../../modules/bootstrap"

  resource_group_name  = azurerm_resource_group.this.name
  location             = var.location
  storage_share_name   = "ibbootstrapshare"
  storage_account_name = var.storage_account_name
  files                = var.files
}

# Outbound
module "outbound-bootstrap" {
  source = "../../modules/bootstrap"

  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  storage_share_name       = "obbootstrapshare"
  create_storage_account   = false
  existing_storage_account = module.inbound-bootstrap.storage_account.name
  files                    = var.files
}

# Create a storage container for storing VM disks provisioned via VMSS
resource "azurerm_storage_container" "this" {
  name                 = "${var.name_prefix}vm-container"
  storage_account_name = module.inbound-bootstrap.storage_account.name
}



### SCALE SETS ###
# Create the inbound Scaleset
module "inbound-scaleset" {
  source = "../../modules/vmss"

  location                  = var.location
  name_prefix               = "${var.name_prefix}-inbound"
  username                  = var.username
  password                  = coalesce(var.password, random_password.this.result)
  subnet_mgmt               = { id = module.vnet.subnet_ids["management"] }
  subnet_private            = { id = module.vnet.subnet_ids["private"] }
  subnet_public             = { id = module.vnet.subnet_ids["public"] }
  bootstrap_storage_account = module.inbound-bootstrap.storage_account
  bootstrap_share_name      = module.inbound-bootstrap.storage_share.name
  vhd_container             = "${module.inbound-bootstrap.storage_account.primary_blob_endpoint}${azurerm_storage_container.this.name}"
  lb_backend_pool_id        = module.inbound-lb.backend_pool_ids["backend1_name"]
  vm_count                  = var.vmseries_count
}



# Create the outbound Scaleset
module "outbound-scaleset" {
  source = "../../modules/vmss"

  location                  = var.location
  name_prefix               = "${var.name_prefix}-outbound"
  username                  = var.username
  password                  = coalesce(var.password, random_password.this.result)
  subnet_mgmt               = { id = module.vnet.subnet_ids["management"] }
  subnet_private            = { id = module.vnet.subnet_ids["private"] }
  subnet_public             = { id = module.vnet.subnet_ids["public"] }
  bootstrap_storage_account = module.outbound-bootstrap.storage_account
  bootstrap_share_name      = module.outbound-bootstrap.storage_share.name
  vhd_container             = "${module.outbound-bootstrap.storage_account.primary_blob_endpoint}${azurerm_storage_container.this.name}"
  lb_backend_pool_id        = module.outbound-lb.backend_pool_ids["backend3_name"]
  vm_count                  = var.vmseries_count
}

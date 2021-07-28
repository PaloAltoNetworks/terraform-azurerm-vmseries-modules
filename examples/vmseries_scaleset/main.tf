# Create the Resource Group.
resource "azurerm_resource_group" "this" {
  name     = coalesce(var.resource_group_name, "${var.name_prefix}vmseries")
  location = var.location
}

# Generate a random password.
resource "random_password" "this" {
  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "_%@"
}

# Create the network required for the topology.
module "vnet" {
  source = "../../modules/vnet"

  virtual_network_name    = var.virtual_network_name
  resource_group_name     = azurerm_resource_group.this.name
  location                = var.location
  address_space           = var.address_space
  network_security_groups = var.network_security_groups
  route_tables            = var.route_tables
  subnets                 = var.subnets
  tags                    = var.vnet_tags
}

# Allow inbound access to Management subnet.
resource "azurerm_network_security_rule" "mgmt" {
  name                        = "vmseries-mgmt-allow-inbound"
  resource_group_name         = azurerm_resource_group.this.name
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
# Create the inbound load balancer
module "inbound_lb" {
  source = "../../modules/loadbalancer"

  name                              = var.lb_public_name
  resource_group_name               = azurerm_resource_group.this.name
  location                          = var.location
  frontend_ips                      = var.public_frontend_ips
  network_security_group_name       = "sg_public"
  network_security_allow_source_ips = coalescelist(var.allow_inbound_data_ips, var.allow_inbound_mgmt_ips)
}

# Create the outbound load balancer
module "outbound_lb" {
  source = "../../modules/loadbalancer"

  name                = var.lb_private_name
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  frontend_ips = {
    outbound = {
      subnet_id                     = lookup(module.vnet.subnet_ids, "private", null)
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

### BOOTSTRAPPING ###

# Inbound
module "inbound_bootstrap" {
  source = "../../modules/bootstrap"

  resource_group_name  = azurerm_resource_group.this.name
  location             = var.location
  storage_share_name   = var.inbound_storage_share_name
  storage_account_name = var.storage_account_name
  files                = var.inbound_files
}

# Outbound
module "outbound_bootstrap" {
  source = "../../modules/bootstrap"

  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  storage_share_name       = var.outbound_storage_share_name
  create_storage_account   = false
  existing_storage_account = module.inbound_bootstrap.storage_account.name
  files                    = var.outbound_files
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

  resource_group_name       = azurerm_resource_group.this.name
  location                  = var.location
  name_prefix               = "${var.name_prefix}inbound"
  img_sku                   = var.common_vmseries_sku
  img_version               = var.inbound_vmseries_version
  tags                      = var.inbound_vmseries_tags
  vm_size                   = var.inbound_vmseries_vm_size
  vm_count                  = var.vmseries_count
  username                  = var.username
  password                  = coalesce(var.password, random_password.this.result)
  subnet_mgmt               = { id = module.vnet.subnet_ids["management"] }
  subnet_private            = { id = module.vnet.subnet_ids["private"] }
  subnet_public             = { id = module.vnet.subnet_ids["public"] }
  bootstrap_storage_account = module.inbound_bootstrap.storage_account
  bootstrap_share_name      = module.inbound_bootstrap.storage_share.name
  public_backend_pool_id    = module.inbound_lb.backend_pool_id
  create_public_pip         = false
  create_mgmt_pip           = true
}

# Create the outbound scale set
module "outbound_scale_set" {
  source = "../../modules/vmss"

  resource_group_name       = azurerm_resource_group.this.name
  location                  = var.location
  name_prefix               = "${var.name_prefix}outbound"
  img_sku                   = var.common_vmseries_sku
  img_version               = var.outbound_vmseries_version
  tags                      = var.outbound_vmseries_tags
  vm_size                   = var.outbound_vmseries_vm_size
  vm_count                  = var.vmseries_count
  username                  = var.username
  password                  = coalesce(var.password, random_password.this.result)
  subnet_mgmt               = { id = module.vnet.subnet_ids["management"] }
  subnet_private            = { id = module.vnet.subnet_ids["private"] }
  subnet_public             = { id = module.vnet.subnet_ids["public"] }
  bootstrap_storage_account = module.outbound_bootstrap.storage_account
  bootstrap_share_name      = module.outbound_bootstrap.storage_share.name
  private_backend_pool_id   = module.outbound_lb.backend_pool_id
}

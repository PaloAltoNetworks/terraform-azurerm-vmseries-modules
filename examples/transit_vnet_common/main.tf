resource "azurerm_resource_group" "this" {
  location = var.location
  name     = var.resource_group_name
}

resource "random_password" "this" {
  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "_%@"
}

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

# Create public IPs for the Internet-facing data interfaces so they could talk outbound.
resource "azurerm_public_ip" "public" {
  for_each = var.vmseries

  name                = "${var.name_prefix}${each.key}-public"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "standard"
}

resource "azurerm_public_ip" "lb" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "standard"
  tags                = var.common_vmseries_tags
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

# The Inbound Load Balancer for handling the traffic from the Internet.
module "inbound-lb" {
  source = "../../modules/loadbalancer"

  name_lb             = var.lb_public_name
  frontend_ips        = local.public_frontend_ips
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  depends_on = [azurerm_resource_group.this, azurerm_public_ip.lb]
}

locals {
  private_frontend_ips = {
    internal_fe = {
      subnet_id                     = module.networks.subnet_private.id
      private_ip_address_allocation = "Dynamic" // Dynamic or Static
      private_ip_address            = ""
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
# The Outbound Load Balancer for handling the traffic from the private networks.
module "outbound-lb" {
  source = "../../modules/loadbalancer"

  name_lb             = var.lb_private_name
  frontend_ips        = local.private_frontend_ips
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  depends_on = [azurerm_resource_group.this]
}

# The storage account for VM-Series initialization.
module "bootstrap" {
  source = "../../modules/bootstrap"

  resource_group_name  = azurerm_resource_group.this.name
  location             = var.location
  storage_account_name = var.storage_account_name
  files                = var.files
}

# Create the Availability Set only if we do not use Availability Zones.
# Each of these two mechanisms improves availability of the VM-Series.
resource "azurerm_availability_set" "this" {
  count = contains([for k, v in var.vmseries : try(v.avzone, null) != null], true) ? 0 : 1

  name                        = "${var.name_prefix}avset"
  resource_group_name         = azurerm_resource_group.this.name
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

  resource_group_name       = azurerm_resource_group.this.name
  location                  = var.location
  name                      = "${var.name_prefix}${each.key}"
  avset_id                  = try(azurerm_availability_set.this[0].id, null)
  avzone                    = try(each.value.avzone, null)
  username                  = var.username
  password                  = coalesce(var.password, random_password.this.result)
  img_version               = var.common_vmseries_version
  img_sku                   = var.common_vmseries_sku
  vm_size                   = var.common_vmseries_vm_size
  tags                      = var.common_vmseries_tags
  bootstrap_storage_account = module.bootstrap.storage_account
  bootstrap_share_name      = module.bootstrap.storage_share.name
  interfaces = [
    {
      name                = "${each.key}-mgmt"
      subnet_id           = module.networks.subnet_mgmt.id
      create_public_ip    = true
      enable_backend_pool = false
    },
    {
      name                 = "${each.key}-public"
      subnet_id            = module.networks.subnet_public.id
      public_ip_address_id = azurerm_public_ip.public[each.key].id
      lb_backend_pool_id   = module.inbound-lb.backend_pool_ids["backend1_name"]
      enable_backend_pool  = true
    },
    {
      name                = "${each.key}-private"
      subnet_id           = module.networks.subnet_private.id
      lb_backend_pool_id  = module.outbound-lb.backend_pool_ids["backend3_name"]
      enable_backend_pool = true

      # Optional static private IP
      private_ip_address = try(each.value.trust_private_ip, null)
    },
  ]

  depends_on = [module.bootstrap]
}

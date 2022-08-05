resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = {}
}

# Create the network required for the topology.
module "vnet" {
  source = "../../modules/vnet"

  virtual_network_name    = var.vnet_name
  location                = var.location
  resource_group_name     = azurerm_resource_group.this.name
  address_space           = var.address_space
  network_security_groups = var.network_security_groups
  route_tables            = {}
  subnets                 = var.subnets
  tags                    = var.tags
}

# Allow inbound access to Management subnet.
resource "azurerm_network_security_rule" "mgmt" {
  name                        = "vmseries-mgmt-allow-inbound"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = "network_security_group_1"
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

# Generate a random password.
resource "random_password" "this" {
  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  special          = true
  override_special = "_%@"
}

# While this example does not require a bootstrap file share,
# we will use the module just to get a storage blob.
# The blob will hold boot diagnostics of our virtual machine.
module "bootstrap" {
  source = "../../modules/bootstrap"

  resource_group_name  = azurerm_resource_group.this.name
  location             = var.location
  storage_account_name = var.storage_account_name
}

module "panorama" {
  source = "../../modules/panorama"

  panorama_name       = var.panorama_name
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  avzone              = var.avzone
  avzones             = var.avzones
  enable_zones        = var.enable_zones
  custom_image_id     = var.custom_image_id
  panorama_disk_type  = var.panorama_disk_type
  panorama_sku        = var.panorama_sku
  panorama_size       = var.panorama_size
  panorama_version    = var.panorama_version
  tags                = var.tags

  interface = [
    // Only one interface in Panorama VM is supported
    {
      name               = "mgmt"
      subnet_id          = lookup(module.vnet.subnet_ids, "management", null)
      private_ip_address = var.panorama_private_ip_address
      public_ip          = true
      public_ip_name     = var.panorama_name
    }
  ]

  logging_disks = {
    logs-1 = {
      size : "2048"
      lun : "1"
    }
    logs-2 = {
      size : "2048"
      lun : "2"
    }
  }

  username                    = var.username
  password                    = random_password.this.result
  boot_diagnostic_storage_uri = module.bootstrap.storage_account.primary_blob_endpoint
}

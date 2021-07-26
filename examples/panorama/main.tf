resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = {}
}

module "vnet" {
  source = "Azure/vnet/azurerm"

  resource_group_name = azurerm_resource_group.this.name
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names
  tags                = var.tags

  depends_on = [azurerm_resource_group.this]
}

module "nsg" {
  source = "Azure/network-security-group/azurerm"

  resource_group_name     = azurerm_resource_group.this.name
  location                = var.location
  security_group_name     = var.security_group_name
  source_address_prefixes = keys(var.management_ips)
  tags                    = var.tags
  predefined_rules = [
    { name = "SSH" },
    { name = "HTTPS" },
  ]

  custom_rules = [
    for i, prefix in var.firewall_mgmt_prefixes :
    {
      name                   = "allow-vmseries${i}-to-panorama"
      description            = "Allow VM-Series devices to connect to Panorama."
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "*"
      source_port_range      = "*"
      destination_port_range = "*"
      source_address_prefix  = prefix
      priority               = 100 + i
    }
  ]

  depends_on = [azurerm_resource_group.this]
}

resource "azurerm_subnet_network_security_group_association" "public" {
  network_security_group_id = module.nsg.network_security_group_id
  subnet_id                 = module.vnet.vnet_subnets[0]
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
  avzone              = var.avzone // Optional Availability Zone number

  interface = [ // Only one interface in Panorama VM is supported
    {
      name               = "mgmt"
      subnet_id          = module.vnet.vnet_subnets[0]
      private_ip_address = var.panorama_private_ip_address // Optional: If not set, use dynamic allocation
      public_ip          = true                            // (optional|bool,   default: false)
      public_ip_name     = "public_ip"                     // (optional|string, default: "")
    }
  ]

  logging_disks = {
    disk_name_1 = {
      size : "2048"
      zone : "1"
      lun : "1"
    }
    disk_name_2 = {
      size : "2048"
      zone : "2"
      lun : "2"
    }
  }

  panorama_size               = var.panorama_size
  custom_image_id             = var.custom_image_id // optional
  username                    = var.username
  password                    = random_password.this.result
  panorama_sku                = var.panorama_sku
  panorama_version            = var.panorama_version
  boot_diagnostic_storage_uri = module.bootstrap.storage_account.primary_blob_endpoint
  tags                        = var.tags
}

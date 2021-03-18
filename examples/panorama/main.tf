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

  tags       = var.tags
  depends_on = [azurerm_resource_group.this]
}

module "nsg" {
  source = "Azure/network-security-group/azurerm"

  resource_group_name     = azurerm_resource_group.this.name
  location                = azurerm_resource_group.this.location
  security_group_name     = var.security_group_name
  source_address_prefixes = keys(var.management_ips)
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

  tags       = var.tags
  depends_on = [azurerm_resource_group.this]
}

resource "azurerm_subnet_network_security_group_association" "public" {
  network_security_group_id = module.nsg.network_security_group_id
  subnet_id                 = module.vnet.vnet_subnets[0]
}

resource "random_password" "this" {
  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "_%@"
}

module "bootstrap" {
  source = "../../modules/bootstrap"

  resource_group_name  = azurerm_resource_group.this.name
  location             = azurerm_resource_group.this.location
  storage_account_name = var.storage_account_name
  files                = var.files
}

module "panorama" {
  source = "../../modules/panorama"

  panorama_name       = var.panorama_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  avzone              = var.avzone // Optional Availability Zone number

  interface = { // Only one interface in Panorama VM is supported
    mgmt = {
      subnet_id            = module.vnet.vnet_subnets[0]
      private_ip_address   = "10.0.0.6" // Optional: If not set, use dynamic allocation
      public_ip            = "true"     // (optional|bool, default: "false")
      public_ip_name       = ""         // (optional|string, default: "")
      enable_ip_forwarding = "false"    // (optional|bool, default: "false")
      primary_interface    = "true"
    }
  }

  logging_disks = {
    disk_name_1 = {
      size : "2048"
      zone : "1"
      lun : "1"
    }
    disk_name_2 = {
      dize : "4096"
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

output "panorama_url" {
  value = "https://${module.panorama.public_mgmt_ip[0]}"
}

output "panorama_admin_password" {
  value = random_password.password.result
}

output "private_mgmt_ip" {
  value = module.panorama.private_mgmt_ip[0]
}

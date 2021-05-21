# Resource group to hold all resources
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

# Generate a random password for VM-Series
resource "random_password" "this" {
  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "_%@"
}

# Virtual Network and its Network Security Group
module "vnet" {
  source = "../../modules/vnet"

  virtual_network_name = "vnet-vmseries"
  location             = var.location
  resource_group_name  = azurerm_resource_group.this.name
  address_space        = ["10.110.0.0/16"]
  network_security_groups = {
    "management-security-group" = {
      rules = {
        "vm-management-rules" = {
          access                     = "Allow"
          direction                  = "Inbound"
          priority                   = 100
          protocol                   = "TCP"
          source_port_range          = "*"
          source_address_prefixes    = var.allow_inbound_mgmt_ips
          destination_address_prefix = "*"
          destination_port_range     = "*"
        }
      }
    }
  }
  route_tables = {}
  subnets = {
    "subnet-mgmt" = {
      address_prefixes       = ["10.110.255.0/24"]
      network_security_group = "management-security-group"
    }
  }
}

# The VM-Series virtual machine
module "vmseries" {
  source = "../../modules/vmseries"

  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  name                = "myfw"
  username            = var.username
  password            = random_password.this.result
  img_sku             = var.common_vmseries_sku
  interfaces = [
    {
      name             = "myfw-mgmt"
      subnet_id        = lookup(module.vnet.subnet_ids, "subnet-mgmt", null)
      create_public_ip = true
    },
  ]
}

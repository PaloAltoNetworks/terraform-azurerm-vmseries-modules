# Greenfield deployment
provider "azurerm" {
  version = ">=2.26.0"
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "example-rg"
  location = "East US"
  tags     = {}
}

module "vnet" {
  source = "../"

  virtual_network_name = "example-vnet"
  resource_group_name  = azurerm_resource_group.this.name
  address_space        = ["10.100.0.0/16"]
  subnets = {
    "mgmt" = {
      address_prefixes = ["10.100.0.0/24"]
      tags             = { "foo" = "bar" }
    },
    "private" = {
      address_prefixes = ["10.100.1.0/24"]
      tags             = { "foo" = "bar" }
    },
    "public" = {
      address_prefixes = ["10.100.2.0/24"]
    },
  }

  network_security_groups = {
    "nsg_1" = {},
    "nsg_2" = {},
    "nsg_3" = {},
  }

  network_security_rules = {
    "AllOutbound" = {
      network_security_group_name = "nsg_1"
      priority                    = 100
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
    },
  }
  route_tables = {
    "rt1" = {},
    "rt2" = {},
    "rt3" = {},
  }

  routes = {
    "route_1" = {
      route_table_name = "rt1"
      address_prefix   = "10.1.0.0/16"
      next_hop_type    = "vnetlocal"
    },
    "route_2" = {
      route_table_name = "rt1"
      address_prefix   = "10.2.0.0/16"
      next_hop_type    = "vnetlocal"
    },
  }
  depends_on = [azurerm_resource_group.this]
}

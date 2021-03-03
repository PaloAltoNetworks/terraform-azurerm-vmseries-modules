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
  source = "../../modules/vnet"

  virtual_network_name = "example-vnet"
  resource_group_name  = azurerm_resource_group.this.name
  address_space        = ["10.100.0.0/16"]
  tags = {
    env = "Test"
  }

  network_security_groups = {
    "network_security_group_1" = {
      location = "East US"
      rules = {
        "AllOutbound" = {
          priority                   = 100
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        "AllowSSH" = {
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }

    },
    "network_security_group_2" = {
      rules = {}
    },
    "network_security_group_3" = {
      rules = {
        "AllOutbound" = {
          priority                   = 100
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"

        }
      }
    },
  }

  route_tables = {
    "route_table_1" = {},
    "route_table_2" = {},
    "route_table_3" = {},
  }

  routes = {
    "route_1" = {
      route_table_name = "route_table_1"
      address_prefix   = "10.1.0.0/16"
      next_hop_type    = "vnetlocal"
    },
    "route_2" = {
      route_table_name = "route_table_2"
      address_prefix   = "10.2.0.0/16"
      next_hop_type    = "vnetlocal"
    },
    "route_3" = {
      route_table_name = "route_table_3"
      address_prefix   = "10.2.0.0/16"
      next_hop_type    = "vnetlocal"
    },
  }

  subnets = {
    "management" = {
      address_prefixes       = ["10.100.0.0/24"]
      network_security_group = "network_security_group_1"
      route_table            = "route_table_1"
    },
    "private" = {
      address_prefixes       = ["10.100.1.0/24"]
      network_security_group = "network_security_group_2"
      route_table            = "route_table_2"
    },
    "public" = {
      address_prefixes       = ["10.100.2.0/24"]
      network_security_group = "network_security_group_3"
      route_table            = "route_table_3"
    },
  }

  depends_on = [azurerm_resource_group.this]
}

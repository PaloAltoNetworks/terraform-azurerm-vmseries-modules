terraform {
  required_version = ">= 1.3, < 2.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "this" {
  name     = "fosix-vnet-brownfield"
  location = "North Europe"
}

resource "azurerm_virtual_network" "this" {
  name                = "fosix-brownfield-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "this" {
  for_each = {
    one-snet = "10.0.0.0/24"
    two-snet = "10.0.1.0/24"
  }

  name                 = each.key
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]
}
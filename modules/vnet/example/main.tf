# Greenfield deployment
// Resource Group creation
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
  location             = "West US"
  resource_group_name  = azurerm_resource_group.this.name
  address_space        = ["10.100.0.0/16"]
  subnets = {
    "subnet_1" = {
      name                 = "mgmt"
      resource_group_name  = "example-rg"
      virtual_network_name = "example-vnet"
      address_prefixes     = ["10.100.0.0/24"]
      tags                 = { "foo" = "bar" }
    }
    "subnet_2" = {
      name             = "private"
      address_prefixes = ["10.100.1.0/24"]
      tags             = { "foo" = "bar" }
    }
    "subnet_3" = {
      name             = "public"
      address_prefixes = ["10.100.2.0/24"]
    }
  }
  depends_on = [azurerm_resource_group.this]
}

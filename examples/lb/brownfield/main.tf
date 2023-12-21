terraform {
  required_version = ">= 1.2, < 2.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


resource "azurerm_resource_group" "ips" {
  name     = "fosix-lb-ips"
  location = "North Europe"
  # tags     = var.tags
}

resource "azurerm_public_ip" "this" {
  for_each = {
    sourced_frontend_zonal = ["1", "2", "3"]
    sourced_frontend       = null
  }

  name                = "fosix-${each.key}"
  resource_group_name = azurerm_resource_group.ips.name
  sku                 = "Standard"
  allocation_method   = "Static"
  location            = azurerm_resource_group.ips.location
  zones               = each.value

  # tags = var.tags
}

resource "azurerm_network_security_group" "this" {
  name                = "fosix-existing-nsg"
  resource_group_name = azurerm_resource_group.ips.name
  location            = azurerm_resource_group.ips.location

}
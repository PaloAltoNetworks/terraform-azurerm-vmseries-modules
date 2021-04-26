terraform {
  required_version = ">=0.12.29, <0.15"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.42"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

terraform {
  required_version = ">= 0.12.29, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 2.64"
    }
  }
}

provider "azurerm" {
  features {}
}

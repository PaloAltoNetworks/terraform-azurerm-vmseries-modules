terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 2.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "= 2.3.1"
    }
  }
}

provider "azurerm" {
  features {}
}

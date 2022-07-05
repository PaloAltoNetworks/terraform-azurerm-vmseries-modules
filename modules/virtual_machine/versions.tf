terraform {
  required_version = ">= 0.13.7, < 2.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.64"
    }
  }
}

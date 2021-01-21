terraform {
  required_version = ">=0.12.29, <0.14"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

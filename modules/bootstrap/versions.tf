terraform {
  required_version = ">= 1.5, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.25"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

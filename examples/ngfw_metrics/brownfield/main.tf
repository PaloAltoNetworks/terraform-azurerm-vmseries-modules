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
    resource_group { prevent_deletion_if_contains_resources = false }
  }
}

resource "azurerm_resource_group" "this" {
  name     = "fosix-app-insights-refactor-brownfield"
  location = "North Europe"
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "fosix-brownfield-law"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  # retention_in_days = var.log_analytics_workspace.metrics_retention_in_days
  # sku               = var.log_analytics_workspace.sku
}

provider "azurerm" {
  version = ">=2.26.0"
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = {}
}

module "bootstrap" {
  source = "../../modules/bootstrap"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  files               = var.files
  depends_on          = [azurerm_resource_group.this]
}

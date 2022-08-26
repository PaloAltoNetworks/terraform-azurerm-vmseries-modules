resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

module "bootstrap" {
  source = "../../modules/bootstrap"

  resource_group_name  = azurerm_resource_group.this.name
  location             = azurerm_resource_group.this.location
  storage_account_name = var.storage_account_name
  files                = var.files
}

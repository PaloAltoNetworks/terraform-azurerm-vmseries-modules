resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

module "inbound_bootstrap" {
  source = "../../modules/bootstrap"

  storage_account_name  = var.storage_account_name
  storage_share_name    = var.inbound_storage_share_name
  resource_group_name   = azurerm_resource_group.this.name
  location              = azurerm_resource_group.this.location
  retention_policy_days = var.retention_policy_days
  files                 = var.inbound_files
}

module "obew_bootstrap" {
  source = "../../modules/bootstrap"

  create_storage_account = false
  storage_account_name   = module.inbound_bootstrap.storage_account.name
  storage_share_name     = var.obew_storage_share_name
  resource_group_name    = azurerm_resource_group.this.name
  files                  = var.obew_files

  depends_on = [module.inbound_bootstrap]
}

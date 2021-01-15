provider "azurerm" {
  version = ">=2.26.0"
  features {}
}

module "vnet" {
  source = "../../modules/vnet"

  location             = "East US"
  resource_group_name  = "some-rg"
  virtual_network_name = "some-vnet"
  subnets              = {}
}

module "bootstrap" {
  source = "../../modules/bootstrap/"

  resource_group_name  = module.vnet.resource_group.name
  location             = module.vnet.location
  storage_account_name = "kbtest2020101502"
  bootstrap_files_dir  = "./files"
  // Please rename files in files/ directory
}

output "storage_account_name" { value = module.bootstrap.storage_account.name }
output "storage_account_id" { value = module.bootstrap.storage_account.id }
output "storage_account_access_key" { value = module.bootstrap.storage_account_access_key }
output "storage_account_endpoint" { value = module.bootstrap.storage_account_endpoint }
output "storage_share_name" { value = module.bootstrap.storage_share.name }
output "storage_share_id" { value = module.bootstrap.storage_share.id }

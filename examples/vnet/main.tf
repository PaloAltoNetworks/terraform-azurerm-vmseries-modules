provider "azurerm" {
  version = ">=2.26.0"
  features {}
}

module "vnet" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/vnet"

  location             = "East US"
  resource_group_name  = "some-rg"
  virtual_network_name = "some-vnet"
  subnets = {
    "mgmt" = {
      name             = "mgmt"
      address_prefixes = ["10.0.7.0/24"]
      existing         = false
    }
    "trust" = {
      name             = "trust"
      address_prefixes = ["10.0.2.0/24"]
      existing         = false
    }
    "untrust" = {
      name             = "untrust"
      address_prefixes = ["10.0.11.0/24"]
      existing         = false
    }
  }
}

output "rg" { value = module.vnet.resource_group }
output "vnet" { value = module.vnet.virtual_network }
output "subnets" { value = module.vnet.subnets }

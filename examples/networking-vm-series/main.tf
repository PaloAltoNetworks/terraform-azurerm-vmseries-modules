# Configure the Azure provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = ">=2.24.0"
  features {}
}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}

# Setup all the networks required for the topology
module "networks" {
  source = "../../modules/networking-vm-series"
  location = var.location
  management_ips = var.management_ips
  name_prefix =  var.name_prefix
}
# Configure the Azure provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = ">=2.20.0"
  features {}
}



module "networks" {
  source      = "../../modules/networking"
  location    = "Australia Central"
  name_prefix = "panostf"
  management_ips = {
    "124.171.153.28" : 100,
  }
}

module "inbound-lb" {
  source = "../../modules/inbound-load-balancer"

  location    = "Australia Central"
  name_prefix = "panostf"
}

module "outbound-lb" {
  source = "../../modules/outbound-load-balancer"

  location       = "Australia Central"
  name_prefix    = "panostf"
  backend-subnet = module.networks.subnet-private.id
}
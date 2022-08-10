resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

module "vnet" {
  source = "../../modules/vnet"

  virtual_network_name    = var.virtual_network_name
  resource_group_name     = azurerm_resource_group.this.name
  location                = var.location
  address_space           = var.address_space
  network_security_groups = var.network_security_groups
  route_tables            = var.route_tables
  subnets                 = var.subnets
  tags                    = var.tags
}

module "appgw" {
  source = "../../modules/appgw"

  name                = "appgw"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  subnet_id           = module.vnet.subnet_ids["appgw"]
  capacity            = 2
  zones               = ["1"]
  enable_http2        = true
  tags                = var.tags
  waf_enabled         = true

  vmseries_ips = ["1.1.1.1"]
  rules = {
    "complex-application" = {
      priority = 1
      listener = {
        port       = 80
        host_names = ["www.complex.app"]
      }
      backend = {
        port = 8080
      }
      probe = {
        path = "/healthcheck"
        host = "127.0.0.1"
      }
      url_path_maps = {
        "menu" = {
          path = "/api/menu/"
          backend = {
            port = 8081
          }
          probe = {
            path = "/api/menu/healthcheck"
            host = "127.0.0.1"
          }
        }
        "header" = {
          path = "/api/header/"
          backend = {
            port = 8082
          }
          probe = {
            path = "/api/header/healthcheck"
            host = "127.0.0.1"
          }
        }
        "old_url_fix" = {
          path = "/old/app/path/"
          redirect = {
            type       = "Permanent"
            target_url = "https://www.complex.app"
          }
        }
      }
    }
  }
}
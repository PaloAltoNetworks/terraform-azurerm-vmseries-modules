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
  ssl_policy_type     = "Predefined"
  ssl_policy_name     = "AppGwSslPolicy20170401"

  ssl_profiles = {
    "tls1.2" = {
      ssl_policy_type = "Predefined"
      ssl_policy_name = "AppGwSslPolicy20220101S"
    }
  }

  vmseries_ips = ["1.1.1.1"]
  rules = {
    "application-1" = {
      priority = 1

      listener = {
        port                 = 443
        protocol             = "Https"
        ssl_certificate_path = "./files/self_signed.pfx"
        ssl_certificate_pass = "123qweasd"
        ssl_profile_name     = "tls1.2"
      }

      backend = {
        hostname_from_backend = true
      }

      probe = {
        path = "/php/login.php"
      }

      rewrite_sets = {
        "xff-strip-port" = {
          sequence = 100
          conditions = {
            "var_client_ip" = {
              pattern     = "1.1.1.1"
              ignore_case = true
            }
            "http_resp_X-Forwarded-Proto" = {
              pattern     = "https"
              ignore_case = true
              negate      = true
            }
          }
          request_headers = {
            "X-Forwarded-For"   = "{var_add_x_forwarded_for_proxy}"
            "X-Forwarded-Proto" = "https"
          }
          response_headers = {
            "X-Forwarded-Proto" = "http"
          }
        }
      }
    }
  }
}
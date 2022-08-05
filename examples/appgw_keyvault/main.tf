data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

module "vnet" {
  source = "../../modules/vnet"

  virtual_network_name    = var.virtual_network_name
  resource_group_name     = data.azurerm_resource_group.this.name
  location                = var.location
  address_space           = var.address_space
  network_security_groups = var.network_security_groups
  route_tables            = var.route_tables
  subnets                 = var.subnets
  tags                    = var.tags
}

module "appgw" {
  source = "../../modules/appgw"

  name                = "fosix-appgw"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  subnet_id           = module.vnet.subnet_ids["appgw"]
  managed_identities  = ["/subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/fosix-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/fosix-mid"]
  # sku = {
  #   name     = "Standard_Medium"
  #   tier     = "Standard"
  #   capacity = 2
  # }
  vmseries_ips = ["1.1.1.1", "2.2.2.2"]
  rules = {
    "plain-app" = {
      priority = 1

      listener = {
        port       = 80
        protocol   = "Http"
        host_names = ["www.fosix.com"]
      }

      redirect = {
        type                 = "Temporary"
        target_listener_name = "ssl-kv-app-listener"
        include_path         = true
        include_query_string = true
      }
    }
    "ssl-kv-app" = {
      priority = 2

      # xff_strip_port = true
      # xfp_https      = true

      listener = {
        port                     = 443
        protocol                 = "Https"
        host_names               = ["www.fosix.com"]
        ssl_certificate_vault_id = "https://fosix-kv.vault.azure.net/secrets/fosix-cert/bb1391bba15042a59adaea584a8208e8"
      }

      backend = {
        hostname = "www.fosix.com"
        port     = 8443
        protocol = "Https"
        root_certs = {
          fw = "files/CA.pem"
        }
      }

      probe = {
        path      = "/"
        port      = 443
        interval  = 10
        timeout   = 60
        threshold = 5
      }

      rewrite_sets = {
        "xff-strip-port" = {
          sequence = 100
          request_header = {
            name  = "X-Forwarded-For"
            value = "{var_add_x_forwarded_for_proxy}"
          }
        }
        "xfp-https" = {
          sequence = 200
          request_header = {
            name  = "X-Forwarded-Proto"
            value = "https"
          }
        }
      }
    }
    "minimum" = {
      priority = 3
      listener = {
        port = 8080
      }
    }
  }
}
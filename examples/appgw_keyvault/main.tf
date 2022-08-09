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
  capacity            = 2
  # capacity_min        = 1
  # capacity_max        = 10
  zones        = ["1"]
  enable_http2 = true
  tags         = var.tags
  waf_enabled  = true

  # vmseries_ips = ["1.1.1.1", "2.2.2.2"]
  vmseries_ips = ["20.69.233.42", "20.81.233.117"]
  rules = {
    "application-1" = {
      priority = 1

      listener = {
        port     = 443
        protocol = "Https"
        # ssl_certificate_path = "./files/self_signed.pfx"
        # ssl_certificate_pass = "password"
        ssl_certificate_vault_id = "https://fosix-kv.vault.azure.net/secrets/fosix-cert/bb1391bba15042a59adaea584a8208e8"

      }

      # backend = {
      #   hostname_from_backend = true
      # }

      probe = {
        path = "/php/login.php"
        host = "127.0.0.1"
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
  }
}
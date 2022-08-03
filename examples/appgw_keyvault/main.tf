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
    "ssl-kv-app" = {
      # listener_port     = 80
      # listener_protocol = "Http"
      listener_port     = 443
      listener_protocol = "Https"
      host_names        = ["www.fosix.com"]

      priority = 1

      probe_host     = "www.example.com"
      probe_protocol = "Http"
      probe_path     = "/"
      probe_port     = 80
      probe_interval = 2
      probe_timeout  = 30
      probe_theshold = 2

      ssl_certificate_vault_id = "https://fosix-kv.vault.azure.net/secrets/fosix-cert/bb1391bba15042a59adaea584a8208e8"
      ssl_certificate_path     = "files/self_signed.pfx"
      ssl_certificate_pass     = "123qweasd"
    }
  }
}
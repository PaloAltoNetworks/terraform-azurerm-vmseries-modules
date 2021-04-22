resource "azurerm_resource_group" "spoke" {
  name     = var.spoke_resource_group_name
  location = var.location
}

module "spoke_vnet" {
  source = "../../modules/vnet"

  virtual_network_name    = var.spoke_virtual_network_name
  resource_group_name     = azurerm_resource_group.spoke.name
  location                = var.location
  address_space           = var.spoke_address_space
  network_security_groups = var.network_security_groups
  route_tables            = var.spoke_route_tables
  subnets                 = var.spoke_subnets
  tags                    = var.common_vmseries_tags

  depends_on = [azurerm_resource_group.spoke]
}

resource "azurerm_virtual_network_peering" "spoke" {
  name                      = var.peering_spoke_name
  resource_group_name       = azurerm_resource_group.spoke.name
  virtual_network_name      = var.spoke_virtual_network_name
  remote_virtual_network_id = module.vnet.virtual_network_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "common" {
  name                      = var.peering_common_name
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = var.virtual_network_name
  remote_virtual_network_id = module.spoke_vnet.virtual_network_id
  allow_forwarded_traffic   = true
}

module "spoke_vmseries" {
  source   = "../../modules/vmseries"
  for_each = var.vmspoke

  resource_group_name       = azurerm_resource_group.spoke.name
  location                  = var.location
  name                      = "${var.name_prefix}${each.key}"
  avset_id                  = null
  avzone                    = try(each.value.avzone, null)
  username                  = var.username
  password                  = coalesce(var.password, random_password.this.result)
  img_publisher             = var.spoke_vm_publisher
  img_offer                 = var.spoke_vm_offer
  img_sku                   = var.spoke_vm_sku
  img_version               = var.spoke_vm_version
  vm_size                   = var.spoke_vm_size
  enable_plan               = false
  bootstrap_storage_account = module.bootstrap.storage_account
  bootstrap_share_name      = module.bootstrap.storage_share.name
  interfaces = [
    {
      name                = "${each.key}-private"
      subnet_id           = module.spoke_vnet.subnet_ids["private"]
      enable_backend_pool = false

      # Optional static private IP
      private_ip_address = try(each.value.trust_private_ip, null)
    },
  ]

  depends_on = [module.bootstrap]
}

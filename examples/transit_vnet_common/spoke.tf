resource "azurerm_resource_group" "spoke" {
  name     = coalesce(var.spoke_resource_group_name, "${var.name_prefix}spoke")
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

module "spoke" {
  source                        = "Azure/compute/azurerm"
  resource_group_name           = azurerm_resource_group.spoke.name
  vm_os_simple                  = var.spoke_vm_offer
  vnet_subnet_id                = lookup(module.spoke_vnet.subnet_ids, "private", null)
  delete_os_disk_on_termination = true
  vm_hostname                   = var.spoke_vm_name
  vm_size                       = var.spoke_vm_size
  nb_public_ip                  = var.nb_public_ip
  boot_diagnostics              = true
  enable_ssh_key                = false
  admin_username                = var.username
  admin_password                = coalesce(var.password, random_password.this.result)

  depends_on = [azurerm_resource_group.spoke]
}

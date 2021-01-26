resource "azurerm_resource_group" "this" {
  count    = var.existing_rg ? 0 : 1
  name     = var.resource_group_name
  location = var.location
}

data "azurerm_resource_group" "this" {
  name       = var.resource_group_name
  depends_on = [azurerm_resource_group.this]
}

resource "azurerm_virtual_network" "this" {
  count               = var.existing_vnet ? 0 : 1
  name                = var.virtual_network_name
  address_space       = var.address_space
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
}

data "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.this.name
  depends_on          = [azurerm_virtual_network.this]
}

resource "azurerm_subnet" "this" {
  for_each             = { for s in var.subnets : s.name => s if s.existing != true }
  name                 = each.value.name
  address_prefixes     = each.value.address_prefixes
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = data.azurerm_virtual_network.this.name
}

data "azurerm_subnet" "this" {
  for_each             = { for s in var.subnets : s.name => var.virtual_network_name }
  name                 = each.key
  virtual_network_name = each.value
  resource_group_name  = data.azurerm_resource_group.this.name
  depends_on           = [azurerm_subnet.this]
}

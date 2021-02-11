data "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  count = var.existing_vnet ? 0 : 1

  name                = var.virtual_network_name
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  address_space       = var.address_space
}

data "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.this.name
  depends_on          = [azurerm_virtual_network.this]
}

resource "azurerm_subnet" "this" {
  for_each = { for s in var.subnets : s.name => s if s.existing != true }

  name                 = each.value.name
  resource_group_name  = data.azurerm_resource_group.this.name
  address_prefixes     = each.value.address_prefixes
  virtual_network_name = data.azurerm_virtual_network.this.name
}

data "azurerm_subnet" "this" {
  for_each = { for s in var.subnets : s.name => var.virtual_network_name }

  name                 = each.key
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = each.value
  depends_on           = [azurerm_subnet.this]
}

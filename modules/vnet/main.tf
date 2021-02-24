data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  location            = coalesce(var.location, data.azurerm_resource_group.this.location)
  resource_group_name = data.azurerm_resource_group.this.name
  address_space       = var.address_space
}
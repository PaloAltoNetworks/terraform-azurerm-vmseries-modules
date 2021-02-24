data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  location            = coalesce(var.location, data.azurerm_resource_group.this.location)
  resource_group_name = data.azurerm_resource_group.this.name
  address_space       = var.address_space
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = try(each.value.resource_group_name, data.azurerm_resource_group.this.name)
  virtual_network_name = try(var.virtual_network_name, each.value.virtual_network_name)
  address_prefixes     = each.value.address_prefixes

  depends_on = [azurerm_virtual_network.this]
}

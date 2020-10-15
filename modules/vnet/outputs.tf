output "location" { value = data.azurerm_resource_group.this.location }
output "resource_group" { value = data.azurerm_resource_group.this }
output "virtual_network" { value = data.azurerm_virtual_network.this }
output "subnets" { value = data.azurerm_subnet.this }

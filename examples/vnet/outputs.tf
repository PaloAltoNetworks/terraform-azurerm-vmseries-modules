output "resource_group_id" {
  description = "The ID of the Resource Group."
  value       = azurerm_resource_group.this.id
}

output "resource_group_location" {
  description = "The location of the Resource Group."
  value       = azurerm_resource_group.this.location
}

output "virtual_network_id" {
  description = "The ID of the created Virtual Network."
  value       = module.vnet.virtual_network_id
}

output "subnet_id" {
  description = "The ID of the created Subnet."
  value       = module.vnet.subnet_id
}
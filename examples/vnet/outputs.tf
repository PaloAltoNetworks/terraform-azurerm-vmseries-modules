output "resource_group_name" {
  description = "The name of the Resource Group."
  value       = azurerm_resource_group.this.name
}

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

output "subnet_ids" {
  description = "The IDs of the created Subnets."
  value       = module.vnet.subnet_ids
}

output "network_security_group_ids" {
  description = "The IDs of the created Network Security Groups."
  value       = module.vnet.network_security_group_ids
}

output "route_table_ids" {
  description = "The IDs of the created Route Tables."
  value       = module.vnet.route_table_ids
}

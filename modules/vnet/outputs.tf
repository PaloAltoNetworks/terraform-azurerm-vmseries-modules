output "virtual_network_id" {
  description = "The identifier of the created Virtual Network."
  value = {
    for k, v in azurerm_virtual_network.this : k => v.id
  }
}

output "subnet_ids" {
  description = "The identifiers of the created Subnets."
  value = {
    for k, v in azurerm_subnet.this : k => v.id
  }
}

output "network_security_group_ids" {
  description = "The identifiers of the created Network Security Groups."
  value = {
    for k, v in azurerm_network_security_group.this : k => v.id
  }
}

output "route_table_ids" {
  description = "The identifiers of the created Route Tables."
  value = {
    for k, v in azurerm_route_table.this : k => v.id
  }
}

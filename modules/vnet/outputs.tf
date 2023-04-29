output "virtual_network_id" {
  description = "The identifier of the created or sourced Virtual Network."
  value       = local.virtual_network.id
}

output "vnet_cidr" {
  description = "VNET address space."
  value       = local.virtual_network.address_space
}

output "subnet_ids" {
  description = "The identifiers of the created or sourced Subnets."
  value       = { for k, v in local.subnets : k => v.id }
}

output "subnet_cidrs" {
  description = "Subnet CIDRs (sourced or created)."
  value       = { for k, v in local.subnets : k => v.address_prefixes[0] }
}

output "network_security_group_ids" {
  description = "The identifiers of the created Network Security Groups."
  value       = { for k, v in azurerm_network_security_group.this : k => v.id }
}

output "route_table_ids" {
  description = "The identifiers of the created Route Tables."
  value       = { for k, v in azurerm_route_table.this : k => v.id }
}

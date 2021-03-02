output "virtual_network_id" {
  description = "The ID of the created Virtual Network."
  value       = azurerm_virtual_network.this.id
}

output "subnet_id" {
  description = "The ID of the created Subnet."
  value = toset([
    for subnet in azurerm_subnet.this : subnet.id
  ])
}

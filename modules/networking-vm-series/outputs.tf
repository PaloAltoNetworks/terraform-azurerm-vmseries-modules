output "subnet_mgmt" {
  value       = azurerm_subnet.subnet_mgmt
  description = "Management subnet resource."
}
output "subnet_public" {
  value       = azurerm_subnet.subnet-outside
  description = "Outside/public subnet resource."
}
output "subnet_private" {
  value       = azurerm_subnet.subnet-inside
  description = "Inside/private subnet resource."

}
output "vnet" {
  value       = azurerm_virtual_network.vnet-vmseries
  description = "VNET resource."
}

output "outbound_route_table" {
  value       = azurerm_route_table.udr-inside.id
  description = "ID of UDR - can be used to direct traffic from a Spoke VNET to the Transit OLB."
}

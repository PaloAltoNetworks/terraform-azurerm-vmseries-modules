output "subnet-mgmt" {
  value       = azurerm_subnet.subnet-mgmt
  description = "Management subnet resource."
}
output "subnet-public" {
  value       = azurerm_subnet.subnet-outside
  description = "Outside/public subnet resource."
}
output "subnet-private" {
  value       = azurerm_subnet.subnet-inside
  description = "Inside/private subnet resource."

}
output "vnet" {
  value       = azurerm_virtual_network.vnet-vmseries
  description = "VNET resource."
}

output "outbound-route-table" {
  value       = azurerm_route_table.udr-inside.id
  description = "ID of UDR - can be used to direct traffic from a Spoke VNET to the Transit OLB."
}
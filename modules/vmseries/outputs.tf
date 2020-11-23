# output "fw_mgmt_public_ip" {
#   description = "Management IPs (Public)"
#   value       = azurerm_public_ip.pip[*].ip_address
# }

output "interface_ids" {
value = {
    for i in azurerm_network_interface.nic:
    i.name => i.id
  }
}

output "firewalls" {
  value = azurerm_virtual_machine.firewall[*]
}

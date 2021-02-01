
output "ip_addresses" {
  description = "VM-Series management IP addresses."
  value       = { for k, v in var.instances : k => azurerm_network_interface.nic-fw-mgmt[k].ip_configuration[0].private_ip_address }
}

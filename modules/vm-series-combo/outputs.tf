
output "inbound-fw-pips" {
  description = "Inbound firewall Public IPs"
  value       = [azurerm_public_ip.ib-pip-fw-mgmt.*.ip_address]
}

output "outbound-fw-pips" {
  description = "outbound firewall Public IPs"
  value       = [azurerm_public_ip.ob-pip-fw-mgmt.*.ip_address]
}
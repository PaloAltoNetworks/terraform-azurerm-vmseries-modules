
output "inbound-fw-pips" {
  description = "Inbound firewall Public IPs"
  value       = [azurerm_public_ip.pip-fw-mgmt.*.ip_address]
}
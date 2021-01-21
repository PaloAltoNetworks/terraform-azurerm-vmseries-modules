
output "inbound-fw-pips" {
  description = "Inbound firewall Public IPs"
  value       = { for k, v in var.instances : k => azurerm_public_ip.pip-fw-mgmt[k].ip_address }
}

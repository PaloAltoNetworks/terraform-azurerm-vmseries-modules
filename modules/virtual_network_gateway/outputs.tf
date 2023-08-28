output "public_ip" {
  description = "Public IP addresses for Virtual Network Gateway"
  value = merge(
    { for k, v in azurerm_public_ip.this : k => v.ip_address },
    { for k, v in data.azurerm_public_ip.exists : k => v.ip_address }
  )
}

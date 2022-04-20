output "public_ip" {
  description = "A public IP assigned to the Application Gateway."
  value       = azurerm_public_ip.this.ip_address
}

output "vng_public_ips" {
  description = "IP Addresses of the VNGs."
  value       = length(var.virtual_network_gateways) > 0 ? { for k, v in module.vng : k => v.public_ip } : null
}

output "vng_ipsec_policy" {
  description = "IPsec policy used for Virtual Network Gateway connection"
  value       = length(var.virtual_network_gateways) > 0 ? { for k, v in module.vng : k => v.ipsec_policy } : null
}
output "natgw_pip" {
  description = "Public IP associated with the NAT Gateway."
  value       = try(local.pip.ip_address, null)
}

output "natgw_pip_prefix" {
  description = "Public IP Prefix associated with the NAT Gateway."
  value       = try(local.pip_prefix.ip_prefix, null)
}

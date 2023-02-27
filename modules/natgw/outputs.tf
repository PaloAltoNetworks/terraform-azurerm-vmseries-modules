output "natgw_pip" {
  value = try(local.pip.ip_address, null)
}

output "natgw_pip_prefix" {
  value = try(local.pip_prefix.ip_prefix, null)
}

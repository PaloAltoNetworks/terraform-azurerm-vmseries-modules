output "public_ip" {
  description = "Public IP addresses for Virtual Network Gateway"
  value = merge(
    { for k, v in azurerm_public_ip.this : k => v.ip_address },
    { for k, v in data.azurerm_public_ip.exists : k => v.ip_address }
  )
}

output "ipsec_policy" {
  description = "IPsec policy used for Virtual Network Gateway connection"
  value = { for k, v in azurerm_virtual_network_gateway_connection.this : k => {
    dh_group         = v.ipsec_policy[0].dh_group
    ike_encryption   = v.ipsec_policy[0].ike_encryption
    ike_integrity    = v.ipsec_policy[0].ike_integrity
    ipsec_encryption = v.ipsec_policy[0].ipsec_encryption
    ipsec_integrity  = v.ipsec_policy[0].ipsec_integrity
    pfs_group        = v.ipsec_policy[0].pfs_group
  } if length(v.ipsec_policy) > 0 }
}
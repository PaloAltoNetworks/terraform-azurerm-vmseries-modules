
output "panorama-publicip" {
  value = { for idx, pip in azurerm_public_ip.panorama-pip-mgmt[*].ip_address :
    "${var.name_prefix}${var.sep}${var.name_panorama}-${element(var.panorama_ha_suffix_map, idx)}" => pip
  }
  description = "Panorama Public IP addresses"
}

output "resource-group" {
  value       = azurerm_resource_group.panorama
  description = "Panorama Resource group resource"
}

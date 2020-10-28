# Permit All outbound traffic in Panorma Managemnet VNET
resource "azurerm_network_security_rule" "panorama-allowall-outbound" {
  name                        = "${var.name_prefix}${var.sep}${var.name_panorama_allowall_outbound}"
  resource_group_name         = azurerm_resource_group.rg.name
  access                      = "Allow"
  direction                   = "Outbound"
  network_security_group_name = azurerm_network_security_group.sg-panorama-mgmt.name
  priority                    = 100
  protocol                    = "*"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
}

# Permit the external (admin) ips access  to the management networks.
resource "azurerm_network_security_rule" "management-rules" {
  for_each                    = var.management_ips
  name                        = "${var.name_prefix}${var.sep}${var.name_management_rules}${var.sep}${each.value}"
  resource_group_name         = azurerm_resource_group.rg.name
  access                      = "Allow"
  direction                   = "Inbound"
  network_security_group_name = azurerm_network_security_group.sg-panorama-mgmt.name
  priority                    = each.value
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = each.key
  destination_address_prefix  = "0.0.0.0/0"
  destination_port_range      = "*"
}


# Permit All outbound traffic in vm-series Management VNET
resource "azurerm_network_security_rule" "vmseries-allowall-outbound" {
  name                        = "${var.name_prefix}${var.sep}${var.name_vmseries_allowall_outbound}"
  resource_group_name         = azurerm_resource_group.rg.name
  access                      = "Allow"
  direction                   = "Outbound"
  network_security_group_name = azurerm_network_security_group.sg-mgmt.name
  priority                    = 100
  protocol                    = "*"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
}

# Permit All Inbound traffic in Outside VNET
# required due to Standard type LB
resource "azurerm_network_security_rule" "outside-allowall-inbound" {
  name                        = "${var.name_prefix}${var.sep}${var.name_outside_allowall_inbound}"
  resource_group_name         = azurerm_resource_group.rg.name
  access                      = "Allow"
  direction                   = "Inbound"
  network_security_group_name = azurerm_network_security_group.sg-allowall.name
  priority                    = 100
  protocol                    = "*"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
}
resource "azurerm_network_security_rule" "outside-allowall-outbound" {
  name                        = "${var.name_prefix}${var.sep}${var.name_vmseries_allowall_outbound}"
  resource_group_name         = azurerm_resource_group.rg.name
  access                      = "Allow"
  direction                   = "Outbound"
  network_security_group_name = azurerm_network_security_group.sg-allowall.name
  priority                    = 101
  protocol                    = "*"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
}

# Permit the external (admin) ips access  to the management networks.
resource "azurerm_network_security_rule" "vm-management-rules" {
  for_each                    = var.management_ips
  name                        = "${var.name_prefix}${var.sep}${var.name_management_rules}${var.sep}${each.value}"
  resource_group_name         = azurerm_resource_group.rg.name
  access                      = "Allow"
  direction                   = "Inbound"
  network_security_group_name = azurerm_network_security_group.sg-mgmt.name
  priority                    = each.value
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = each.key
  destination_address_prefix  = "0.0.0.0/0"
  destination_port_range      = "*"
}
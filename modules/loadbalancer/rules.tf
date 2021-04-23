
resource "azurerm_network_security_rule" "allow_inbound_ips" {
  for_each = { for k, v in local.output_rules : k => v
    if var.network_security_group_name != null && var.network_security_group_name != "" && length(var.network_security_allow_source_ips) > 0
  }

  name                        = "allow-inbound-ips-${each.key}"
  resource_group_name         = coalesce(var.network_security_resource_group_name, var.resource_group_name)
  network_security_group_name = var.network_security_group_name
  priority                    = each.value.index + var.network_security_base_priority
  direction                   = "inbound"
  access                      = "allow"
  protocol                    = replace(each.value.protocol, "all", "*")
  description                 = "Load balancer ${var.name} port ${each.value.protocol}/${each.value.port}: allowed inbound IP ranges"
  source_port_range           = "*"
  destination_port_ranges     = [each.value.port == "0" ? "*" : each.value.port]
  source_address_prefixes     = var.network_security_allow_source_ips
  destination_address_prefix  = each.value.frontend_ip
}


resource "azurerm_network_security_rule" "allow_inbound_ips" {
  # In order to generate unique numerical `priority`, we need a numerical index. So, lets use keys() for that:
  for_each = { for i, k in keys(local.input_rules) : k => {
    index       = i
    port        = local.input_rules[k].rule.port
    protocol    = lower(local.input_rules[k].rule.protocol)
    frontend_ip = local.frontend_ip_configs[local.input_rules[k].fipkey]
    } if var.network_security_group_name != null && var.network_security_group_name != "" && length(var.network_security_allow_source_ips) > 0
  }

  name                        = "allow-inbound-ips-${each.key}"
  resource_group_name         = coalesce(var.network_security_resource_group_name, var.resource_group_name)
  network_security_group_name = var.network_security_group_name
  priority                    = each.value.index + var.network_security_base_priority
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = replace(each.value.protocol, "all", "*")
  description                 = "Load balancer ${var.name} port ${each.value.protocol}/${each.value.port}: allowed inbound IP ranges"
  source_port_range           = "*"
  destination_port_ranges     = [each.value.port == "0" ? "*" : each.value.port]
  source_address_prefixes     = var.network_security_allow_source_ips
  destination_address_prefix  = each.value.frontend_ip
}

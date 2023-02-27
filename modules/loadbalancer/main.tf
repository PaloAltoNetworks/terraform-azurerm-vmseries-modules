locals {
  # Decide how the backend machines access internet. If outbound rules are defined use them instead of the default route.
  # This is an inbound rule setting, applicable to all inbound rules.
  disable_outbound_snat = length(var.outbound_rules) > 0

  # Recalculate the main input map, taking into account whether the boolean condition is true/false.
  frontend_ips = {
    for k, v in var.frontend_ips : k => {
      name  = k
      rules = try(v.rules, {})
    }
  }

  # A list of all rules: outbound and inbound
  all_rules = merge(var.frontend_ips, var.outbound_rules)

  # Frontend ip configurations, no rules, only PIPs.
  # The `if` statement is to avoid errors in LB configuration when re-using a PIP created by some other rule.
  frontend_ip_configurations = {
    for k, v in local.all_rules : k => {
      name                          = k
      public_ip_address_id          = try(v.create_public_ip, false) ? azurerm_public_ip.this[k].id : try(data.azurerm_public_ip.exists[k].id, null)
      create_public_ip              = try(v.create_public_ip, false)
      zones                         = try(v.zones, null)
      subnet_id                     = try(v.subnet_id, null)
      private_ip_address_allocation = try(v.private_ip_address_allocation, null)
      private_ip_address            = try(v.private_ip_address, null)
    }
    if try(v.create_public_ip, false) || !can(local.all_rules[v.public_ip_name])
  }

  # Terraform for_each unfortunately requires a single-dimensional map, but we have
  # a two-dimensional input. We need two steps for conversion.

  # Firstly, flatten() ensures that this local value is a flat list of objects, rather
  # than a list of lists of objects.
  input_flat_rules = flatten([
    for fipkey, fip in local.frontend_ips : [
      for rulekey, rule in fip.rules : {
        fipkey  = fipkey
        fip     = fip
        rulekey = rulekey
        rule    = rule
      }
    ]
  ])

  # Finally, convert flat list to a flat map. Make sure the keys are unique. This is used for for_each.
  input_rules = { for v in local.input_flat_rules : "${v.fipkey}-${v.rulekey}" => v }

  # Now, the outputs to be returned by the module. First, calculate the raw IP addresses.
  output_ips = { for _, v in azurerm_lb.lb.frontend_ip_configuration : v.name => try(data.azurerm_public_ip.exists[v.name].ip_address, azurerm_public_ip.this[v.name].ip_address, v.private_ip_address) }

  # A more rich output combines the raw IP addresses with more attributes.
  # As the later NSGs demand that troublesome numerical `priority` attribute, we
  # need to generate unique numerical `index`. So, lets use keys() for that:
  output_rules = {
    for i, k in keys(local.input_rules) : k => {
      index        = i
      fipkey       = local.input_rules[k].fipkey
      rulekey      = local.input_rules[k].rulekey
      port         = local.input_rules[k].rule.port
      backend_port = try(local.input_rules[k].rule.backend_port, null)
      nsg_priority = lookup(local.input_rules[k].rule, "nsg_priority", null)
      protocol     = lower(local.input_rules[k].rule.protocol)
      frontend_ip  = local.output_ips[local.input_rules[k].fipkey]
      // The hash16 is 16-bit in size, just crudely yank the initial digits of sha256.
      hash16 = parseint(substr(sha256("${local.output_ips[local.input_rules[k].fipkey]}:${local.input_rules[k].rule.port}"), 0, 4), 16)
    }
  }
}



resource "azurerm_public_ip" "this" {
  for_each = { for k, v in local.all_rules :
  k => v if try(v.create_public_ip, false) }

  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.enable_zones ? var.avzones : null
  tags                = var.tags
}

data "azurerm_public_ip" "exists" {
  for_each = { for k, v in local.all_rules :
  k => v if try(v.public_ip_name, null) != null }

  name                = each.value.public_ip_name
  resource_group_name = try(each.value.public_ip_resource_group, var.resource_group_name)
}

resource "azurerm_lb" "lb" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  tags                = var.tags

  dynamic "frontend_ip_configuration" {
    for_each = local.frontend_ip_configurations
    iterator = each
    content {
      name                          = each.value.name
      public_ip_address_id          = each.value.public_ip_address_id
      subnet_id                     = each.value.subnet_id
      private_ip_address_allocation = each.value.private_ip_address_allocation
      private_ip_address            = each.value.private_ip_address_allocation == "Static" ? each.value.private_ip_address : null
      zones                         = try(each.value.zones, null) == null ? [] : each.value.zones
      # Azure error message says: "Networking supports zones only for frontendIpconfigurations which reference a subnet."
      # Therefore availability_zone null has a very different meaning depending whether subnet_id is null or not.
    }
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend" {
  name            = coalesce(var.backend_name, var.name)
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "probe" {
  name            = coalesce(var.probe_name, var.name)
  loadbalancer_id = azurerm_lb.lb.id
  port            = var.probe_port
}

resource "azurerm_lb_rule" "lb_rules" {
  for_each = local.input_rules

  name                     = each.key
  loadbalancer_id          = azurerm_lb.lb.id
  probe_id                 = azurerm_lb_probe.probe.id
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_backend.id]

  protocol                       = each.value.rule.protocol
  backend_port                   = try(each.value.rule.backend_port, each.value.rule.port)
  frontend_ip_configuration_name = each.value.fip.name
  frontend_port                  = each.value.rule.port
  enable_floating_ip             = try(each.value.rule.floating_ip, true)
  disable_outbound_snat          = local.disable_outbound_snat
  load_distribution              = try(each.value.rule.session_persistence, null)
}

resource "azurerm_lb_outbound_rule" "outb_rules" {
  for_each = var.outbound_rules

  name                    = each.key
  loadbalancer_id         = azurerm_lb.lb.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend.id

  protocol                 = each.value.protocol
  enable_tcp_reset         = each.value.protocol != "Udp" ? try(each.value.enable_tcp_reset, null) : null
  allocated_outbound_ports = try(each.value.allocated_outbound_ports, null)
  idle_timeout_in_minutes  = each.value.protocol != "Udp" ? try(each.value.idle_timeout_in_minutes, null) : null

  frontend_ip_configuration {
    name = try(each.value.create_public_ip, false) ? azurerm_public_ip.this[each.key].name : data.azurerm_public_ip.exists[each.key].name
  }
}

# Optional NSG rules. Each corresponds to one azurerm_lb_rule.
resource "azurerm_network_security_rule" "allow_inbound_ips" {
  for_each = {
    for k, v in local.output_rules : k => v
    if var.network_security_group_name != null && var.network_security_group_name != "" && length(var.network_security_allow_source_ips) > 0
  }

  name                        = "allow-inbound-ips-${each.key}"
  resource_group_name         = coalesce(var.network_security_resource_group_name, var.resource_group_name)
  network_security_group_name = var.network_security_group_name
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = title(replace(each.value.protocol, "all", "*"))
  description                 = "Auto-generated for load balancer ${var.name} port ${each.value.protocol}/${coalesce(each.value.backend_port, each.value.port)}: allowed inbound IP ranges"
  source_port_range           = "*"
  destination_port_ranges     = [each.value.port == "0" ? "*" : coalesce(each.value.backend_port, each.value.port)]
  source_address_prefixes     = var.network_security_allow_source_ips
  destination_address_prefix  = each.value.frontend_ip
  # For the priority, we add this %10 so that the numbering would be a bit more sparse instead of sequential.
  # This helps tremendously when a mass of indexes shifts by +1 or -1:
  priority = coalesce(each.value.nsg_priority, each.value.index * 10 + each.value.hash16 % 10 + var.network_security_base_priority)
}

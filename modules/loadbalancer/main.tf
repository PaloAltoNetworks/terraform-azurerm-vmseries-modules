locals {
  # Decide how the backend machines access internet. If outbound rules are defined use them instead of the default route.
  # This is an inbound rule setting, applicable to all inbound rules as you cannot mix SNAT with Outbound rules for a single backend.
  disable_outbound_snat = anytrue([for _, v in var.frontend_ips : try(length(v.out_rules) > 0, false)])

  # Calculate inbound rules
  in_flat_rules = flatten([
    for fipkey, fip in var.frontend_ips : [
      for rulekey, rule in try(fip.in_rules, {}) : {
        fipkey  = fipkey
        fip     = fip
        rulekey = rulekey
        rule    = rule
      }
    ]
  ])
  in_rules = { for v in local.in_flat_rules : "${v.fipkey}-${v.rulekey}" => v }

  # Calculate outbound rules
  out_flat_rules = flatten([
    for fipkey, fip in var.frontend_ips : [
      for rulekey, rule in try(fip.out_rules, {}) : {
        fipkey  = fipkey
        fip     = fip
        rulekey = rulekey
        rule    = rule
      }
    ]
  ])
  out_rules = { for v in local.out_flat_rules : "${v.fipkey}-${v.rulekey}" => v }
}

resource "azurerm_public_ip" "this" {
  for_each = { for k, v in var.frontend_ips : k => v if try(v.create_public_ip, false) }

  name                = "${var.name}-${each.key}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.enable_zones ? var.avzones : null
  tags                = var.tags
}

data "azurerm_public_ip" "this" {
  for_each = {
    for k, v in var.frontend_ips : k => v
    if try(v.public_ip_name, null) != null && !try(v.create_public_ip, false)
  }

  name                = try(each.value.public_ip_name, "")
  resource_group_name = try(each.value.public_ip_resource_group, var.resource_group_name, "")
}

resource "azurerm_lb" "lb" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  tags                = var.tags

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ips
    iterator = each
    content {
      name                          = each.key
      public_ip_address_id          = try(each.value.create_public_ip, false) ? azurerm_public_ip.this[each.key].id : try(data.azurerm_public_ip.this[each.key].id, null)
      subnet_id                     = try(each.value.subnet_id, null)
      private_ip_address_allocation = try(each.value.private_ip_address, null) != null ? "Static" : null
      private_ip_address            = try(each.value.private_ip_address, null)
      zones                         = try(each.value.subnet_id, null) != null ? var.avzones : []

      gateway_load_balancer_frontend_ip_configuration_id = try(each.value.gateway_load_balancer_frontend_ip_configuration_id, null)
    }
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend" {
  name            = var.backend_name
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "probe" {
  name            = var.probe_name
  loadbalancer_id = azurerm_lb.lb.id
  port            = var.probe_port
}

resource "azurerm_lb_rule" "in_rules" {
  for_each = local.in_rules

  name                     = each.key
  loadbalancer_id          = azurerm_lb.lb.id
  probe_id                 = azurerm_lb_probe.probe.id
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_backend.id]

  protocol                       = each.value.rule.protocol
  backend_port                   = coalesce(try(each.value.rule.backend_port, null), each.value.rule.port)
  frontend_ip_configuration_name = each.value.fipkey
  frontend_port                  = each.value.rule.port
  enable_floating_ip             = try(each.value.rule.floating_ip, true)
  disable_outbound_snat          = local.disable_outbound_snat
  load_distribution              = try(each.value.rule.session_persistence, null)
}

resource "azurerm_lb_outbound_rule" "out_rules" {
  for_each = local.out_rules

  name                    = each.key
  loadbalancer_id         = azurerm_lb.lb.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend.id

  protocol                 = each.value.rule.protocol
  enable_tcp_reset         = each.value.rule.protocol != "Udp" ? try(each.value.rule.enable_tcp_reset, null) : null
  allocated_outbound_ports = try(each.value.rule.allocated_outbound_ports, null)
  idle_timeout_in_minutes  = each.value.rule.protocol != "Udp" ? try(each.value.rule.idle_timeout_in_minutes, null) : null

  frontend_ip_configuration {
    name = each.value.fipkey
  }
}

locals {
  # Map of all frontend IP addresses, public or private.
  frontend_addresses = {
    for v in azurerm_lb.lb.frontend_ip_configuration : v.name => try(data.azurerm_public_ip.this[v.name].ip_address, azurerm_public_ip.this[v.name].ip_address, v.private_ip_address)
  }

  # A map of hashes calculated for each inbound rule. Used to calculate NSG inbound rules priority index if modules is also used to automatically manage NSG rules. 
  rules_hash = {
    for k, v in local.in_rules : k => substr(
      sha256("${local.frontend_addresses[v.fipkey]}:${v.rule.port}"),
      0,
      4
    )
    if var.network_security_group_name != null && var.network_security_group_name != "" && length(var.network_security_allow_source_ips) > 0
  }
}

# Optional NSG rules. Each corresponds to one azurerm_lb_rule.
resource "azurerm_network_security_rule" "allow_inbound_ips" {
  for_each = {
    for k, v in local.in_rules : k => v
    if var.network_security_group_name != null && var.network_security_group_name != "" && length(var.network_security_allow_source_ips) > 0
  }

  name                        = "allow-inbound-ips-${each.key}"
  network_security_group_name = var.network_security_group_name
  resource_group_name         = coalesce(var.network_security_resource_group_name, var.resource_group_name)
  description                 = "Auto-generated for load balancer ${var.name} port ${each.value.rule.protocol}/${try(each.value.rule.backend_port, each.value.rule.port)}: allowed inbound IP ranges"

  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = title(replace(lower(each.value.rule.protocol), "all", "*"))
  source_port_range          = "*"
  destination_port_ranges    = [each.value.rule.port == "0" ? "*" : try(each.value.rule.backend_port, each.value.rule.port)]
  source_address_prefixes    = var.network_security_allow_source_ips
  destination_address_prefix = local.frontend_addresses[each.value.fipkey]

  # For the priority, we add this %10 so that the numbering would be a bit more sparse instead of sequential.
  # This helps tremendously when a mass of indexes shifts by +1 or -1 and prevents problems when we need to shift rules reusing already used priority index.
  priority = try(
    each.value.rule.nsg_priority,
    index(keys(local.in_rules), each.key) * 10 + parseint(local.rules_hash[each.key], 16) % 10 + var.network_security_base_priority
  )
}

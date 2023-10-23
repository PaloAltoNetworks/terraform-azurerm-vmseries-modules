locals {
  # Decide how the backend machines access internet. If outbound rules are defined use them instead of the default route.
  # This is an inbound rule setting, applicable to all inbound rules as you cannot mix SNAT with Outbound rules for a single backend.
  disable_outbound_snat = anytrue([for _, v in var.frontend_ips : length(v.out_rules) != 0])

  # Calculate inbound rules
  in_flat_rules = flatten([
    for fipkey, fip in var.frontend_ips : [
      for rulekey, rule in fip.in_rules : {
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
      for rulekey, rule in fip.out_rules : {
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
  for_each = { for k, v in var.frontend_ips : k => v if v.create_public_ip }

  name                = each.value.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
  tags                = var.tags
}

data "azurerm_public_ip" "this" {
  for_each = { for k, v in var.frontend_ips : k => v if !v.create_public_ip && v.public_ip_name != null }

  name                = each.value.public_ip_name
  resource_group_name = coalesce(each.value.public_ip_resource_group, var.resource_group_name)
}

resource "azurerm_lb" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  tags                = var.tags

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ips
    iterator = frontend_ip
    content {
      name                          = frontend_ip.value.name
      public_ip_address_id          = frontend_ip.value.create_public_ip ? azurerm_public_ip.this[frontend_ip.key].id : try(data.azurerm_public_ip.this[frontend_ip.key].id, null)
      subnet_id                     = frontend_ip.value.subnet_id
      private_ip_address_allocation = frontend_ip.value.private_ip_address != null ? "Static" : null
      private_ip_address            = frontend_ip.value.private_ip_address
      zones                         = frontend_ip.value.subnet_id != null ? var.zones : null

      gateway_load_balancer_frontend_ip_configuration_id = frontend_ip.value.gateway_load_balancer_frontend_ip_configuration_id
    }
  }

  lifecycle {
    precondition {
      condition = !(
        anytrue(
          [for _, fip in var.frontend_ips : fip.public_ip_name != null]
          ) && anytrue(
          [for _, fip in var.frontend_ips : fip.subnet_id != null]
        )
      )
      error_message = "All frontends have to be of the same type, either public or private. Please check module's documentation (Usage section) for details."
    }
  }
}

resource "azurerm_lb_backend_address_pool" "this" {
  name            = var.backend_name
  loadbalancer_id = azurerm_lb.this.id
}

locals {
  default_http_probe_port = {
    "Http"  = 80
    "Https" = "443"
  }
  default_probe = (
    var.health_probes == null || anytrue(flatten([
      for _, fip in var.frontend_ips : [
        for _, rule in fip.in_rules : rule.health_probe_key == "default"
      ]
    ]))
    ) ? {
    default = {
      name                = "default_vmseries_probe"
      protocol            = "Tcp"
      port                = 80
      probe_threshold     = null
      interval_in_seconds = null
      request_path        = null
    }
  } : {}
}

resource "azurerm_lb_probe" "this" {
  for_each = merge(coalesce(var.health_probes, {}), local.default_probe)

  loadbalancer_id = azurerm_lb.this.id

  name                = each.value.name
  protocol            = each.value.protocol
  port                = contains(["Http", "Https"], each.value.protocol) && each.value.port == null ? local.default_http_probe_port[each.value.protocol] : each.value.port
  probe_threshold     = each.value.probe_threshold
  interval_in_seconds = each.value.interval_in_seconds
  request_path        = each.value.protocol != "Tcp" ? each.value.request_path : null

  # this is to overcome the discrepancy between the provider and Azure defaults
  # for more details see here -> https://learn.microsoft.com/en-gb/azure/load-balancer/whats-new#known-issues:~:text=SNAT%20port%20exhaustion-,numberOfProbes,-%2C%20%22Unhealthy%20threshold%22
  number_of_probes = 1
}

resource "azurerm_lb_rule" "this" {
  for_each = local.in_rules

  name                     = each.value.rule.name
  loadbalancer_id          = azurerm_lb.this.id
  probe_id                 = azurerm_lb_probe.this[each.value.rule.health_probe_key].id
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.this.id]

  protocol                       = each.value.rule.protocol
  backend_port                   = coalesce(each.value.rule.backend_port, each.value.rule.port)
  frontend_ip_configuration_name = each.value.fip.name
  frontend_port                  = each.value.rule.port
  enable_floating_ip             = each.value.rule.floating_ip
  disable_outbound_snat          = local.disable_outbound_snat
  load_distribution              = each.value.rule.session_persistence
}

resource "azurerm_lb_outbound_rule" "this" {
  for_each = local.out_rules

  name                    = each.value.rule.name
  loadbalancer_id         = azurerm_lb.this.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.this.id

  protocol                 = each.value.rule.protocol
  enable_tcp_reset         = each.value.rule.protocol != "Udp" ? each.value.rule.enable_tcp_reset : null
  allocated_outbound_ports = each.value.rule.allocated_outbound_ports
  idle_timeout_in_minutes  = each.value.rule.protocol != "Udp" ? each.value.rule.idle_timeout_in_minutes : null

  frontend_ip_configuration {
    name = each.value.fip.name
  }
  depends_on = [azurerm_lb_rule.this]
}

locals {
  # Map of all frontend IP addresses, public or private.
  frontend_addresses = {
    for k, v in var.frontend_ips : k => try(data.azurerm_public_ip.this[k].ip_address, azurerm_public_ip.this[k].ip_address, v.private_ip_address)
  }

  # A map of hashes calculated for each inbound rule. Used to calculate NSG inbound rules priority index if modules is also used to automatically manage NSG rules. 
  rules_hash = {
    for k, v in local.in_rules :
    k => substr(sha256("${local.frontend_addresses[v.fipkey]}:${v.rule.port}"), 0, 4)
    if var.nsg_auto_rules_settings != null
  }
}

# Optional NSG rules. Each corresponds to one azurerm_lb_rule.
resource "azurerm_network_security_rule" "this" {
  for_each = { for k, v in local.in_rules : k => v if var.nsg_auto_rules_settings != null }

  name                        = "allow-inbound-ips-${each.key}"
  network_security_group_name = var.nsg_auto_rules_settings.nsg_name
  resource_group_name         = coalesce(var.nsg_auto_rules_settings.nsg_resource_group_name, var.resource_group_name)
  description                 = "Auto-generated for load balancer ${var.name} port ${each.value.rule.protocol}/${coalesce(each.value.rule.backend_port, each.value.rule.port)}: allowed IPs: ${join(",", var.nsg_auto_rules_settings.source_ips)}"

  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = title(replace(lower(each.value.rule.protocol), "all", "*"))
  source_port_range          = "*"
  destination_port_ranges    = [each.value.rule.port == "0" ? "*" : coalesce(each.value.rule.backend_port, each.value.rule.port)]
  source_address_prefixes    = var.nsg_auto_rules_settings.source_ips
  destination_address_prefix = local.frontend_addresses[each.value.fipkey]

  # For the priority, we add this %10 so that the numbering would be a bit more sparse instead of sequential.
  # This helps tremendously when a mass of indexes shifts by +1 or -1 and prevents problems when we need to shift rules reusing already used priority index.
  priority = coalesce(
    each.value.rule.nsg_priority,
    index(keys(local.in_rules), each.key) * 10 + parseint(local.rules_hash[each.key], 16) % 10 + var.nsg_auto_rules_settings.base_priority
  )
}

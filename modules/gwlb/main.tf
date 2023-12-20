# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb
resource "azurerm_lb" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Gateway"
  tags                = var.tags

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ips
    iterator = frontend_ip
    content {
      name                          = frontend_ip.value.name
      private_ip_address_allocation = frontend_ip.value.private_ip_address_allocation
      private_ip_address_version    = frontend_ip.value.private_ip_address_version
      private_ip_address            = frontend_ip.value.private_ip_address
      subnet_id                     = frontend_ip.value.subnet_id
      zones                         = frontend_ip.value.subnet_id != null ? var.zones : null
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool
resource "azurerm_lb_backend_address_pool" "this" {
  for_each = var.backends

  name            = coalesce(each.value.name, "${var.name}-${each.key}")
  loadbalancer_id = azurerm_lb.this.id

  dynamic "tunnel_interface" {
    for_each = each.value.tunnel_interfaces
    content {
      identifier = tunnel_interface.value.identifier
      port       = tunnel_interface.value.port
      protocol   = tunnel_interface.value.protocol
      type       = tunnel_interface.value.type
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe
resource "azurerm_lb_probe" "this" {
  for_each = var.health_probes

  name            = coalesce(each.value.name, var.name)
  loadbalancer_id = azurerm_lb.this.id

  port                = each.value.port
  protocol            = each.value.protocol
  probe_threshold     = each.value.probe_threshold
  request_path        = each.value.request_path
  interval_in_seconds = each.value.interval_in_seconds
  number_of_probes    = each.value.number_of_probes
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule
resource "azurerm_lb_rule" "this" {
  for_each = var.lb_rules

  name            = coalesce(each.value.name, azurerm_lb.this.frontend_ip_configuration[0].name)
  loadbalancer_id = azurerm_lb.this.id
  probe_id        = azurerm_lb_probe.this[each.value.health_probe_key].id

  frontend_ip_configuration_name = azurerm_lb.this.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [for _, v in azurerm_lb_backend_address_pool.this : v.id]
  load_distribution              = each.value.load_distribution

  # HA port rule - required by Azure GWLB
  protocol      = "All"
  backend_port  = 0
  frontend_port = 0
}

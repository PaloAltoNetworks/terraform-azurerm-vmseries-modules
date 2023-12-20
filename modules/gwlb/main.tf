resource "azurerm_lb" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Gateway"
  tags                = var.tags

  frontend_ip_configuration {
    name                          = var.frontend_ip.name
    private_ip_address_allocation = var.frontend_ip.private_ip_address_allocation
    private_ip_address_version    = var.frontend_ip.private_ip_address_version
    private_ip_address            = var.frontend_ip.private_ip_address
    subnet_id                     = var.frontend_ip.subnet_id
    zones                         = var.frontend_ip.subnet_id != null ? var.zones : null
  }
}

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

resource "azurerm_lb_rule" "this" {
  name            = try(var.lb_rule.name, azurerm_lb.this.frontend_ip_configuration[0].name)
  loadbalancer_id = azurerm_lb.this.id
  probe_id        = azurerm_lb_probe.this["default"].id

  frontend_ip_configuration_name = azurerm_lb.this.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [for _, v in azurerm_lb_backend_address_pool.this : v.id]
  load_distribution              = try(var.lb_rule.load_distribution, null)

  # HA port rule - required by Azure GWLB
  protocol      = "All"
  backend_port  = 0
  frontend_port = 0
}
resource "azurerm_lb" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Gateway"

  frontend_ip_configuration {
    name                          = try(var.frontend_ip_config.name, var.name)
    private_ip_address_allocation = try(var.frontend_ip_config.private_ip_address_allocation, null)
    private_ip_address_version    = try(var.frontend_ip_config.private_ip_address_version, null)
    private_ip_address            = try(var.frontend_ip_config.private_ip_address, null)
    subnet_id                     = var.frontend_ip_config.subnet_id
    zones                         = try(var.frontend_ip_config.zones, null)
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "this" {
  for_each = var.backends

  name            = try(each.value.name, "${var.name}-${each.key}")
  loadbalancer_id = azurerm_lb.this.id

  dynamic "tunnel_interface" {
    for_each = each.value.tunnel_interfaces
    content {
      identifier = tunnel_interface.value.identifier
      port       = tunnel_interface.value.port
      protocol   = "VXLAN"
      type       = tunnel_interface.value.type
    }
  }
}

resource "azurerm_lb_probe" "this" {
  name            = try(var.health_probe.name, var.name)
  loadbalancer_id = azurerm_lb.this.id

  port                = try(var.health_probe.port, null)
  protocol            = try(var.health_probe.protocol, null)
  probe_threshold     = try(var.health_probe.probe_threshold, null)
  request_path        = try(var.health_probe.request_path, null)
  interval_in_seconds = try(var.health_probe.interval_in_seconds, null)
  number_of_probes    = try(var.health_probe.number_of_probes, null)
}

resource "azurerm_lb_rule" "this" {
  name            = try(var.lb_rule.name, azurerm_lb.this.frontend_ip_configuration[0].name)
  loadbalancer_id = azurerm_lb.this.id
  probe_id        = azurerm_lb_probe.this.id

  frontend_ip_configuration_name = azurerm_lb.this.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [for _, v in azurerm_lb_backend_address_pool.this : v.id]
  load_distribution              = try(var.lb_rule.load_distribution, null)

  # HA port rule - required by Azure GWLB
  protocol      = "All"
  backend_port  = 0
  frontend_port = 0
}
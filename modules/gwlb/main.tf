# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb
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
  name            = coalesce(var.health_probe.name, var.name)
  loadbalancer_id = azurerm_lb.this.id

  port                = var.health_probe.port
  protocol            = var.health_probe.protocol
  probe_threshold     = var.health_probe.probe_threshold
  request_path        = var.health_probe.request_path
  interval_in_seconds = var.health_probe.interval_in_seconds
  number_of_probes    = var.health_probe.number_of_probes
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule
resource "azurerm_lb_rule" "this" {
  name            = coalesce(var.lb_rule.name, azurerm_lb.this.frontend_ip_configuration[0].name)
  loadbalancer_id = azurerm_lb.this.id
  probe_id        = azurerm_lb_probe.this.id

  frontend_ip_configuration_name = azurerm_lb.this.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [for _, v in azurerm_lb_backend_address_pool.this : v.id]
  load_distribution              = var.lb_rule.load_distribution

  # HA port rule - required by Azure GWLB
  protocol      = "All"
  backend_port  = 0
  frontend_port = 0
}

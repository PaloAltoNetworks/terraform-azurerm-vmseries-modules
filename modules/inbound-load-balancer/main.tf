resource "azurerm_resource_group" "rg-lb" {
  name     = "${var.name_prefix}${var.sep}${var.name_rg}"
  location = var.location
}

resource "azurerm_public_ip" "this" {
  for_each = { for k, rule in var.rules
    :
    k => rule if rule.create_public_ip
  }

  name                = "${var.name_prefix}-${each.value.port}"
  location            = azurerm_resource_group.rg-lb.location
  resource_group_name = azurerm_resource_group.rg-lb.name
  allocation_method   = "Static"
  sku                 = "standard"
}

resource "azurerm_lb" "lb" {
  name                = "${var.name_prefix}${var.sep}${var.name_lb}"
  location            = azurerm_resource_group.rg-lb.location
  resource_group_name = azurerm_resource_group.rg-lb.name
  sku                 = "standard"

  dynamic "frontend_ip_configuration" {
    for_each = var.rules
    content {
      name                 = frontend_ip_configuration.value.create_public_ip ? "${azurerm_public_ip.this[frontend_ip_configuration.key].name}-fip" : frontend_ip_configuration.value.frontend_ip_configuration_name
      public_ip_address_id = frontend_ip_configuration.value.create_public_ip ? azurerm_public_ip.this[frontend_ip_configuration.key].id : frontend_ip_configuration.value.public_ip_address_id
    }
  }
}

resource "azurerm_lb_backend_address_pool" "lb-backend" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "${var.name_prefix}${var.sep}${var.name_backend}"
  resource_group_name = azurerm_resource_group.rg-lb.name
}

resource "azurerm_lb_probe" "probe" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "${var.name_prefix}${var.sep}${var.name_probe}"
  port                = 80
  resource_group_name = azurerm_resource_group.rg-lb.name
}

resource "azurerm_lb_rule" "lb-rules" {
  for_each = var.rules

  name                    = each.key
  resource_group_name     = azurerm_resource_group.rg-lb.name
  loadbalancer_id         = azurerm_lb.lb.id
  probe_id                = azurerm_lb_probe.probe.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-backend.id

  protocol                       = each.value.protocol
  backend_port                   = each.value.port
  frontend_ip_configuration_name = each.value.create_public_ip ? "${azurerm_public_ip.this[each.key].name}-fip" : each.value.frontend_ip_configuration_name
  frontend_port                  = each.value.port
  enable_floating_ip             = true
}

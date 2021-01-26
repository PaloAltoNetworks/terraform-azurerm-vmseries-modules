resource "azurerm_resource_group" "rg-lb" {
  name     = "${var.name_prefix}${var.sep}${var.name_rg}"
  location = var.location
}

resource "azurerm_public_ip" "lb-fip-pip" {
  for_each = { for rule in var.rules : rule.port => rule }

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
    for_each = azurerm_public_ip.lb-fip-pip
    content {
      name                 = "${frontend_ip_configuration.value.name}-fip"
      public_ip_address_id = frontend_ip_configuration.value.id
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
  for_each = { for rule in var.rules : rule.port => rule }

  name                    = "${each.value.name}${var.sep}${var.name_lbrule}"
  resource_group_name     = azurerm_resource_group.rg-lb.name
  loadbalancer_id         = azurerm_lb.lb.id
  probe_id                = azurerm_lb_probe.probe.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-backend.id

  protocol                       = each.value.protocol
  backend_port                   = each.value.port
  frontend_ip_configuration_name = "${var.name_prefix}-${each.value.port}-fip"
  frontend_port                  = each.value.port
  enable_floating_ip             = true
}

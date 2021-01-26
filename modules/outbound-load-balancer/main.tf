resource "azurerm_resource_group" "rg-lb" {
  name     = "${var.name_prefix}${var.sep}${var.name_rg}"
  location = var.location
}

resource "azurerm_lb" "lb" {
  name                = "${var.name_prefix}${var.sep}${var.name_lb}"
  location            = azurerm_resource_group.rg-lb.location
  resource_group_name = azurerm_resource_group.rg-lb.name
  sku                 = "standard"

  frontend_ip_configuration {
    name                          = "${var.name_prefix}${var.sep}${var.name_lb_fip}"
    private_ip_address            = var.private-ip
    subnet_id                     = var.backend-subnet
    private_ip_address_allocation = "Static"
  }
}

resource "azurerm_lb_backend_address_pool" "lb-backend" {
  name                = "${var.name_prefix}${var.sep}${var.name_lb_backend}"
  loadbalancer_id     = azurerm_lb.lb.id
  resource_group_name = azurerm_resource_group.rg-lb.name
}

resource "azurerm_lb_probe" "probe" {
  name                = "${var.name_prefix}${var.sep}${var.name_probe}"
  port                = 80
  loadbalancer_id     = azurerm_lb.lb.id
  resource_group_name = azurerm_resource_group.rg-lb.name
}

# This LB rule forwards all traffic on all ports to the provided backend servers.
resource "azurerm_lb_rule" "lb-rules" {
  name                           = "${azurerm_lb.lb.name}${var.sep}${var.name_lb_rule}"
  resource_group_name            = azurerm_resource_group.rg-lb.name
  loadbalancer_id                = azurerm_lb.lb.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb-backend.id
  probe_id                       = azurerm_lb_probe.probe.id
  backend_port                   = 0
  frontend_ip_configuration_name = "${var.name_prefix}${var.sep}${var.name_lb_fip}"
  frontend_port                  = 0
  protocol                       = "All"
}

/*
* outbound-load-balancer terraform module
* ===========
* 
* A terraform module for creating all the networking components required for VM series firewalls in Azure.
* 
* Usage
* -----
* 
* ```hcl
* module "outbound-lb" {
*   source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/networking"
*
*   location         = "Australia Central"
*   name_prefix      = "panostf"
*   backend-subnet   = "subnet-id"
* }
* ```
*/
# Sets up an Azure LB and associated rules
# This sets up an OUTBOUND LB and associated rules
# It does not have a public IP associated with it.

resource "azurerm_resource_group" "rg-lb" {
  location = var.location
  name     = "${var.name_prefix}${var.sep}${var.name_rg}"
}

resource "azurerm_lb" "lb" {
  location            = var.location
  name                = "${var.name_prefix}${var.sep}${var.name_lb}"
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
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "${var.name_prefix}${var.sep}${var.name_lb_backend}"
  resource_group_name = azurerm_resource_group.rg-lb.name
}

resource "azurerm_lb_probe" "probe" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "${var.name_prefix}${var.sep}${var.name_probe}"
  port                = 80
  resource_group_name = azurerm_resource_group.rg-lb.name
}

# This LB rule forwards all traffic on all ports to the provided backend servers.
resource "azurerm_lb_rule" "lb-rules" {
  backend_port                   = 0
  frontend_ip_configuration_name = "${var.name_prefix}${var.sep}${var.name_lb_fip}"
  frontend_port                  = 0
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "${azurerm_lb.lb.name}${var.sep}${var.name_lb_rule}"
  protocol                       = "All"
  resource_group_name            = azurerm_resource_group.rg-lb.name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb-backend.id
  probe_id                       = azurerm_lb_probe.probe.id

}

# *********** Locals *********** #
locals {

  pip_map = { for i in flatten([for i in {
    for l in var.loadbalancer :
    l.name => [
      for fe in l.frontend_configuration :
      merge(fe.address, { "location" = l.location }, { "resource_group_name" = l.resource_group_name }, { "lb_name" = l.name })
      if lookup(fe.address, "type", null) == "public" ? true : false
    ]
    } : i
    ]) :
  i.name => i }

  lb = { for a in flatten([
    for l in values({
      for l in var.loadbalancer :
      l.name => {
        for b in l.backend_configuration :
        b.name => merge(b, { "lb_name" = l.name }, { "resource_group_name" = l.resource_group_name })
      }
    }) :
    [for x in l :
    x]
    ]) :
  a.name => a }

  probes = { for a in flatten([
    for l in values({
      for l in var.loadbalancer :
      l.name => {
        for b in l.probes :
        b.name => merge(
          b,
          { "lb_name" = l.name },
          { "resource_group_name" = l.resource_group_name }
        )
      }
    }) :
    [for x in l : x]
    ]) :
  a.name => a }

  rules = { for a in flatten([
    for l in values({
      for l in var.loadbalancer :
      l.name => {
        for b in l.rules :
        b.name => merge(
          b,
          { "lb_name" = l.name },
          { "resource_group_name" = l.resource_group_name }
        )
      }
    }) :
    [for x in l : x]
    ]) :
  a.name => a }
}


# *********** Create Public IP Address *********** #
resource "azurerm_public_ip" "azlb" {
  for_each            = local.pip_map
  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = each.value.allocation
  sku                 = var.lbsku
}


# *********** Create Load Balancer *********** #
resource "azurerm_lb" "azlb" {
  for_each = {
    for l in var.loadbalancer :
    l.name => l
  }

  name                = each.key
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  sku                 = var.lbsku

  dynamic "frontend_ip_configuration" {
    for_each = { for fe in each.value.frontend_configuration : fe.name => fe }
    content {
      name                          = frontend_ip_configuration.key
      public_ip_address_id          = lookup(frontend_ip_configuration.value.address, "type", null) == "public" ? azurerm_public_ip.azlb[frontend_ip_configuration.value.address.name].id : null
      subnet_id                     = lookup(frontend_ip_configuration.value.address, "type", null) == "private" ? frontend_ip_configuration.value.address.subnet_id : null
      private_ip_address_allocation = lookup(frontend_ip_configuration.value.address, "type", null) == "private" ? frontend_ip_configuration.value.address.allocation : null
      private_ip_address            = lookup(frontend_ip_configuration.value.address, "type", null) == "private" && lookup(frontend_ip_configuration.value.address, "ip_address", null) != null ? frontend_ip_configuration.value.address.ip_address : null
    }
  }
}


# *********** Create Load Balancer Backend Address Pool *********** #
resource "azurerm_lb_backend_address_pool" "lbback" {
  for_each            = local.lb
  name                = each.key
  resource_group_name = each.value.resource_group_name
  loadbalancer_id     = azurerm_lb.azlb[each.value.lb_name].id
}


# *********** Create Load Balancer Probe *********** #
resource "azurerm_lb_probe" "azlb" {
  for_each            = local.probes
  name                = "${each.value.lb_name}-${each.key}"
  resource_group_name = each.value.resource_group_name
  loadbalancer_id     = azurerm_lb.azlb[each.value.lb_name].id
  port                = each.value.port
  interval_in_seconds = each.value.interval
  number_of_probes    = each.value.number_of_probes
}


# *********** Create Load Balancer Rule *********** #
resource "azurerm_lb_rule" "azlb" {
  for_each                       = local.rules
  name                           = "${each.value.lb_name}-${each.key}"
  loadbalancer_id                = azurerm_lb.azlb[each.value.lb_name].id
  resource_group_name            = each.value.resource_group_name
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  protocol                       = each.value.protocol
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  enable_floating_ip             = each.value.enable_floating_ip
  load_distribution              = var.load_distribution
  idle_timeout_in_minutes        = var.idle_timeout
  depends_on                     = [azurerm_lb_probe.azlb]
  probe_id                       = azurerm_lb_probe.azlb[each.value.probe].id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lbback[each.value.backend_address_pool].id
}

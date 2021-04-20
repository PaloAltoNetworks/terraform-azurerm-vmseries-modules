resource "azurerm_public_ip" "this" {
  for_each = { for k, v in var.frontend_ips : k => v if try(v.create_public_ip, false) }

  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

data "azurerm_public_ip" "exists" {
  for_each = { for k, v in var.frontend_ips : k => v if try(v.public_ip_name, null) != null }

  name                = each.value.public_ip_name
  resource_group_name = try(each.value.public_ip_resource_group, var.resource_group_name)
}

resource "azurerm_lb" "lb" {
  name                = var.name_lb
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"

  dynamic "frontend_ip_configuration" {
    for_each = local.frontend_ips
    content {
      name                          = frontend_ip_configuration.value.name
      public_ip_address_id          = frontend_ip_configuration.value.public_ip_address_id
      subnet_id                     = frontend_ip_configuration.value.subnet_id
      private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address_allocation
      private_ip_address            = frontend_ip_configuration.value.private_ip_address_allocation == "Static" ? frontend_ip_configuration.value.private_ip_address : null
    }
  }
}

locals {
  # The main input will go here through a sequence of operations to obtain the final result.

  # Recalculate the main input map, taking into account whether the boolean condition is true/false.
  frontend_ips = { for k, v in var.frontend_ips : k => {
    name                          = try(v.create_public_ip, false) ? azurerm_public_ip.this[k].name : k
    public_ip_address_id          = try(v.create_public_ip, false) ? azurerm_public_ip.this[k].id : try(data.azurerm_public_ip.exists[k].id, null)
    create_public_ip              = try(v.create_public_ip, null)
    subnet_id                     = try(v.subnet_id, null)
    private_ip_address_allocation = try(v.private_ip_address_allocation, null)
    private_ip_address            = try(v.private_ip_address, null)
    rules                         = try(v.rules, {})
  } }

  # Terraform for_each unfortunately requires a single-dimensional map, but we have
  # a two-dimensional input. We need two steps for conversion.

  # Firstly, flatten() ensures that this local value is a flat list of objects, rather
  # than a list of lists of objects.
  input_flat_rules = flatten([
    for fipkey, fip in local.frontend_ips : [
      for rulekey, rule in fip.rules : {
        fipkey  = fipkey
        fip     = fip
        rulekey = rulekey
        rule    = rule
      }
    ]
  ])

  # Finally, convert flat list to a flat map. Make sure the keys are unique. This is used for for_each.
  input_rules = { for v in local.input_flat_rules : "${v.fipkey}-${v.rulekey}" => v }
}

resource "azurerm_lb_backend_address_pool" "lb_backend" {
  name                = coalesce(var.backend_name, var.name_lb)
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "probe" {
  name                = coalesce(var.name_probe, var.name_lb)
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb.id
  port                = var.probe_port
}

resource "azurerm_lb_rule" "lb_rules" {
  for_each = local.input_rules

  name                    = each.key
  resource_group_name     = var.resource_group_name
  loadbalancer_id         = azurerm_lb.lb.id
  probe_id                = azurerm_lb_probe.probe.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend.id

  protocol                       = each.value.rule.protocol
  backend_port                   = each.value.rule.port
  frontend_ip_configuration_name = each.value.fip.name
  frontend_port                  = each.value.rule.port
  enable_floating_ip             = true
}

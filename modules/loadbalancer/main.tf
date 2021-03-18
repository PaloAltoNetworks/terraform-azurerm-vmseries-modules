data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_public_ip" "this" {
  for_each = { for k, v in var.frontend_ips : k => v if try(v.create_public_ip, false) }

  name                = each.key
  location            = coalesce(var.location, data.azurerm_resource_group.this.location)
  resource_group_name = data.azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "standard"
}

resource "azurerm_lb" "lb" {
  name                = var.name_lb
  resource_group_name = data.azurerm_resource_group.this.name
  location            = coalesce(var.location, data.azurerm_resource_group.this.location)
  sku                 = "standard"

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
    public_ip_data                = try(v.public_ip_address_id, "false") != "false" ? regex("/subscriptions/[^/]*/resourceGroups/([^/]*)/providers/Microsoft\\.Network/publicIPAddresses/(.*)", v.public_ip_address_id) : null
    public_ip_address_id          = try(v.create_public_ip, false) ? azurerm_public_ip.this[k].id : lookup(v, "public_ip_address_id", null)
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

data "azurerm_public_ip" "provided" {
  for_each = { for k, v in local.frontend_ips : k => v if v.public_ip_data != null }

  name                = each.value.public_ip_data[1]
  resource_group_name = each.value.public_ip_data[0]
}

resource "azurerm_lb_backend_address_pool" "lb_backend" {
  for_each = local.input_rules

  loadbalancer_id = azurerm_lb.lb.id
  name            = each.value.rule.backend_name
}

resource "azurerm_lb_probe" "probe" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = coalesce(var.name_probe, var.name_lb)
  port                = var.probe_port
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_lb_rule" "lb_rules" {
  for_each = local.input_rules

  name                    = each.key
  resource_group_name     = data.azurerm_resource_group.this.name
  loadbalancer_id         = azurerm_lb.lb.id
  probe_id                = azurerm_lb_probe.probe.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend[each.key].id

  protocol                       = each.value.rule.protocol
  backend_port                   = each.value.rule.port
  frontend_ip_configuration_name = each.value.fip.name
  frontend_port                  = each.value.rule.port
  enable_floating_ip             = true
}

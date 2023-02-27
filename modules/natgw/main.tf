resource "azurerm_public_ip" "this" {
  count = (var.create_natgw && var.create_pip) ? 1 : 0

  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zone != null ? [var.zone] : null

  tags = var.tags
}

data "azurerm_public_ip" "this" {
  count = (var.create_natgw && !var.create_pip && var.existing_pip_name != null) ? 1 : 0

  name                = var.existing_pip_name
  resource_group_name = var.existing_pip_resource_group_name == null ? var.resource_group_name : var.existing_pip_resource_group_name
}

resource "azurerm_public_ip_prefix" "this" {
  count = (var.create_natgw && var.create_pip_prefix) ? 1 : 0

  name                = "${var.name}-pip-prefix"
  resource_group_name = var.resource_group_name
  location            = var.location
  ip_version          = "IPv4"
  prefix_length       = var.pip_prefix_length
  sku                 = "Standard"
  zones               = var.zone != null ? [var.zone] : null

  tags = var.tags
}

data "azurerm_public_ip_prefix" "this" {
  count = (var.create_natgw && !var.create_pip_prefix && var.existing_pip_prefix_name != null) ? 1 : 0

  name                = var.existing_pip_prefix_name
  resource_group_name = coalesce(var.existing_pip_prefix_resource_group_name, var.resource_group_name)
}

resource "azurerm_nat_gateway" "this" {
  count = var.create_natgw ? 1 : 0

  name                    = var.name
  resource_group_name     = var.resource_group_name
  location                = var.location
  sku_name                = "Standard"
  idle_timeout_in_minutes = var.idle_timeout
  zones                   = var.zone != null ? [var.zone] : null

  tags = var.tags
}

data "azurerm_nat_gateway" "this" {
  count = var.create_natgw ? 0 : 1

  name                = var.name
  resource_group_name = var.resource_group_name
}


locals {
  natgw_id = var.create_natgw ? azurerm_nat_gateway.this[0].id : data.azurerm_nat_gateway.this[0].id

  pip = var.create_natgw ? (
    var.create_pip ? azurerm_public_ip.this[0] : try(data.azurerm_public_ip.this[0], null)
  ) : null

  pip_prefix = var.create_natgw ? (
    var.create_pip_prefix ? azurerm_public_ip_prefix.this[0] : try(data.azurerm_public_ip_prefix.this[0], null)
  ) : null
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  count = var.create_natgw && local.pip != null ? 1 : 0

  nat_gateway_id       = local.natgw_id
  public_ip_address_id = local.pip.id
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "nat_ips" {
  count = var.create_natgw && local.pip_prefix != null ? 1 : 0

  nat_gateway_id      = local.natgw_id
  public_ip_prefix_id = local.pip_prefix.id
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  for_each = var.subnet_ids

  nat_gateway_id = local.natgw_id
  subnet_id      = each.value
}

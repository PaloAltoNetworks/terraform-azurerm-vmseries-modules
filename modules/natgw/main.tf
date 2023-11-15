# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
resource "azurerm_public_ip" "this" {
  count = try(var.create_natgw && var.public_ip.create, false) ? 1 : 0

  name                = var.public_ip.name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zone != null ? [var.zone] : null

  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip
data "azurerm_public_ip" "this" {
  count = try(var.create_natgw && !var.public_ip.create && var.public_ip.name != null, false) ? 1 : 0

  name                = var.public_ip.name
  resource_group_name = coalesce(var.public_ip.resource_group_name, var.resource_group_name)
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip_prefix
resource "azurerm_public_ip_prefix" "this" {
  count = try(var.create_natgw && var.public_ip_prefix.create, false) ? 1 : 0

  name                = var.public_ip_prefix.name
  resource_group_name = var.resource_group_name
  location            = var.location
  ip_version          = "IPv4"
  prefix_length       = var.public_ip_prefix.length
  sku                 = "Standard"
  zones               = var.zone != null ? [var.zone] : null

  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip_prefix
data "azurerm_public_ip_prefix" "this" {
  count = try(var.create_natgw && !var.public_ip_prefix.create && var.public_ip_prefix.name != null, false) ? 1 : 0

  name                = var.public_ip_prefix.name
  resource_group_name = coalesce(var.public_ip_prefix.resource_group_name, var.resource_group_name)
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway
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

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/nat_gateway
data "azurerm_nat_gateway" "this" {
  count = var.create_natgw ? 0 : 1

  name                = var.name
  resource_group_name = var.resource_group_name
}

locals {
  natgw_id = var.create_natgw ? azurerm_nat_gateway.this[0].id : data.azurerm_nat_gateway.this[0].id

  pip = try(azurerm_public_ip.this[0], data.azurerm_public_ip.this[0], null)

  pip_prefix = try(azurerm_public_ip_prefix.this[0], data.azurerm_public_ip_prefix.this[0], null)

  /*   pip = var.create_natgw ? (
    try(var.public_ip.create, false) ? azurerm_public_ip.this[0] : try(data.azurerm_public_ip.this[0], null)
  ) : null

  pip_prefix = var.create_natgw ? (
    try(var.public_ip_prefix.create, false) ? azurerm_public_ip_prefix.this[0] : try(data.azurerm_public_ip_prefix.this[0], null)
  ) : null */
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association
resource "azurerm_nat_gateway_public_ip_association" "this" {
  count = var.create_natgw && var.public_ip != null ? 1 : 0

  nat_gateway_id       = local.natgw_id
  public_ip_address_id = local.pip.id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_prefix_association
resource "azurerm_nat_gateway_public_ip_prefix_association" "nat_ips" {
  count = var.create_natgw && var.public_ip_prefix != null ? 1 : 0

  nat_gateway_id      = local.natgw_id
  public_ip_prefix_id = local.pip_prefix.id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association
resource "azurerm_subnet_nat_gateway_association" "this" {
  for_each = var.subnet_ids

  nat_gateway_id = local.natgw_id
  subnet_id      = each.value
}

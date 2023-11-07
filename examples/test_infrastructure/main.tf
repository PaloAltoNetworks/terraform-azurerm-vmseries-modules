# Generate a random password.
resource "random_password" "this" {
  count = var.password == null ? 1 : 0

  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "_%@"
}

locals {
  password = coalesce(var.password, try(random_password.this[0].result, null))
}

# Create or source the Resource Group.
resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = "${var.name_prefix}${var.resource_group_name}"
  location = var.location

  tags = var.tags
}

data "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

locals {
  resource_group = var.create_resource_group ? azurerm_resource_group.this[0] : data.azurerm_resource_group.this[0]
}

# Manage the network required for the topology.
module "vnet" {
  source = "../../modules/vnet"

  for_each = var.vnets

  name                   = each.value.create_virtual_network ? "${var.name_prefix}${each.value.name}" : each.value.name
  create_virtual_network = each.value.create_virtual_network
  resource_group_name    = coalesce(each.value.resource_group_name, local.resource_group.name)
  location               = var.location

  address_space = each.value.address_space

  create_subnets = each.value.create_subnets
  subnets        = each.value.subnets

  network_security_groups = { for k, v in each.value.network_security_groups : k => merge(v, { name = "${var.name_prefix}${v.name}" })
  }
  route_tables = { for k, v in each.value.route_tables : k => merge(v, { name = "${var.name_prefix}${v.name}" })
  }

  tags = var.tags
}

module "vnet_peering" {
  source   = "../../modules/vnet_peering"
  for_each = { for k, v in var.vnets : k => v if can(v.hub_vnet_name) }


  local_peer_config = {
    name                = "peer-${each.value.name}-to-${each.value.hub_vnet_name}"
    resource_group_name = local.resource_group.name
    vnet_name           = "${var.name_prefix}${each.value.name}"
  }
  remote_peer_config = {
    name                = "peer-${each.value.hub_vnet_name}-to-${each.value.name}"
    resource_group_name = try(each.value.hub_resource_group_name, local.resource_group.name)
    vnet_name           = each.value.hub_vnet_name
  }

  depends_on = [module.vnet]
}

# Create test VM running a web server
resource "azurerm_network_interface" "vm" {
  for_each = var.test_vms

  name                = "${var.name_prefix}${each.value.name}-nic"
  location            = var.location
  resource_group_name = local.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet[each.value.vnet_key].subnet_ids[each.value.subnet_key]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  for_each = var.test_vms

  # checkov:skip=CKV_AZURE_178:This is a test, non-production VM
  # checkov:skip=CKV_AZURE_149:This is a test, non-production VM

  name                            = "${var.name_prefix}${each.value.name}"
  resource_group_name             = local.resource_group.name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.username
  admin_password                  = local.password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.vm[each.key].id]
  allow_extension_operations      = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "bitnami"
    offer     = "wordpress"
    sku       = "4-4"
    version   = "latest"
  }
  plan {
    name      = "4-4"
    product   = "wordpress"
    publisher = "bitnami"
  }
}

# Create Bastion host for management

resource "azurerm_public_ip" "bastion" {
  for_each = var.bastions

  name                = "${var.name_prefix}${each.value.name}-nic"
  location            = var.location
  resource_group_name = local.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "this" {
  for_each = var.bastions

  name                = "${var.name_prefix}${each.value.name}"
  location            = var.location
  resource_group_name = local.resource_group.name

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = module.vnet[each.value.vnet_key].subnet_ids[each.value.subnet_key]
    public_ip_address_id = azurerm_public_ip.bastion[each.key].id
  }
}
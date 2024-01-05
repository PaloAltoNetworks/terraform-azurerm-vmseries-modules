resource "azurerm_public_ip" "this" {
  for_each = { for v in var.interfaces : v.name => v if v.create_public_ip }

  location            = var.location
  resource_group_name = var.resource_group_name
  name                = each.value.public_ip_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.virtual_machine.zone != null ? [var.virtual_machine.zone] : null
  tags                = var.tags
}

data "azurerm_public_ip" "this" {
  for_each = { for v in var.interfaces : v.name => v if !v.create_public_ip && v.public_ip_name != null
  }

  name                = each.value.public_ip_name
  resource_group_name = coalesce(each.value.public_ip_resource_group, var.resource_group_name)
}

resource "azurerm_network_interface" "this" {
  for_each = { for k, v in var.interfaces : v.name => merge(v, { index = k }) }

  name                          = each.value.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = each.value.index == 0 ? false : var.virtual_machine.accelerated_networking
  enable_ip_forwarding          = each.value.index == 0 ? false : true
  tags                          = var.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = each.value.private_ip_address != null ? "Static" : "Dynamic"
    private_ip_address            = each.value.private_ip_address
    public_ip_address_id          = try(azurerm_public_ip.this[each.value.name].id, data.azurerm_public_ip.this[each.value.name].id, null)
  }
}

locals {
  password = sensitive(var.authentication.password)
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  size                       = var.virtual_machine.size
  zone                       = var.virtual_machine.zone
  availability_set_id        = var.virtual_machine.avset_id
  encryption_at_host_enabled = var.virtual_machine.encryption_at_host_enabled

  network_interface_ids = [for v in var.interfaces : azurerm_network_interface.this[v.name].id]

  admin_username                  = var.authentication.username
  admin_password                  = var.authentication.disable_password_authentication ? null : local.password
  disable_password_authentication = var.authentication.disable_password_authentication

  dynamic "admin_ssh_key" {
    for_each = { for k, v in var.authentication.ssh_keys : k => v }
    content {
      username   = var.authentication.username
      public_key = admin_ssh_key.value
    }
  }

  os_disk {
    name                   = var.virtual_machine.disk_name
    storage_account_type   = var.virtual_machine.disk_type
    caching                = "ReadWrite"
    disk_encryption_set_id = var.virtual_machine.disk_encryption_set_id
  }

  source_image_id = var.image.custom_id

  dynamic "source_image_reference" {
    for_each = var.image.custom_id == null ? [1] : []
    content {
      publisher = var.image.publisher
      offer     = var.image.offer
      sku       = var.image.sku
      version   = var.image.version
    }
  }

  dynamic "plan" {
    for_each = var.image.enable_marketplace_plan ? [1] : []

    content {
      name      = var.image.sku
      publisher = var.image.publisher
      product   = var.image.offer
    }
  }

  custom_data = var.virtual_machine.bootstrap_options == null ? null : base64encode(var.virtual_machine.bootstrap_options)


  # After converting to azurerm_linux_virtual_machine, an empty block boot_diagnostics {} will use managed storage. Want.
  # 2.36 in required_providers per https://github.com/terraform-providers/terraform-provider-azurerm/pull/8917
  boot_diagnostics {
    storage_account_uri = var.virtual_machine.diagnostics_storage_uri
  }

  identity {
    type         = var.virtual_machine.identity_type
    identity_ids = var.virtual_machine.identity_ids
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "this" {
  for_each = { for v in var.interfaces : v.name => v.lb_backend_pool_id if v.lb_backend_pool_id != null }

  backend_address_pool_id = each.value
  ip_configuration_name   = azurerm_network_interface.this[each.key].ip_configuration[0].name
  network_interface_id    = azurerm_network_interface.this[each.key].id

  depends_on = [
    azurerm_network_interface.this,
    azurerm_linux_virtual_machine.this
  ]
}
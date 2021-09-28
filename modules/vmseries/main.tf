resource "azurerm_public_ip" "this" {
  for_each = { for k, v in var.interfaces : k => v if try(v.create_public_ip, false) }

  location            = var.location
  resource_group_name = var.resource_group_name
  name                = each.value.name
  allocation_method   = "Static"
  sku                 = "Standard"
  availability_zone = try(
    each.value.availability_zone,
    # For the default, first consider using avzone if only possible. Otherwise fall back to enable_zones.
    var.enable_zones && var.avzone != null && var.avzone != ""
    ?
    var.avzone
    :
    (var.enable_zones ? "Zone-Redundant" : "No-Zone")
  )
  tags = try(each.value.tags, var.tags)
}

resource "azurerm_network_interface" "this" {
  count = length(var.interfaces)

  name                          = var.interfaces[count.index].name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = count.index == 0 ? false : var.accelerated_networking # for interface 0 it is unsupported by PAN-OS
  enable_ip_forwarding          = true
  tags                          = try(var.interfaces[count.index].tags, var.tags)

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.interfaces[count.index].subnet_id
    private_ip_address_allocation = try(var.interfaces[count.index].private_ip_address, null) != null ? "static" : "dynamic"
    private_ip_address            = try(var.interfaces[count.index].private_ip_address, null)
    public_ip_address_id          = try(azurerm_public_ip.this[count.index].id, var.interfaces[count.index].public_ip_address_id, null)
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "this" {
  for_each = { for k, v in var.interfaces : k => v if try(v.enable_backend_pool, false) }

  backend_address_pool_id = each.value.lb_backend_pool_id
  ip_configuration_name   = azurerm_network_interface.this[each.key].ip_configuration[0].name
  network_interface_id    = azurerm_network_interface.this[each.key].id
}

resource "azurerm_virtual_machine" "this" {
  name                         = var.name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  tags                         = var.tags
  vm_size                      = var.vm_size
  zones                        = var.enable_zones && var.avzone != null && var.avzone != "" ? [var.avzone] : null
  availability_set_id          = var.avset_id
  primary_network_interface_id = azurerm_network_interface.this[0].id

  network_interface_ids = [for k, v in azurerm_network_interface.this : v.id]

  storage_image_reference {
    id        = var.custom_image_id
    publisher = var.custom_image_id == null ? var.img_publisher : null
    offer     = var.custom_image_id == null ? var.img_offer : null
    sku       = var.custom_image_id == null ? var.img_sku : null
    version   = var.custom_image_id == null ? var.img_version : null
  }

  dynamic "plan" {
    for_each = var.enable_plan ? ["one"] : []

    content {
      name      = var.img_sku
      publisher = var.img_publisher
      product   = var.img_offer
    }
  }

  storage_os_disk {
    create_option     = "FromImage"
    name              = coalesce(var.os_disk_name, "${var.name}-vhd")
    managed_disk_type = var.managed_disk_type
    os_type           = "Linux"
    caching           = "ReadWrite"
  }

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = var.name
    admin_username = var.username
    admin_password = var.password
    custom_data = var.bootstrap_share_name == null ? null : join(
      ",",
      [
        "storage-account=${var.bootstrap_storage_account.name}",
        "access-key=${var.bootstrap_storage_account.primary_access_key}",
        "file-share=${var.bootstrap_share_name}",
        "share-directory=None"
      ]
    )
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  # After converting to azurerm_linux_virtual_machine, an empty block boot_diagnostics {} will use managed storage. Want.
  # 2.36 in required_providers per https://github.com/terraform-providers/terraform-provider-azurerm/pull/8917
  dynamic "boot_diagnostics" {
    for_each = var.bootstrap_storage_account != null ? ["one"] : []

    content {
      enabled     = true
      storage_uri = var.bootstrap_storage_account.primary_blob_endpoint
    }
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }
}

resource "azurerm_application_insights" "this" {
  count = var.metrics_retention_in_days != 0 ? 1 : 0

  name                = coalesce(var.name_application_insights, var.name)
  location            = var.location
  resource_group_name = var.resource_group_name # same RG, so no RBAC modification is needed
  application_type    = "other"
  retention_in_days   = var.metrics_retention_in_days
  tags                = var.tags
}

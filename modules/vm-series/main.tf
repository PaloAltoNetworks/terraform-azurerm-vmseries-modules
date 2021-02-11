data "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_availability_set" "this" {
  name                        = coalesce(var.name_avset, "${var.name_prefix}avset")
  location                    = data.azurerm_resource_group.location
  resource_group_name         = data.azurerm_resource_group.name
  platform_fault_domain_count = 2
}

resource "azurerm_network_interface" "nic-fw-mgmt" {
  for_each = var.instances

  name                = "${var.name_prefix}${each.key}-nic-mgmt"
  location            = data.azurerm_resource_group.location
  resource_group_name = data.azurerm_resource_group.name

  ip_configuration {
    name                          = "${var.name_prefix}${each.key}-ip-mgmt"
    subnet_id                     = var.subnet-mgmt.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = try(each.value.mgmt_public_ip_address_id, null)
  }
}

resource "azurerm_network_interface" "nic-fw-private" {
  for_each = var.instances

  name                 = "${var.name_prefix}${each.key}-nic-private"
  location             = data.azurerm_resource_group.location
  resource_group_name  = data.azurerm_resource_group.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "${var.name_prefix}${each.key}-ip-private"
    subnet_id                     = var.subnet-private.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_interface" "nic-fw-public" {
  for_each = var.instances

  name                 = "${var.name_prefix}${each.key}-nic-public"
  location             = data.azurerm_resource_group.location
  resource_group_name  = data.azurerm_resource_group.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "${var.name_prefix}${each.key}-ip-public"
    subnet_id                     = var.subnet-public.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = try(each.value.nic1_public_ip_address_id, null)
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "this" {
  for_each = var.enable_backend_pool ? var.instances : {}

  backend_address_pool_id = var.lb_backend_pool_id
  ip_configuration_name   = azurerm_network_interface.nic-fw-public[each.key].ip_configuration[0].name
  network_interface_id    = azurerm_network_interface.nic-fw-public[each.key].id
}

resource "azurerm_virtual_machine" "this" {
  for_each = var.instances

  name                         = "${var.name_prefix}${each.key}"
  location                     = data.azurerm_resource_group.location
  resource_group_name          = data.azurerm_resource_group.name
  tags                         = var.tags
  vm_size                      = var.vm_size
  availability_set_id          = azurerm_availability_set.this.id
  primary_network_interface_id = azurerm_network_interface.nic-fw-mgmt[each.key].id

  network_interface_ids = [
    azurerm_network_interface.nic-fw-mgmt[each.key].id,
    azurerm_network_interface.nic-fw-public[each.key].id,
    azurerm_network_interface.nic-fw-private[each.key].id
  ]

  storage_image_reference {
    id        = var.custom_image_id
    publisher = var.custom_image_id == null ? var.vm_series_publisher : null
    offer     = var.custom_image_id == null ? var.vm_series_offer : null
    sku       = var.custom_image_id == null ? var.vm_series_sku : null
    version   = var.custom_image_id == null ? var.vm_series_version : null
  }

  dynamic "plan" {
    for_each = var.enable_plan ? ["one"] : []

    content {
      name      = var.vm_series_sku
      publisher = var.vm_series_publisher
      product   = var.vm_series_offer
    }
  }

  storage_os_disk {
    create_option     = "FromImage"
    name              = "${var.name_prefix}${each.key}-vhd"
    managed_disk_type = var.managed_disk_type
    os_type           = "Linux"
    caching           = "ReadWrite"
  }

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = "${var.name_prefix}${each.key}"
    admin_username = var.username
    admin_password = var.password
    custom_data = var.bootstrap-share-name == null ? null : join(
      ",",
      [
        "storage-account=${var.bootstrap-storage-account.name}",
        "access-key=${var.bootstrap-storage-account.primary_access_key}",
        "file-share=${var.bootstrap-share-name}",
        "share-directory=None"
      ]
    )
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  # After converting to azurerm_linux_virtual_machine, an empty block boot_diagnostics {} will use managed storage. Want.
  # 2.36 in required_providers per https://github.com/terraform-providers/terraform-provider-azurerm/pull/8917
  boot_diagnostics {
    enabled     = true
    storage_uri = var.bootstrap-storage-account.primary_blob_endpoint
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }
}

resource "azurerm_application_insights" "this" {
  count = var.metrics_retention_in_days != 0 ? 1 : 0

  name                = var.name_prefix
  location            = data.azurerm_resource_group.location
  resource_group_name = data.azurerm_resource_group.name # same RG, so no RBAC modification is needed
  application_type    = "other"
  retention_in_days   = var.metrics_retention_in_days
}

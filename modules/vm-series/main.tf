resource "azurerm_availability_set" "this" {
  name                        = coalesce(var.name_avset, "${var.name_prefix}-avset")
  location                    = var.resource_group.location
  resource_group_name         = var.resource_group.name
  platform_fault_domain_count = 2
}

# Create a public IP for management
resource "azurerm_public_ip" "pip-fw-mgmt" {
  for_each = var.instances

  name                = "${var.name_prefix}${each.key}-fw-pip"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  allocation_method   = "Static"
  sku                 = "standard"
}
# Create another PIP for the outside interface so we can talk outbound
resource "azurerm_public_ip" "pip-fw-public" {
  for_each = var.instances

  name                = "${var.name_prefix}${each.key}-pip-public"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  allocation_method   = "Static"
  sku                 = "standard"
}

resource "azurerm_network_interface" "nic-fw-mgmt" {
  for_each = var.instances

  name                = "${var.name_prefix}${each.key}-nic-mgmt"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  ip_configuration {
    name                          = "${var.name_prefix}${each.key}-ip-mgmt"
    subnet_id                     = var.subnet-mgmt.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-fw-mgmt[each.key].id
  }
}

resource "azurerm_network_interface" "nic-fw-private" {
  for_each = var.instances

  name                 = "${var.name_prefix}${each.key}-nic-private"
  location             = var.resource_group.location
  resource_group_name  = var.resource_group.name
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
  location             = var.resource_group.location
  resource_group_name  = var.resource_group.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "${var.name_prefix}${each.key}-ip-public"
    subnet_id                     = var.subnet-public.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-fw-public[each.key].id
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "this" {
  for_each = var.instances

  backend_address_pool_id = var.lb_backend_pool_id
  ip_configuration_name   = azurerm_network_interface.nic-fw-public[each.key].ip_configuration[0].name
  network_interface_id    = azurerm_network_interface.nic-fw-public[each.key].id
}

resource "azurerm_virtual_machine" "this" {
  for_each = var.instances

  name                         = "${var.name_prefix}${each.key}"
  location                     = var.resource_group.location
  resource_group_name          = var.resource_group.name
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

  plan {
    name      = var.vm_series_sku
    publisher = var.vm_series_publisher
    product   = var.vm_series_offer
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
    custom_data = join(
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
}

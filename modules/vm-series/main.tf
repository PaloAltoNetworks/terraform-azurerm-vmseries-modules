resource "azurerm_availability_set" "this" {
  name                        = coalesce(var.name_avset, "${var.name_prefix}avset")
  location                    = var.location
  resource_group_name         = var.resource_group_name
  platform_fault_domain_count = 2
}

resource "azurerm_network_interface" "mgmt" {
  for_each = var.instances

  name                          = "${var.name_prefix}${each.key}-mgmt"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = false # unsupported by PAN-OS

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_mgmt.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = try(each.value.mgmt_public_ip_address_id, null)
  }
}

locals {
  # Terraform for_each unfortunately requires a single-dimensional map, but we have
  # a two-dimensional inputs. We need two steps for conversion.

  # Firstly, flatten() ensures that this local value is a flat list of objects, rather
  # than a list of lists of objects.
  input_flat_subnets_data = flatten([
    for vmkey, vm in var.instances : [
      for subnetkey, subnet in var.subnets_data : {
        vmkey               = vmkey
        vm                  = vm
        subnetkey           = subnetkey
        subnet              = subnet
        lb_backend_pool_id  = var.lb_backend_pool_ids[subnetkey]
        enable_backend_pool = var.enable_backend_pools[subnetkey]
      }
    ]
  ])

  # Finally, convert flat list to a flat map. Make sure the keys are unique. This is used for for_each.
  input_subnets_data = { for v in local.input_flat_subnets_data : "${v.vmkey}-${v.subnetkey}" => v }
}

variable "lb_backend_pool_ids" { # FIXME move it 
}

variable "enable_backend_pools" { # FIXME move it 
}

resource "azurerm_network_interface" "data" {
  for_each = local.input_subnets_data

  name                          = "${var.name_prefix}${each.key}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.accelerated_networking
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = each.value.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = each.value.subnetkey == 0 ? try(each.value.vm.nic1_public_ip_address_id, null) : null
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "this" {
  for_each = { for k, v in local.input_subnets_data : k => v if v.enable_backend_pool }

  backend_address_pool_id = each.value.lb_backend_pool_id
  ip_configuration_name   = azurerm_network_interface.data[each.key].ip_configuration[0].name
  network_interface_id    = azurerm_network_interface.data[each.key].id
}

resource "azurerm_virtual_machine" "this" {
  for_each = var.instances

  name                         = "${var.name_prefix}${each.key}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  tags                         = var.tags
  vm_size                      = var.vm_size
  availability_set_id          = azurerm_availability_set.this.id
  primary_network_interface_id = azurerm_network_interface.mgmt[each.key].id

  network_interface_ids = concat(
    [azurerm_network_interface.mgmt[each.key].id],
    [for k, v in local.input_subnets_data : azurerm_network_interface.data[k].id if v.vmkey == each.key]
  )

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
  boot_diagnostics {
    enabled     = true
    storage_uri = var.bootstrap_storage_account.primary_blob_endpoint
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }
}

resource "azurerm_application_insights" "this" {
  count = var.metrics_retention_in_days != 0 ? 1 : 0

  name                = var.name_prefix
  location            = var.location
  resource_group_name = var.resource_group_name # same RG, so no RBAC modification is needed
  application_type    = "other"
  retention_in_days   = var.metrics_retention_in_days
}

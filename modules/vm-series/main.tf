/*
* networking terraform module
* ===========
* 
* A terraform module for deploying standalone (non-scale-set) VM series firewalls in Azure.
* 
* This module deploys a single VM-series
* 
* Usage
* -----
* 
* ```hcl
* module "vm-series" {
*   source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/vm-series"
*
*   location                      = "Australia Central"
*   name_prefix                   = "panostf"
*   password                      = "your-password"
*   subnet-mgmt                   = azurerm_subnet.subnet-mgmt
*   subnet-private                = azurerm_subnet.subnet-private
*   subnet-public                 = module.networks.subnet-public
*   bootstrap-storage-account     = module.panorama.bootstrap-storage-account
*   bootstrap-share-name          = "sharename"
*   vhd-container                 = "vhd-storage-container-name"
*   lb_backend_pool_id            = "private-backend-pool-id"
* }
* ```
*/
resource "azurerm_availability_set" "az" {
  location                    = var.location
  name                        = coalesce(var.name_avset, "${var.name_prefix}-avset")
  resource_group_name         = var.resource_group.name
  platform_fault_domain_count = 2
}

# Create a public IP for management
resource "azurerm_public_ip" "pip-fw-mgmt" {
  for_each = var.instances

  allocation_method   = "Static"
  location            = var.resource_group.location
  name                = "${var.name_prefix}${each.key}-fw-pip"
  sku                 = "standard"
  resource_group_name = var.resource_group.name
}
# Create another PIP for the outside interface so we can talk outbound
resource "azurerm_public_ip" "pip-fw-public" {
  for_each = var.instances

  allocation_method   = "Static"
  location            = var.resource_group.location
  name                = "${var.name_prefix}${each.key}-pip-public"
  sku                 = "standard"
  resource_group_name = var.resource_group.name
}

resource "azurerm_network_interface" "nic-fw-mgmt" {
  for_each = var.instances

  location            = var.resource_group.location
  name                = "${var.name_prefix}${each.key}-nic-mgmt"
  resource_group_name = var.resource_group.name
  ip_configuration {
    subnet_id                     = var.subnet-mgmt.id
    name                          = "${var.name_prefix}${each.key}-ip-mgmt"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-fw-mgmt[each.key].id
  }
}

resource "azurerm_network_interface" "nic-fw-private" {
  for_each = var.instances

  location            = var.resource_group.location
  name                = "${var.name_prefix}${each.key}-nic-private"
  resource_group_name = var.resource_group.name
  ip_configuration {
    subnet_id                     = var.subnet-private.id
    name                          = "${var.name_prefix}${each.key}-ip-private"
    private_ip_address_allocation = "dynamic"
  }
  enable_ip_forwarding = true
}

resource "azurerm_network_interface" "nic-fw-public" {
  for_each = var.instances

  location            = var.resource_group.location
  name                = "${var.name_prefix}${each.key}-nic-public"
  resource_group_name = var.resource_group.name
  ip_configuration {
    subnet_id                     = var.subnet-public.id
    name                          = "${var.name_prefix}${each.key}-ip-public"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-fw-public[each.key].id

  }
  enable_ip_forwarding = true

}

resource "azurerm_network_interface_backend_address_pool_association" "inbound-pool-assoc" {
  for_each = var.instances

  backend_address_pool_id = var.lb_backend_pool_id
  ip_configuration_name   = azurerm_network_interface.nic-fw-public[each.key].ip_configuration[0].name
  network_interface_id    = azurerm_network_interface.nic-fw-public[each.key].id
}

resource "azurerm_virtual_machine" "inbound-fw" {
  for_each = var.instances

  name                         = "${var.name_prefix}${each.key}"
  location                     = var.resource_group.location
  resource_group_name          = var.resource_group.name
  vm_size                      = var.vm_size
  availability_set_id          = azurerm_availability_set.az.id
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

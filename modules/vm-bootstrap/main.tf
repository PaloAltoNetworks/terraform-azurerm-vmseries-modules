/*
* vm-bootstrap terraform module
* ===========
* 
* A terraform module for creating the bootstrap storage account and dependencies required to bootstrap
* PANOS firewalls in Azure.
* 
* Does *not* configure the bootstrap images, licenses, or configurations.
* 
* Usage
* -----
* 
* ```hcl
* module "vm-bootstrap" {
*   source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/vm-bootstrap"
*
*   location        = "Australia Central"
*   name_prefix     = "panostf"
*   name_bootstrap_share = "bootstrap"
* }
* ```
* 
*/
# Base resource group
resource "azurerm_resource_group" "bootstrap" {
  location = var.location
  name     = "${var.name_prefix}${var.sep}${var.name_rg}"
}

# The storage account is used for the VM Series bootstrap
# Ref: https://docs.paloaltonetworks.com/vm-series/8-1/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-the-vm-series-firewall-in-azure.html#idd51f75b8-e579-44d6-a809-2fafcfe4b3b6
resource "azurerm_storage_account" "bootstrap-storage-account" {
  location                 = var.location
  name                     = "${var.name_prefix}${var.name_bootstrap_share}"
  account_replication_type = "LRS"
  account_tier             = "Standard"
  resource_group_name      = azurerm_resource_group.bootstrap.name
}

# Create rhe share to house the directories
### INBOUND ####
resource "azurerm_storage_share" "inbound-bootstrap-storage-share" {
  name                 = var.name_inbound_bootstrap_storage_share
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
  quota                = 50
}

resource "azurerm_storage_share_directory" "bootstrap-storage-directories" {
  for_each = toset([
    "content",
    "software",
  "license"])
  name                 = each.key
  share_name           = azurerm_storage_share.inbound-bootstrap-storage-share.name
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
}

resource "azurerm_storage_share_directory" "inbound-bootstrap-config-directory" {
  share_name           = azurerm_storage_share.inbound-bootstrap-storage-share.name
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
  name                 = "config"
}

#
#### OUTBOUND #####
#
resource "azurerm_storage_share" "outbound-bootstrap-storage-share" {
  name                 = var.name_outbound-bootstrap-storage-share
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
  quota                = 50
}

resource "azurerm_storage_share_directory" "outbound-bootstrap-storage-directories" {
  for_each = toset([
    "content",
    "software",
  "license"])
  name                 = each.key
  share_name           = azurerm_storage_share.outbound-bootstrap-storage-share.name
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
}

resource "azurerm_storage_share_directory" "outbound-bootstrap-config-directory" {
  share_name           = azurerm_storage_share.outbound-bootstrap-storage-share.name
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
  name                 = "config"
}

# Create a storage container for storing VM disks provisioned via VMSS
resource "azurerm_storage_container" "vm-sc" {
  name                 = "${var.name_prefix}${var.sep}${var.name_vm_sc}"
  storage_account_name = azurerm_storage_account.bootstrap-storage-account.name
}

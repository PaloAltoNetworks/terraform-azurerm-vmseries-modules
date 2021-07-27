variable "location" {
  description = "Region to install VM-Series and dependencies."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group where to place the resources created."
  type        = string
}

variable "name_prefix" {
  description = "A prefix for all the names of the created Azure objects. It can end with a dash `-` character, if your naming convention prefers such separator."
  type        = string
}

variable "vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported."
  default     = "Standard_D3_v2"
  type        = string
}

variable "subnet_mgmt" {
  description = "Management subnet."
  type        = object({ id = string })
}

variable "subnet_public" {
  description = "Public subnet (untrusted)."
  type        = object({ id = string })
}

variable "subnet_private" {
  description = "Private subnet (trusted)."
  type        = object({ id = string })
}

variable "bootstrap_storage_account" {
  description = "Storage account setup for bootstrapping"
  type = object({
    name               = string
    primary_access_key = string
  })
}

variable "bootstrap_share_name" {
  description = "File share for bootstrap config"
  type        = string
}

variable "username" {
  description = "Initial administrative username to use for VM-Series."
  default     = "panadmin"
  type        = string
}

variable "password" {
  description = "Initial administrative password to use for VM-Series."
  type        = string
}

variable "zones" {
  description = "The availability zones to use, for example `[\"1\", \"2\", \"3\"]`. If an empty list, no Availability Zones are used: `[]`."
  default     = ["1", "2"]
  type        = list(string)
}

variable "managed_disk_type" {
  description = "Type of Managed Disk which should be created. Possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`. The `Premium_LRS` works only for selected `vm_size` values, details in Azure docs."
  default     = "StandardSSD_LRS"
  type        = string
}

variable "custom_image_id" {
  description = "Absolute ID of your own Custom Image to be used for creating new VM-Series. If set, the `username`, `password`, `img_version`, `img_publisher`, `img_offer`, `img_sku` inputs are all ignored (these are used only for published images, not custom ones). The Custom Image is expected to contain PAN-OS software."
  default     = null
  type        = string
}

variable "enable_plan" {
  description = "Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku \"byol\", which means \"bring your own license\", still requires accepting on the Marketplace (as of 2021). Can be set to `false` when using a custom image."
  default     = true
  type        = bool
}

variable "img_publisher" {
  description = "The Azure Publisher identifier for a image which should be deployed."
  default     = "paloaltonetworks"
}

variable "img_offer" {
  description = "The Azure Offer identifier corresponding to a published image. For `img_version` 9.1.1 or above, use \"vmseries-flex\"; for 9.1.0 or below use \"vmseries1\"."
  default     = "vmseries-flex"
}

variable "img_sku" {
  description = "VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "bundle2"
  type        = string
}

variable "img_version" {
  description = "VM-Series PAN-OS version - list available for a default `img_offer` with `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all`"
  default     = "9.1.3"
  type        = string
}

variable "vm_count" {
  description = "Minimum instances per scale set."
  default     = 2
  type        = number
}

variable "vhd_container" {
  description = "Storage container for storing VMSS instance VHDs."
  type        = string
}

variable "private_backend_pool_id" {
  description = "Identifier of the load balancer backend pool to associate with the private interface of each VM-Series firewall."
  type        = string
  default     = null
}

variable "public_backend_pool_id" {
  description = "Identifier of the load balancer backend pool to associate with the public interface of each VM-Series firewall."
  type        = string
  default     = null
}

variable "enable_public_interface" {
  default = true
}

variable "accelerated_networking" {
  description = "If true, enable Azure accelerated networking (SR-IOV) for all dataplane network interfaces. [Requires](https://docs.paloaltonetworks.com/pan-os/9-0/pan-os-new-features/virtualization-features/support-for-azure-accelerated-networking-sriov) PAN-OS 9.0 or higher. The PAN-OS management interface (nic0) is never accelerated, whether this variable is true or false."
  default     = true
  type        = bool
}

variable "tags" {
  default = {}
}

#  ---   #
# Naming #
#  ---   #

variable "name_scale_set" {
  default = "inbound-scaleset"
}

variable "name_mgmt_nic_profile" {
  default = "inbound-nic-fw-mgmt-profile"
}

variable "name_mgmt_nic_ip" {
  default = "inbound-nic-fw-mgmt"
}

variable "name_fw_mgmt_pip" {
  default = "inbound-fw-mgmt-pip"
}

variable "name_domain_name_label" {
  default = "inbound-vm-mgmt"
}

variable "name_public_nic_profile" {
  default = "inbound-nic-fw-public-profile"
}

variable "name_public_nic_ip" {
  default = "inbound-nic-fw-public"
}

variable "name_private_nic_profile" {
  default = "inbound-nic-fw-private-profile"
}

variable "name_private_nic_ip" {
  default = "inbound-nic-fw-private"
}

variable "name_fw" {
  default = "inbound-fw"
}

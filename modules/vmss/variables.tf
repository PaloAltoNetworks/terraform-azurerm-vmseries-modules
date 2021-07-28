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

variable "create_mgmt_pip" {
  default = true
  type    = bool
}

variable "create_public_pip" {
  default = true
  type    = bool
}

variable "mgmt_pip_domain_name_label" {
  default = null
  type    = string
}

variable "public_pip_domain_name_label" {
  default = null
  type    = string
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

variable "disable_password_authentication" {
  description = "If true, disables password-based authentication on VM-Series instances."
  default     = false
  type        = bool
}

variable "encryption_at_host_enabled" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#encryption_at_host_enabled)."
  default     = null
  type        = bool
}

variable "health_probe_id" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)."
  default     = null
  type        = string
}

variable "overprovision" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)."
  default     = false
  type        = bool
}

variable "platform_fault_domain_count" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)."
  default     = null
  type        = number
}

variable "proximity_placement_group_id" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)."
  default     = null
  type        = string
}

variable "scale_in_policy" {
  description = "Which virtual machines are chosen for removal when a Virtual Machine Scale Set is scaled in. Either `Default`, `NewestVM` and `OldestVM`. See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)."
  default     = null
  type        = string
}

variable "single_placement_group" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)."
  default     = null
  type        = bool
}

variable "zone_balance" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)."
  default     = true
  type        = bool
}

variable "zones" {
  description = "The availability zones to use, for example `[\"1\", \"2\", \"3\"]`. If an empty list, no Availability Zones are used: `[]`."
  default     = ["1", "2", "3"]
  type        = list(string)
}

variable "storage_account_type" {
  description = "Type of Managed Disk which should be created. Possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`. The `Premium_LRS` works only for selected `vm_size` values, details in Azure docs."
  default     = "StandardSSD_LRS"
  type        = string
}

variable "boot_diagnostics_storage_account_uri" {
  default = null
  type    = string
}

variable "disk_encryption_set_id" {
  default = null
  type    = string
}

variable "use_custom_image" {
  description = "If true, use `custom_image_id` and ignore the inputs `username`, `password`, `img_version`, `img_publisher`, `img_offer`, `img_sku` (all these are used only for published images, not custom ones)."
  default     = false
  type        = bool
}

variable "custom_image_id" {
  description = "Absolute ID of your own Custom Image to be used for creating new VM-Series. The Custom Image is expected to contain PAN-OS software."
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

variable "create_public_interface" {
  description = "If true, create the third network interface for virtual machines."
  default     = true
  type        = bool
}

variable "accelerated_networking" {
  description = "If true, enable Azure accelerated networking (SR-IOV) for all dataplane network interfaces. [Requires](https://docs.paloaltonetworks.com/pan-os/9-0/pan-os-new-features/virtualization-features/support-for-azure-accelerated-networking-sriov) PAN-OS 9.0 or higher. The PAN-OS management interface (nic0) is never accelerated, whether this variable is true or false."
  default     = true
  type        = bool
}

variable "tags" {
  description = "Map of tags to use for all the created resources."
  default     = {}
  type        = map(string)
}

#  ---   #
# Naming #
#  ---   #

variable "name_scale_set" {
  default = "scaleset"
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

variable "name_fw_public_pip" {
  default = "inbound-fw-mgmt-pip"
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

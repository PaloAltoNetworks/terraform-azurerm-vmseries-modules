variable "location" {
  description = "Region to install vm-series and dependencies."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}

variable "instances" {
  description = "Map of instances to create. Keys are instance identifiers, values are objects with specific attributes."
}

variable "resource_group" {
  description = "The resource group for VM series. "
}

variable "subnet-mgmt" {
  description = "Management subnet."
}

variable "subnet-public" {
  description = "External/public subnet resource"
}

variable "subnet-private" {
  description = "internal/private subnet resource"
}

variable "bootstrap-storage-account" {
  description = "Storage account setup for bootstrapping"
}

variable "bootstrap-share-name" {
  description = "Azure File share for bootstrap config"
}

variable "password" {
  description = "VM-Series Password"
}

variable "username" {
  description = "VM-Series Username"
  default     = "panadmin"
}

variable "managed_disk_type" {
  description = "Type of Managed Disk which should be created. Possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`. The `Premium_LRS` works only for selected `vm_size` values, details in Azure docs."
  default     = "StandardSSD_LRS"
  type        = string
}

variable "vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported."
  default     = "Standard_D3_v2"
  type        = string
}

variable "custom_image_id" {
  description = "Absolute ID of your own Custom Image to be used for creating new VM-Series. If set, the `username`, `password`, `vm_series_version`, `vm_series_publisher`, `vm_series_offer`, `vm_series_sku` inputs are all ignored (these are used only for published images, not custom ones). The Custom Image is expected to contain PAN-OS software."
  default     = null
  type        = string
}

variable "vm_series_publisher" {
  description = "The Azure Publisher identifier for a image which should be deployed."
  default     = "paloaltonetworks"
}

variable "vm_series_offer" {
  description = "The Azure Offer identifier corresponding to a published image. For `vm_series_version` 9.1.1 or above, use \"vmseries-flex\"; for 9.1.0 or below use \"vmseries1\"."
  default     = "vmseries-flex"
}

variable "vm_series_sku" {
  description = "VM-series SKU - list available with az vm image list --publisher paloaltonetworks --all"
  default     = "bundle2"
}
variable "vm_series_version" {
  description = "VM-series Software version"
  default     = "9.0.4"
}

variable "lb_backend_pool_id" {
  description = "Identifier of the backend pool of the load balancer to associate with the VM-Series firewalls."
  default     = null
  type        = string
}

variable "name_avset" {
  default     = null
  description = "Name of the Availability Set to be created. Can be `null`, in which case a default name is auto-generated."
  type        = string
}

variable "tags" {
  description = "A map of tags to be associated with the resources created."
  default     = {}
  type        = "map"
}

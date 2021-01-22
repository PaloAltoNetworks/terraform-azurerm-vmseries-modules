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
  default     = "StandardSSD_LRS"
  description = "Type of Managed Disk which should be created. Possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`."
  type        = string
}

variable "vmseries_size" {
  description = "Default size for VM series"
  default     = "Standard_D5_v2"
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
  description = "ID Of inbound load balancer backend pool to associate with the VM series firewall"
}

#  ---   #
# Naming #
#  ---   #

# Seperator
variable "sep" {
  default = "-" # FIXME remove
}

variable "name_az" {
  default     = null
  description = "Name of the Availability Set to be created. Can be `null`, in which case a default name is auto-generated."
  type        = string
}

variable "name_fw" {
  default     = "ib-fw"
  description = "Name of the VM-Series Virtual Machine to be created. Can be `null`, in which case a default name is auto-generated."
  type        = string
}

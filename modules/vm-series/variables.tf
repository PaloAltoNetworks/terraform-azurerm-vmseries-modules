variable "location" {
  description = "Region to install vm-series and dependencies."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
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

variable "vm_count" {
  description = "Count of VM-series of each type (inbound/outbound) to deploy. Min 2 required for production."
  default     = 2
}


#  ---   #
# Naming #
#  ---   #

# Seperator
variable "sep" {
  default = "-"
}

variable "name_az" {
  default = "ib-vm-az"
}

variable "name_pip_fw_mgmt" {
  default = "ib-fw-pip"
}

variable "name_pip_fw_public" {
  default = "ib-pip-fw-public"
}

variable "name_nic_fw_mgmt" {
  default = "ib-nic-fw-mgmt"
}

variable "name_fw_ip_mgmt" {
  default = "ib-fw-ip-mgmt"
}

variable "name_nic_fw_private" {
  default = "ib-nic-fw-private"
}

variable "name_fw_ip_private" {
  default = "ib-fw-ip-private"
}

variable "name_nic_fw_public" {
  default = "ib-nic-fw-public"
}

variable "name_fw_ip_public" {
  default = "ib-fw-ip-public"
}

variable "name_inbound_fw" {
  default = "ib-fw"
}

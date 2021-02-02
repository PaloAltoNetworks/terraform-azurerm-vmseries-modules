variable "location" {
  description = "Region to install VM Series Scale sets and dependencies."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}

variable "vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported."
  default     = "Standard_D3_v2"
  type        = string
}

variable "subnet-mgmt" {
  description = "Management subnet."
}

variable "subnet-public" {
  description = "External/public subnet"
}

variable "subnet-private" {
  description = "internal/private subnet"
}

variable "bootstrap-storage-account" {
  description = "Storage account setup for bootstrapping"
}

variable "bootstrap-share-name" {
  description = "File share for bootstrap config"
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

variable "vm_series_sku" {
  description = "VM-series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "bundle2"
  type        = string
}

variable "vm_series_version" {
  description = "VM-series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "9.0.4"
  type        = string
}

variable "vm_count" {
  description = "Minimum instances per scale set."
  default     = 2
}

variable "vhd-container" {
  description = "Storage container for storing VMSS instance VHDs."
}

variable "lb_backend_pool_id" {
  description = "ID Of inbound load balancer backend pool to associate with the VM series firewall"
}

#  ---   #
# Naming #
#  ---   #

# Seperator
variable "sep" {
  default = "-"
}

variable "name_rg" {
  default = "vmseries-rg"
}

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

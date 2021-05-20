variable "location" {
  description = "Region to install VM-Series and dependencies."
  type        = string
}

variable "name_prefix" {
  description = "Prefix to add to all the created object names."
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

variable "img_sku" {
  description = "VM-series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "bundle2"
  type        = string
}

variable "img_version" {
  description = "VM-series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "9.0.4"
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

variable "lb_backend_pool_id" {
  description = "Identifier of the backend pool to associate with the VM series firewall."
  type        = string
}

variable "accelerated_networking" {
  description = "If true, enable Azure accelerated networking (SR-IOV) for all dataplane network interfaces. [Requires](https://docs.paloaltonetworks.com/pan-os/9-0/pan-os-new-features/virtualization-features/support-for-azure-accelerated-networking-sriov) PAN-OS 9.0 or higher. The PAN-OS management interface (nic0) is never accelerated, whether this variable is true or false."
  default     = true
  type        = bool
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
  default = "scale-set"
}

variable "name_mgmt_nic_profile" {
  default = "mgmt"
}

variable "name_mgmt_nic_ip" {
  default = "mgmt"
}

variable "name_fw_mgmt_pip" {
  default = "fw-mgmt-pip"
}

variable "name_domain_name_label" {
  default = "fw-mgmt"
}

variable "name_public_nic_profile" {
  default = "public"
}

variable "name_public_nic_ip" {
  default = "public"
}

variable "name_private_nic_profile" {
  default = "private"
}

variable "name_private_nic_ip" {
  default = "private"
}

variable "name_fw" {
  default = "fw"
}

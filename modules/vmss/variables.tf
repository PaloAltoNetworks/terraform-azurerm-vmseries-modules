variable "location" {
  description = "Region to install VM Series Scale sets and dependencies."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}

variable "vmseries_size" {
  description = "Default size for VM series"
  default     = "Standard_D5_v2"
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

variable "inbound-bootstrap-share-name" {
  description = "File share for bootstrap config"
}

variable "outbound-bootstrap-share-name" {
  description = "File share for bootstrap config"
}

variable "username" {
  description = "Username"
  default     = "panadmin"
}

variable "password" {
  description = "Password for VM Series firewalls"
}


variable "vm_series_sku" {
  description = "VM-series SKU - list available with az vm image list --publisher paloaltonetworks --all"
  default     = "bundle2"
}
variable "vm_series_version" {
  description = "VM-series Software version"
  default     = "9.0.4"
}

variable "vm_count" {
  description = "Minimum instances per scale set."
  default     = 2
}

variable "vhd-container" {
  description = "Storage container for storing VMSS instance VHDs."
}

variable "inbound_lb_backend_pool_id" {
  description = "ID Of inbound load balancer backend pool to associate with the VM series firewall"
}

variable "outbound_lb_backend_pool_id" {
  description = "ID Of outbound load balancer backend pool to associate with the VM series firewall"
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

variable "name_inbound_scale_set" {
  default = "inbound-scaleset"
}

variable "name_inbound_mgmt_nic_profile" {
  default = "inbound-nic-fw-mgmt-profile"
}

variable "name_inbound_mgmt_nic_ip" {
  default = "inbound-nic-fw-mgmt"
}

variable "name_inbound_fw_mgmt_pip" {
  default = "inbound-fw-mgmt-pip"
}

variable "name_inbound_domain_name_label" {
  default = "inbound-vm-mgmt"
}

variable "name_inbound_public_nic_profile" {
  default = "inbound-nic-fw-public-profile"
}

variable "name_inbound_public_nic_ip" {
  default = "inbound-nic-fw-public"
}

variable "name_inbound_private_nic_profile" {
  default = "inbound-nic-fw-private-profile"
}

variable "name_inbound_private_nic_ip" {
  default = "inbound-nic-fw-private"
}
variable "name_inbound_fw" {
  default = "inbound-fw"
}


variable "name_outbound_fw" {
  default = "outbound-fw"
}

variable "name_outbound_scale_set" {
  default = "outbound-scaleset"
}

variable "name_outbound_mgmt_nic_profile" {
  default = "outbound-nic-fw-mgmt-profile"
}

variable "name_outbound_mgmt_nic_ip" {
  default = "outbound-nic-fw-mgmt"
}

variable "name_outbound_fw_mgmt_pip" {
  default = "outbound-fw-mgmt-pip"
}

variable "name_outbound_fw_public_pip" {
  default = "outbound-fw-public-pip"
}

variable "name_outbound_domain_name_label" {
  default = "outbound-vm-mgmt"
}
variable "name_outbound_public_domain_name_label" {
  default = "outbound-vm-public"
}

variable "name_outbound_public_nic_profile" {
  default = "outbound-nic-fw-public-profile"
}

variable "name_outbound_public_nic_ip" {
  default = "outbound-nic-fw-public"
}

variable "name_outbound_private_nic_profile" {
  default = "outbound-nic-fw-private-profile"
}

variable "name_outbound_private_nic_ip" {
  default = "outbound-nic-fw-private"
}
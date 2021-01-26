variable "location" {
  description = "Region to deploy vm-series networking resources."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here."
}
variable "management_ips" {
  type        = map(any)
  description = "External IP addresses or prefixes that will be permitted direct access to the management network."
}
variable "management_vnet_prefix" {
  default     = "10.255."
  description = "The private prefix used for the management virtual network."
}

variable "management_subnet" {
  default     = "0.0/24"
  description = "The private network that terminates all FW and Panorama IP addresses - Joined with management_vnet_prefix."
}

variable "firewall_vnet_prefix" {
  default     = "10.110."
  description = "The private prefix used for all firewall networks."
}

variable "public_subnet" {
  default     = "129.0/24"
  description = "The private network that is the external or public side of the VM series firewalls (eth1/1)."
}

variable "private_subnet" {
  default     = "0.0/24"
  description = "The private network behind or on the internal/private side of the VM series firewalls (eth1/2)."
}

variable "vm_management_subnet" {
  default     = "255.0/24"
  description = "The subnet used for the management NICs on the vm-series."
}

variable "olb_private_ip" {
  # This IP MUST fall in the private-subnet network.
  description = "The private IP address to assign to the Outgoing Load balancer frontend. This IP MUST fall in the private-subnet network."
  default     = "10.110.0.21"
}


#  ---   #
# Naming #
#  ---   #

# Separator
variable "sep" {
  default = "-"
}

variable "name_vnet_panorama_mgmt" {
  default = "vnet-panorama-mgmt"
}

variable "name_rg" {
  default = "rg-networks-vmseries"
}

variable "name_vnet_vmseries" {
  default = "vnet-vmseries"
}

variable "name_subnet_mgmt" {
  default = "net-vmseries-mgmt"
}

variable "name_sg_mgmt" {
  default = "sg-vmmgmt"
}

variable "name_subnet_inside" {
  default = "net-inside"
}

variable "name_sg_allowall" {
  default = "sg-allowall"
}

variable "name_subnet_outside" {
  default = "net-outside"
}

variable "name_udr_inside" {
  default = "udr-inside"
}

variable "name_inter_vnet_rule" {
  default = "inter-vnet-rule"
}

variable "name_vmseries_allowall_outbound" {
  default = "vmseries-allowall-outbound"
}

variable "name_vmseries_mgmt_inbound" {
  default = "vmseries-mgmt-inbound"
}

variable "name_panorama_allowall_outbound" {
  default = "panorama-allowall-outbound"
}

variable "name_outside_allowall_inbound" {
  default = "outside-allowall-inbound"
}

variable "name_outside_allowall_outbound" {
  default = "outside-allowall-outbound"
}

variable "name_management_rules" {
  default = "mgmt-sgrule"
}

variable "name_vm_management_rules" {
  default = "vm-mgmt-sgrule"
}
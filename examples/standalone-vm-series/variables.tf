#----------------------#
#   Global Variables   #
#----------------------#
variable "location" {
  type        = string
  description = "The Azure region to use."
  default     = "Australia Central"
}
variable "name_prefix" {
  type        = string
  description = "A prefix for all naming conventions - used globally"
  default     = "pantf"
}

variable "username" {
  default     = "panadmin"
  description = "Username to use for all systems"
}

variable "password" {
  description = "Admin password to use for all systems"
}

#----------------------#
#      Networking      #
#----------------------#
variable "management_ips" {
  type        = map(any)
  description = "A list of IP addresses and/or subnets that are permitted to access the out of band Management network."
}

# Subnet definitions
#  All subnet defs are joined with their vnet prefix to form a full CIDR prefix
#  ex. for management, ${management_vnet_prefix}${management_subnet}
#  Thus to change the VNET addressing you only need to update the relevent _vnet_prefix variable.

variable "management_vnet_prefix" {
  default     = "10.255."
  description = "The private prefix used for the management virtual network"
}

variable "management_subnet" {
  default     = "0.0/24"
  description = "The private network that terminates all FW and Panorama IP addresses."
}

variable "firewall_vnet_prefix" {
  default     = "10.110."
  description = "The private prefix used for all firewall networks"
}

variable "vm_management_subnet" {
  default     = "255.0/24"
  description = "The subnet used for the management NICs on the vm-series"
}

variable "public_subnet" {
  default     = "129.0/24"
  description = "The private network that is the external or public side of the VM series firewalls (eth1/1)"
}

variable "private_subnet" {
  default     = "0.0/24"
  description = "The private network behind or on the internal side of the VM series firewalls (eth1/2)"
}

variable "olb_private_ip" {
  # !! This IP MUST fall in the private-subnet network. !!
  description = "The private IP address to assign to the Outgoing Load balancer frontend"
  default     = "10.110.0.21"
}
variable "rules" {
  description = "Inbound Load balancer rules. Largely used for testing the environment, these are mapped to PIPs and then the inbound LB."
  type = list(object({
    port = number
    name = string
  }))
  default = []
}

#----------------------#
#      VM Options      #
#----------------------#
# Total number of VM series per direction (inbound/outbound) to deploy
variable "vm_series_count" {
  default = 1
}

variable "panorama_sku" {
  default = "byol"
}
variable "panorama_version" {
  default = "9.0.5"
}

variable "vm_series_sku" {
  default = "bundle2"
}
variable "vm_series_version" {
  default = "9.0.4"
}

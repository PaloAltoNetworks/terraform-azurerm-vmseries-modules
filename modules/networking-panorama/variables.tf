variable "resource_group_name" {
  description = "Name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "Region to deploy Panorama Resources"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
  type        = string
}
variable "management_ips" {
  description = "External IP addresses or prefixes that will be permitted direct access to the management network."
  type        = map(any)
}

variable "management_vnet_prefix" {
  description = "The private prefix used for the management virtual network"
  default     = "10.255."
  type        = string
}

variable "management_subnet" {
  description = "The private network that terminates all FW and Panorama IP addresses - Joined with management_vnet_prefix"
  default     = "0.0/24"
  type        = string
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

variable "name_panorama_sg" {
  default = "sg-panorama-mgmt"
}

variable "name_panorama_subnet_mgmt" {
  default = "net-panorama-mgmt"
}

variable "name_panorama_allowall_outbound" {
  default = "panorama-allowall-outbound"
}

variable "name_management_rules" {
  default = "panorama-mgmt-sgrule"
}

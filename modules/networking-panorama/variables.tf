variable "location" {
  description = "Region to deploy Panorama Resources"
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}
variable "management_ips" {
  type        = map(any)
  description = "External IP addresses or prefixes that will be permitted direct access to the management network."
}
variable "management_vnet_prefix" {
  default     = "10.255."
  description = "The private prefix used for the management virtual network"
}

variable "management_subnet" {
  default     = "0.0/24"
  description = "The private network that terminates all FW and Panorama IP addresses - Joined with management_vnet_prefix"
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
  default = "rg-panorama-networks"
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

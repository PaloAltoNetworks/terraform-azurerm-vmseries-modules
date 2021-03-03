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

variable "resource_group_name" {
  type        = string
  description = "The resource group name for Panorama."
}

#----------------------#
#      Networking      #
#----------------------#
variable "management_ips" {
  description = "A map where the keys are the IP addresses or ranges that are permitted to access the out-of-band management interfaces belonging to firewalls and Panorama devices. The map's values are priorities, integers in the range 102-60000 inclusive. All priorities should be unique."
  type        = map(number)
}

##########
# Naming #
##########

variable "sep" {
  default     = "-"
  description = "Separator used in the names of the generated resources. May be empty."
}

variable "panorama_name" {
  type    = string
  default = "panorama"
}

variable "panorama_size" {
  type    = string
  default = "Standard_D5_v2"
}

variable "custom_image_id" {
  type    = string
  default = null
}

variable "username" {
  type    = string
  default = "panadmin"
}

variable "panorama_sku" {
  type    = string
  default = "byol"
}

variable "panorama_version" {
  type    = string
  default = "10.0.3"
}

variable "subnet_names" {
  type    = list
  default = ["subnet1", "subnet2"]
}

variable "subnet_prefixes" {
  type    = list
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "vnet_name" {
  type = string
}

variable "address_space" {
  type    = list
  default = ["10.0.0.0/16"]
}

variable "tags" {
  type = map(any)
}

variable "firewall_mgmt_prefixes" {
  type    = list
  default = ["10.0.1.0/24"]
}

variable "security_group_name" {
  type    = string
  default = "nsg-panorama"
}

variable "avzone" {
  type    = string
  default = null
}

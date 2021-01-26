variable "existing_rg" {
  description = "Enable this option if you have already created Resource Group."
  type        = bool
  default     = false
}

variable "existing_vnet" {
  description = "Enable this option if you have already created Virtual Network."
  type        = bool
  default     = false
}

variable "location" {
  description = "Location of the resources that will be deployed."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group to create."
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the Virtual Network to create."
  type        = string
}

variable "address_space" {
  description = "Address space for VNet."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Definition of subnets to create."
}

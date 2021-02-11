variable "resource_group_name" {
  description = "Name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "Region to deploy panorama into."
  type        = string
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here."
  type        = string
}

variable "panorama_size" {
  description = "Virtual Machine size."
  default     = "Standard_D5_v2"
  type        = string
}

variable "subnet_mgmt" {
  description = "Panorama's management subnet ID."
}

variable "username" {
  description = "Initial administrative username to use for Panorama."
  default     = "panadmin"
  type        = string
}

variable "password" {
  description = "Initial administrative password to use for Panorama."
  type        = string
}

variable "panorama_sku" {
  description = "Panorama SKU."
  default     = "byol"
  type        = string
}

variable "panorama_version" {
  description = "Panorama PAN-OS Software version. List published images with `az vm image list -o table --all --publisher paloaltonetworks --offer panorama`"
  default     = "10.0.3"
  type        = string
}



#  ---   #
# Naming #
#  ---   #

variable "sep" {
  default     = "-"
  description = "Separator used in the names of the generated resources. May be empty."
}

variable "name_panorama_pip_mgmt" {
  default = "panorama-pip"
}

variable "name_mgmt" {
  default = "nic-mgmt"
}

variable "name_panorama" {
  default = "panorama"
}

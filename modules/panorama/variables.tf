variable "location" {
  description = "Region to install vm-series and dependencies."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}

variable "panorama_size" {
  description = "Default size for Panorama"
  default     = "Standard_D5_v2"
}

variable "subnet_mgmt" {
  description = "Management subnet."
}

variable "username" {
  description = "Panorama Username"
  default     = "panadmin"
}

variable "password" {
  description = "Panorama Password"
}

variable "panorama_sku" {
  default     = "byol"
  description = "Panorama SKU - list available with az vm image list --publisher paloaltonetworks --all"
}
variable "panorama_version" {
  default     = "9.0.5"
  description = "Panorama Software version"
}


#  ---   #
# Naming #
#  ---   #

# Seperator
variable "sep" {
  default = "-"
}

variable "name_rg" {
  default = "rg-panorama"
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
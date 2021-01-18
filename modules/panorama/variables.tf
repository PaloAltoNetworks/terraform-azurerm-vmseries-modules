variable "location" {
  description = "Region to deploy panorama into."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here."
}

variable "panorama_size" {
  description = "Virtual Machine size."
  default     = "Standard_D5_v2"
}

variable "subnet_mgmt" {
  description = "Panorama's management subnet ID."
}

variable "username" {
  description = "Panorama Username."
  default     = "panadmin"
}

variable "password" {
  description = "Panorama Password."
}

variable "panorama_sku" {
  default     = "byol"
  description = "Panorama SKU."
}

variable "panorama_version" {
  default     = "10.0.3"
  description = "PAN-OS Software version. List published images with `az vm image list --publisher paloaltonetworks --offer panorama --all`"
}


#  ---   #
# Naming #
#  ---   #

variable "sep" {
  default     = "-"
  description = "Separator used in the names of the generated resources. May be empty."
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

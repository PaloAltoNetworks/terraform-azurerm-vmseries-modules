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

variable "enable_logging_disk" {
  description = "Enable / Disable attaching a managed disk for Panorama logging"
  type        = bool
  default     = false
}

variable "logging_disk_size" {
  description = "Panorama logging disk size in GB"
  type        = string
  default     = "2000"
}

variable "logical_unit_number" {
  description = "The Logical Unit Number of the Data Disk, which needs to be unique within the Virtual Machine. Changing this forces a new resource to be created."
  type        = string
  default     = "10"
}

variable "panorama_ha" {
  description = "Enable Panorama HA. Creates two Panorama virtual machines instead of one. Requires `location` to be one of the Azure regions that support Availability Zones."
  type        = bool
  default     = false
}

variable "panorama_ha_suffix_map" {
  type    = list(string)
  default = ["a", "b"]
}

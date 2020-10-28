variable "location" {
  description = "Region to deploy vm-series bootstrap resources."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}

variable "bootstrap_key_lifetime" {
  description = "Default key lifetime for bootstrap."
  default     = "8760"
}

#  ---   #
# Naming #
#  ---   #

# Seperator
variable "sep" {
  default = "-"
}

variable "name_rg" {
  default = "rg-bootstrap"
}

variable "name_bootstrap_share" {
  default = "bootstrap"
}

variable "name_inbound_bootstrap_storage_share" {
  default = "ibbootstrapshare"
}

variable "name_outbound-bootstrap-storage-share" {
  default = "obbootstrapshare"
}
variable "name_vm_sc" {
  default = "vm-container"
}
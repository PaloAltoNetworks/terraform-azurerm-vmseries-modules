variable "location" {
  description = "Region to deploy load balancer and dependencies."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}

#  ---   #
# Naming #
#  ---   #

# Seperator
variable "sep" {
  default = "-"
}

variable "name_rg" {
  default = "lb-rg"
}

variable "name_lb" {
  default = "lb"
}

variable "name_backend" {
  default = "lb-backend"
}

variable "name_probe" {
  default = "lb-probe"
}

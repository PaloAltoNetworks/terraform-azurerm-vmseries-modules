variable "location" {
  description = "Region to install vm-series and dependencies."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}

variable "rules" {
  description = "A list[objects] of ports and names that will be assigned to inbound LB rules. Useful for testing."
  type = list(object({
    port = number
    name = string
    protocol = string
  }))
  default = [{
    port = 80
    name = "default-rule"
    protocol = "Tcp"
  }]
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

variable "name_lbrule" {
  default = "lbrule"
}
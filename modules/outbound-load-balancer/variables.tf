variable "location" {
  description = "Region to install vm-series and dependencies."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
}

variable "private-ip" {
  description = "Private IP address to assign to the frontend of the loadbalancer"
}


variable "backend-subnet" {
  description = "Subnet to provision the load balancer in, must be the same as the private/internal subnet of VM-series."
}

#  ---   #
# Naming #
#  ---   #

# Separator
variable "sep" {
  default = "-"
}

variable "name_rg" {
  default = "olb-rg"
}

variable "name_lb" {
  default = "olb"
}

variable "name_lb_backend" {
  default = "olb-backend"
}

variable "name_probe" {
  default = "olb-probe-80"
}

variable "name_lb_rule" {
  default = "lbrule-outbound"
}

variable "name_lb_fip" {
  default = "olb-fib"
}
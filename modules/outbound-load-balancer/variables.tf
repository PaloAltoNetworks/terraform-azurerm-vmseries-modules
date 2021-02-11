variable "resource_group_name" {
  description = "Name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "Region to deploy all load balancer resources."
  type        = string
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here"
  type        = string
}

variable "private-ip" {
  description = "Private IP address to assign to the frontend of the loadbalancer"
  default     = "10.110.0.21"
  type        = string
}


variable "backend-subnet" {
  description = "ID of Subnet to provision the load balancer in, must be the same as the private/internal subnet of VM-series."
}

#  ---   #
# Naming #
#  ---   #

# Separator
variable "sep" {
  default = "-"
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
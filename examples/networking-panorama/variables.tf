#----------------------#
#   Global Variables   #
#----------------------#
variable "location" {
  type        = string
  description = "The Azure region to use."
  default     = "Australia Central"
}
variable "name_prefix" {
  type        = string
  description = "A prefix for all naming conventions - used globally"
  default     = "pantf"
}

#----------------------#
#      Networking      #
#----------------------#
variable "management_ips" {
  type        = map(any)
  description = "A list of IP addresses and/or subnets that are permitted to access the out of band Management network."
}
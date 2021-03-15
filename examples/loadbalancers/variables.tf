variable "resource_group_name" {
  description = "Name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "Region to deploy load balancer and dependencies."
  default     = ""
  type        = "string"
}

variable "name_lb" {
  description = "The loadbalancer name."
  type        = string
}

variable "name_probe" {
  description = "The loadbalancer probe name."
  type        = string
}

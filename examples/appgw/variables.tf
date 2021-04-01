variable "resource_group_name" {
  description = "Name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "Region to deploy load balancer and dependencies."
  default     = ""
  type        = string
}

variable "appgw_name" {
  description = "The application gateway name."
  type        = string
}

variable "appgw_subnet_id" {
  description = "The loadbalancer probe name."
  type        = string
  default     = null
}

variable "fw_private_ips" {
  description = "The private IP addresses list from deployed FW."
  type = list(string)
  default = null
}

variable "frontend_port_name" {
  type = string
  description = "The frontend port name."
  default = "frontend_http"
}

variable "frontend_ip_configuration_name" {
  type = string
  description = "The frontend ip configuration name."
  default = "frontend_ip_config_name"
}

variable "listener_name" {
  description = "The application gateway listener name."
  type        = string
  default     = "http_listener"
}

variable "backend_address_pool_name" {
  type = string
  description = "The backend address pool name."
  default = "backend_http"
}

variable "http_setting_name" {
  type = string
  description = "The http setting name."
  default = "http"
}

variable "request_routing_rule_name" {
  type = string
  description = "The routing rule name."
  default = "http_rule"
}

variable "tags" {
  type = map(any)
  description = "The tag definition for application gateway."
  default = {}
}

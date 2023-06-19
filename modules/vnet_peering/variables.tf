variable "local_resource_group_name" {
  description = "Name of the existing local peer resource group where to place the resources created."
  type        = string
}

variable "peer_resource_group_name" {
  description = "Name of the existing remote peer resource group where to place the resources created."
  type        = string
}

variable "name_prefix" {
  description = "Prefix name appended to the peering names."
  default     = ""
  type        = string
}

variable "local_vnet_name" {
  description = "Local VNET name."
  default     = ""
  type        = string
}

variable "peer_vnet_name" {
  description = "Peer VNET name."
  default     = ""
  type        = string
}

variable "local_allow_virtual_network_access" {
  description = "Local peer setting for allowing traffic from peer VNET to VMs in the local VNET."
  default     = true
  type        = bool
}

variable "local_allow_forwarded_traffic" {
  description = "Local peer setting for forwarded traffic from VMs in the peer VNET."
  default     = true
  type        = bool
}

variable "local_allow_gateway_transit" {
  description = "Local peer setting for allowing gateway links for remote gateway or Route Server in the peer VNET."
  default     = false
  type        = bool
}

variable "local_use_remote_gateways" {
  description = "Local peer setting for using peer VNET remote gateway or Route Server."
  default     = false
  type        = bool
}

variable "peer_allow_virtual_network_access" {
  description = "Remote peer setting for allowing traffic from local VNET to VMs in the peer VNET."
  default     = true
  type        = bool
}

variable "peer_allow_forwarded_traffic" {
  description = "Remote peer setting for forwarded traffic from VMs in the local VNET."
  default     = true
  type        = bool
}

variable "peer_allow_gateway_transit" {
  description = "Remote peer setting for allowing gateway links for remote gateway or Route Server in the local VNET."
  default     = false
  type        = bool
}

variable "peer_use_remote_gateways" {
  description = "Remote peer setting for using local VNET remote gateway or Route Server."
  default     = false
  type        = bool
}
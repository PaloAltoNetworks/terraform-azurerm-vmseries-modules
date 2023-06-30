variable "name_prefix" {
  description = "Prefix name appended to the peering names."
  default     = ""
  type        = string
}

variable "local_peer_config" {
  description = <<-EOF
  A map that contains the local peer configuration.
  Mandatory Values are : 
  - `vnet_name`                   (string) : the local peer VNET name.
  - `resource_group_name          (string) : the resource group name of the local peer
  - `allow_virtual_network_access (bool)   : allows communication between the two peering VNETs
  - `allow_forwarded_traffic`     (bool)   : allows traffic forwarded from the peer VNET but not originated from within it
  - `allow_gateway_transit`       (bool)   : controls the learning of routes from local VNET (gateway or route server) into the remote VNET. Must be true if `use_remote_gateways` is `true` for remote peer
  - `use_remote_gateways`         (bool)   : controls the learning of routes from the remote VNET (gateway or route server) into the local VNET

  Optional values:
  - `name`                        (string) : the name of the local VNET peering
  EOF
  type = object({
    vnet_name                    = string
    resource_group_name          = string
    name                         = optional(string)
    allow_virtual_network_access = bool
    allow_forwarded_traffic      = bool
    allow_gateway_transit        = bool
    use_remote_gateways          = bool
  })
}

variable "remote_peer_config" {
  description = <<-EOF
  A map that contains the remote peer configuration.
  Mandatory Values are : 
  - `vnet_name`                   (string) : the remote peer VNET name.
  - `resource_group_name          (string) : the resource group name of the remote peer
  - `allow_virtual_network_access (bool)   : allows communication between the two peering VNETs
  - `allow_forwarded_traffic`     (bool)   : allows traffic forwarded from the local VNET but not originated from within it
  - `allow_gateway_transit`       (bool)   : controls the learning of routes from remote VNET (gateway or route server) into the local VNET. Must be true if `use_remote_gateways` is `true` for local peer
  - `use_remote_gateways`         (bool)   : controls the learning of routes from the local VNET (gateway or route server) into the remote VNET

  Optional values:
  - `name`                        (string) : the name of the remote VNET peering
  EOF
  type = object({
    vnet_name                    = string
    resource_group_name          = string
    name                         = optional(string)
    allow_virtual_network_access = bool
    allow_forwarded_traffic      = bool
    allow_gateway_transit        = bool
    use_remote_gateways          = bool
  })
}
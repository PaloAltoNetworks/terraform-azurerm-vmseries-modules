variable "local_peer_config" {
  description = <<-EOF
  A map that contains the local peer configuration.
  Mandatory Values: 
  - `name`                         - (`string`, required) the name of the local VNET peering.
  - `resource_group_name`          - (`string`, required) the resource group name of the local peer.
  - `vnet_name`                    - (`string`, required) the local peer VNET name.
  - `allow_virtual_network_access` - (`bool`, optional, defaults to `true`) allows communication between the two peering VNETs.
  - `allow_forwarded_traffic`      - (`bool`, optional, defaults to `true`) allows traffic forwarded from the remote VNET but not
                                     originated from within it.
  - `allow_gateway_transit`        - (`bool`, optional, defaults to `false`) controls the learning of routes from local VNET
                                     (gateway or route server) into the remote VNET. Must be true if `use_remote_gateways` is
                                     `true` for remote peer.
  - `use_remote_gateways`          - (`bool`, optional, defaults to `false`) controls the learning of routes from the remote VNET
                                     (gateway or route server) into the local VNET.
  EOF
  type = object({
    name                         = string
    resource_group_name          = string
    vnet_name                    = string
    allow_virtual_network_access = optional(bool, true)
    allow_forwarded_traffic      = optional(bool, true)
    allow_gateway_transit        = optional(bool, false)
    use_remote_gateways          = optional(bool, false)
  })
}

variable "remote_peer_config" {
  description = <<-EOF
  A map that contains the remote peer configuration.
  Mandatory Values: 
  - `name`                         - (`string`, required) the name of the remote VNET peering.
  - `resource_group_name`          - (`string`, required) the resource group name of the remote peer.
  - `vnet_name`                    - (`string`, required) the remote peer VNET name.
  - `allow_virtual_network_access` - (`bool`, optional, defaults to `true`) allows communication between the two peering VNETs.
  - `allow_forwarded_traffic`      - (`bool`, optional, defaults to `true`) allows traffic forwarded from the local VNET but not
                                    originated from within it.
  - `allow_gateway_transit`        - (`bool`, optional, defaults to `false`) controls the learning of routes from remote VNET
                                     (gateway or route server) into the local VNET. Must be true if `use_remote_gateways` is
                                    `true` for remote peer.
  - `use_remote_gateways`          - (`bool`, optional, defaults to `false`) controls the learning of routes from the local VNET
                                     (gateway or route server) into the remote VNET.
  EOF
  type = object({
    name                         = string
    resource_group_name          = string
    vnet_name                    = string
    allow_virtual_network_access = optional(bool, true)
    allow_forwarded_traffic      = optional(bool, true)
    allow_gateway_transit        = optional(bool, false)
    use_remote_gateways          = optional(bool, false)
  })
}
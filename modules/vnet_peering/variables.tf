variable "name_prefix" {
  description = "Prefix name appended to the peering names."
  default     = ""
  type        = string
}

variable "local_peer_config" {
  description = <<-EOF
  A map that contains the local peer configuration.
  Mandatory Values: 
  - `vnet_name`                   - (`string`, required) the local peer VNET name.
  - `resource_group_name          - (`string`, required) : the resource group name of the local peer
  - `allow_virtual_network_access - (`bool`, optional, defaults to `true`) : allows communication between the two peering VNETs
  - `allow_forwarded_traffic`     - (`bool`, optional, defaults to `true`) : allows traffic forwarded from the remote VNET but not originated from within it
  - `allow_gateway_transit`       - (`bool`, optional, defaults to `false`) : controls the learning of routes from local VNET (gateway or route server) into the remote VNET. Must be true if `use_remote_gateways` is `true` for remote peer
  - `use_remote_gateways`         - (`bool`, optional, defaults to `false`) : controls the learning of routes from the remote VNET (gateway or route server) into the local VNET
  - `name`                        - (`string`, optional, defaults to `<var.name_prefix><var.local_peer_config.vnet_name>-to-<var.remote_peer_config.vnet_name>`) : the name of the local VNET peering
  EOF
  type        = map(any)
}

variable "remote_peer_config" {
  description = <<-EOF
  A map that contains the remote peer configuration.
  Mandatory Values :
  - `vnet_name`                   - (`string`, required) : the remote peer VNET name.
  - `resource_group_name          - (`string`, required) : the resource group name of the remote peer
  - `allow_virtual_network_access - (`bool`, optional, defaults to `true`) : allows communication between the two peering VNETs
  - `allow_forwarded_traffic`     - (`bool`, optional, defaults to `true`) : allows traffic forwarded from the local VNET but not originated from within it
  - `allow_gateway_transit`       - (`bool`, optional, defaults to `false`) : controls the learning of routes from remote VNET (gateway or route server) into the local VNET. Must be true if `use_remote_gateways` is `true` for local peer
  - `use_remote_gateways`         - (`bool`, optional, defaults to `false`) : controls the learning of routes from the local VNET (gateway or route server) into the remote VNET
  - `name`                        - (`string`, optional, defaults to `<var.name_prefix><var.remote_peer_config.vnet_name>-to-<var.local_peer_config.vnet_name>`) : the name of the local VNET peering
  EOF
  type        = map(any)
}
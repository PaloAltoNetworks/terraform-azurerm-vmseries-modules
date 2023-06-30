variable "name_prefix" {
  description = "Prefix name appended to the peering names."
  default     = ""
  type        = string
}

variable "local_peer_config" {
  description = <<-EOF
  A map that contains the local peer configuration.
  Mandatory Values: 
  - `vnet_name` (`string`) : the local peer VNET name.
  - `resource_group_name (`string`) : the resource group name of the local peer
  - `allow_virtual_network_access (`bool`) : allows communication between the two peering VNETs
  - `allow_forwarded_traffic` (`bool`) : allows traffic forwarded from the remote VNET but not originated from within it
  - `allow_gateway_transit` (`bool`) : controls the learning of routes from local VNET (gateway or route server) into the remote VNET. Must be true if `use_remote_gateways` is `true` for remote peer
  - `use_remote_gateways` (`bool`) : controls the learning of routes from the remote VNET (gateway or route server) into the local VNET

  <details>
  <summary>Optional</summary>
  - `name` (string) : the name of the local VNET peering
  </details>

  EOF
  type        = map(any)
}

variable "remote_peer_config" {
  description = <<-EOF
  A map that contains the remote peer configuration.
  Mandatory Values : 
  - `vnet_name` (`string`) : the remote peer VNET name.
  - `resource_group_name (`string`) : the resource group name of the remote peer
  - `allow_virtual_network_access (`bool`) : allows communication between the two peering VNETs
  - `allow_forwarded_traffic` (`bool`) : allows traffic forwarded from the local VNET but not originated from within it
  - `allow_gateway_transit` (`bool`) : controls the learning of routes from remote VNET (gateway or route server) into the local VNET. Must be true if `use_remote_gateways` is `true` for local peer
  - `use_remote_gateways` (`bool`) : controls the learning of routes from the local VNET (gateway or route server) into the remote VNET

  <details>
  <summary>Optional</summary>
  - `name` (string) : the name of the remote VNET peering
  </details>

  EOF
  type        = map(any)
}
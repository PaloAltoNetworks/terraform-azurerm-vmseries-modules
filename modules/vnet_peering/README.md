<!-- BEGIN_TF_DOCS -->
# Palo Alto Networks VNet Peering Module for Azure

A terraform module for deploying a Virtual Network Peering and its components required for the VM-Series firewalls in Azure.

## Usage

Simple usage example:

```hcl
local_peer_config = {
  name                = "peer-local_vnet-to-remote_vnet"
  resource_group_name = "local_resourcegroup_name"
  vnet_name           = "local_vnet_name"
}

remote_peer_config = {
  name                = "peer-remote_vnet-to-local_vnet"
  resource_group_name = "remote_resourcegroup_name"
  vnet_name           = "remote_vnet_name"
}
```

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`local_peer_config`](#local_peer_config) | `object` | A map that contains the local peer configuration.
[`remote_peer_config`](#remote_peer_config) | `object` | A map that contains the remote peer configuration.




## Module's Outputs

Name |  Description
--- | ---
`local_peering_name` | The name of the local VNET peering.
`remote_peering_name` | The name of the remote VNET peering.
`local_peering_id` | The ID of the local VNET peering.
`remote_peering_id` | The ID of the remote VNET peering.

## Module's Nameplate


Requirements needed by this module:

- `terraform`, version: >= 1.3, < 2.0
- `azurerm`, version: ~> 3.25


Providers used in this module:

- `azurerm`, version: ~> 3.25




Resources used in this module:

- `virtual_network_peering` (managed)
- `virtual_network_peering` (managed)
- `virtual_network` (data)
- `virtual_network` (data)

## Inputs/Outpus details

### Required Inputs


#### local_peer_config

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


Type: 

```hcl
object({
    name                         = string
    resource_group_name          = string
    vnet_name                    = string
    allow_virtual_network_access = optional(bool, true)
    allow_forwarded_traffic      = optional(bool, true)
    allow_gateway_transit        = optional(bool, false)
    use_remote_gateways          = optional(bool, false)
  })
```


<sup>[back to list](#modules-required-inputs)</sup>

#### remote_peer_config

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


Type: 

```hcl
object({
    name                         = string
    resource_group_name          = string
    vnet_name                    = string
    allow_virtual_network_access = optional(bool, true)
    allow_forwarded_traffic      = optional(bool, true)
    allow_gateway_transit        = optional(bool, false)
    use_remote_gateways          = optional(bool, false)
  })
```


<sup>[back to list](#modules-required-inputs)</sup>



<!-- END_TF_DOCS -->
<!-- BEGIN_TF_DOCS -->


## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`local_peer_config`](#local_peer_config) | `map(any)` | A map that contains the local peer configuration.
[`remote_peer_config`](#remote_peer_config) | `map(any)` | A map that contains the remote peer configuration.

## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`name_prefix`](#name_prefix) | `string` | Prefix name appended to the peering names.

## Module's Outputs

Name |  Description
--- | ---
[`local_peering_name`](#local_peering_name) | The name of the local VNET peering
[`remote_peering_name`](#remote_peering_name) | The name of the remote VNET peering
[`local_peering_id`](#local_peering_id) | The ID of the local VNET peering
[`remote_peering_id`](#remote_peering_id) | The ID of the remote VNET peering

## Module's Nameplate

Requirements needed by this module:

- `terraform`, version: >= 1.2, < 2.0
- `azurerm`, version: ~> 3.25

Providers used in this module:

- `azurerm`, version: ~> 3.25

Modules used in this module:
Name | Version | Source | Description
--- | --- | --- | ---

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
- `vnet_name`                   - (`string`, required) the local peer VNET name.
- `resource_group_name          - (`string`, required) : the resource group name of the local peer
- `allow_virtual_network_access - (`bool`, optional, defaults to `true`) : allows communication between the two peering VNETs
- `allow_forwarded_traffic`     - (`bool`, optional, defaults to `true`) : allows traffic forwarded from the remote VNET but not originated from within it
- `allow_gateway_transit`       - (`bool`, optional, defaults to `false`) : controls the learning of routes from local VNET (gateway or route server) into the remote VNET. Must be true if `use_remote_gateways` is `true` for remote peer
- `use_remote_gateways`         - (`bool`, optional, defaults to `false`) : controls the learning of routes from the remote VNET (gateway or route server) into the local VNET
- `name`                        - (`string`, optional, defaults to `<var.name_prefix><var.local_peer_config.vnet_name>-to-<var.remote_peer_config.vnet_name>`) : the name of the local VNET peering


Type: `map(any)`

<sup>[back to list](#modules-required-inputs)</sup>

#### remote_peer_config

A map that contains the remote peer configuration.
Mandatory Values :
- `vnet_name`                   - (`string`, required) : the remote peer VNET name.
- `resource_group_name          - (`string`, required) : the resource group name of the remote peer
- `allow_virtual_network_access - (`bool`, optional, defaults to `true`) : allows communication between the two peering VNETs
- `allow_forwarded_traffic`     - (`bool`, optional, defaults to `true`) : allows traffic forwarded from the local VNET but not originated from within it
- `allow_gateway_transit`       - (`bool`, optional, defaults to `false`) : controls the learning of routes from remote VNET (gateway or route server) into the local VNET. Must be true if `use_remote_gateways` is `true` for local peer
- `use_remote_gateways`         - (`bool`, optional, defaults to `false`) : controls the learning of routes from the local VNET (gateway or route server) into the remote VNET
- `name`                        - (`string`, optional, defaults to `<var.name_prefix><var.remote_peer_config.vnet_name>-to-<var.local_peer_config.vnet_name>`) : the name of the local VNET peering


Type: `map(any)`

<sup>[back to list](#modules-required-inputs)</sup>


### Optional Inputs


#### name_prefix

Prefix name appended to the peering names.

Type: `string`

Default value: ``

<sup>[back to list](#modules-optional-inputs)</sup>




### Outputs


#### `local_peering_name`

The name of the local VNET peering.

<sup>[back to list](#modules-outputs)</sup>
#### `remote_peering_name`

The name of the remote VNET peering.

<sup>[back to list](#modules-outputs)</sup>
#### `local_peering_id`

The ID of the local VNET peering.

<sup>[back to list](#modules-outputs)</sup>
#### `remote_peering_id`

The ID of the remote VNET peering.

<sup>[back to list](#modules-outputs)</sup>
<!-- END_TF_DOCS -->
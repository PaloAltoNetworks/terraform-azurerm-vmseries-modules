# Palo Alto Networks VNet Peering Module for Azure

A terraform module for deploying a Virtual Network Peering and its components required for the VM-Series firewalls in Azure.

## Usage

For usage refer to any example module.

## Reference
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2, < 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.25 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.25 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [azurerm_virtual_network_peering.local](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.remote](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network.local_peer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |
| [azurerm_virtual_network.remote_peer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix name appended to the peering names. | `string` | `""` | no |
| <a name="input_local_peer_config"></a> [local\_peer\_config](#input\_local\_peer\_config) | A map that contains the local peer configuration.<br>Mandatory Values: <br>- `vnet_name` (`string`) : the local peer VNET name.<br>- `resource_group_name (`string`) : the resource group name of the local peer<br>- `allow\_virtual\_network\_access (`bool`) : allows communication between the two peering VNETs<br>- `allow_forwarded_traffic` (`bool`) : allows traffic forwarded from the remote VNET but not originated from within it<br>- `allow_gateway_transit` (`bool`) : controls the learning of routes from local VNET (gateway or route server) into the remote VNET. Must be true if `use_remote_gateways` is `true` for remote peer<br>- `use_remote_gateways` (`bool`) : controls the learning of routes from the remote VNET (gateway or route server) into the local VNET<br><br><details><br><summary>Optional</summary><br>- <br></details><br>- `name` (string) : the name of the local VNET peering | <pre>object({<br>    vnet_name                    = string<br>    resource_group_name          = string<br>    name                         = optional(string)<br>    allow_virtual_network_access = bool<br>    allow_forwarded_traffic      = bool<br>    allow_gateway_transit        = bool<br>    use_remote_gateways          = bool<br>  })</pre> | n/a | yes |
| <a name="input_remote_peer_config"></a> [remote\_peer\_config](#input\_remote\_peer\_config) | A map that contains the remote peer configuration.<br>Mandatory Values : <br>- `vnet_name` (`string`) : the remote peer VNET name.<br>- `resource_group_name (`string`) : the resource group name of the remote peer<br>- `allow\_virtual\_network\_access (`bool`) : allows communication between the two peering VNETs<br>- `allow_forwarded_traffic` (`bool`) : allows traffic forwarded from the local VNET but not originated from within it<br>- `allow_gateway_transit` (`bool`) : controls the learning of routes from remote VNET (gateway or route server) into the local VNET. Must be true if `use_remote_gateways` is `true` for local peer<br>- `use_remote_gateways` (`bool`) : controls the learning of routes from the local VNET (gateway or route server) into the remote VNET<br><br><details><br><summary>Optional</summary><br>- <br></details><br>- `name` (string) : the name of the remote VNET peering | <pre>object({<br>    vnet_name                    = string<br>    resource_group_name          = string<br>    name                         = optional(string)<br>    allow_virtual_network_access = bool<br>    allow_forwarded_traffic      = bool<br>    allow_gateway_transit        = bool<br>    use_remote_gateways          = bool<br>  })</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_local_peering_name"></a> [local\_peering\_name](#output\_local\_peering\_name) | The name of the local VNET peering. |
| <a name="output_remote_peering_name"></a> [remote\_peering\_name](#output\_remote\_peering\_name) | The name of the remote VNET peering. |
| <a name="output_local_peering_id"></a> [local\_peering\_id](#output\_local\_peering\_id) | The ID of the local VNET peering. |
| <a name="output_remote_peering_id"></a> [remote\_peering\_id](#output\_remote\_peering\_id) | The ID of the remote VNET peering. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
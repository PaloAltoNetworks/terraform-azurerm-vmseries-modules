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
| [azurerm_virtual_network_peering.peer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network.local](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |
| [azurerm_virtual_network.peer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_local_resource_group_name"></a> [local\_resource\_group\_name](#input\_local\_resource\_group\_name) | Name of the existing local peer resource group where to place the resources created. | `string` | n/a | yes |
| <a name="input_peer_resource_group_name"></a> [peer\_resource\_group\_name](#input\_peer\_resource\_group\_name) | Name of the existing remote peer resource group where to place the resources created. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix name appended to the peering names. | `string` | `""` | no |
| <a name="input_local_vnet_name"></a> [local\_vnet\_name](#input\_local\_vnet\_name) | Local VNET name. | `string` | `""` | no |
| <a name="input_peer_vnet_name"></a> [peer\_vnet\_name](#input\_peer\_vnet\_name) | Peer VNET name. | `string` | `""` | no |
| <a name="input_local_allow_virtual_network_access"></a> [local\_allow\_virtual\_network\_access](#input\_local\_allow\_virtual\_network\_access) | Local peer setting for allowing traffic from peer VNET to VMs in the local VNET. | `bool` | `true` | no |
| <a name="input_local_allow_forwarded_traffic"></a> [local\_allow\_forwarded\_traffic](#input\_local\_allow\_forwarded\_traffic) | Local peer setting for forwarded traffic from VMs in the peer VNET. | `bool` | `true` | no |
| <a name="input_local_allow_gateway_transit"></a> [local\_allow\_gateway\_transit](#input\_local\_allow\_gateway\_transit) | Local peer setting for allowing gateway links for remote gateway or Route Server in the peer VNET. | `bool` | `false` | no |
| <a name="input_local_use_remote_gateways"></a> [local\_use\_remote\_gateways](#input\_local\_use\_remote\_gateways) | Local peer setting for using peer VNET remote gateway or Route Server. If set to `true` - `peer_allow_gateway_transit` needs to be set to true. | `bool` | `false` | no |
| <a name="input_peer_allow_virtual_network_access"></a> [peer\_allow\_virtual\_network\_access](#input\_peer\_allow\_virtual\_network\_access) | Remote peer setting for allowing traffic from local VNET to VMs in the peer VNET. | `bool` | `true` | no |
| <a name="input_peer_allow_forwarded_traffic"></a> [peer\_allow\_forwarded\_traffic](#input\_peer\_allow\_forwarded\_traffic) | Remote peer setting for forwarded traffic from VMs in the local VNET. | `bool` | `true` | no |
| <a name="input_peer_allow_gateway_transit"></a> [peer\_allow\_gateway\_transit](#input\_peer\_allow\_gateway\_transit) | Remote peer setting for allowing gateway links for remote gateway or Route Server in the local VNET. | `bool` | `false` | no |
| <a name="input_peer_use_remote_gateways"></a> [peer\_use\_remote\_gateways](#input\_peer\_use\_remote\_gateways) | Remote peer setting for using local VNET remote gateway or Route Server. If set to `true` - `local_allow_gateway_transit` needs to be set to true. | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_local_peering_name"></a> [local\_peering\_name](#output\_local\_peering\_name) | The name of the local VNET peering. |
| <a name="output_remote_peering_name"></a> [remote\_peering\_name](#output\_remote\_peering\_name) | The name of the remote VNET peering. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
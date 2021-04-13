Palo Alto Networks Networking Module for Azure
===========

A terraform module for deploying the networking components required for VM-Series firewalls in Azure.

Usage
-----

```hcl
module "networks" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/networking"

  location    = "Australia Central"
  name_prefix = "pan"
  management_ips = {
      "124.171.153.28" : 100,
    }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.12.29, <0.14 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=2.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=2.26.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.sg-allowall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.sg-mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.sg-panorama-mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.inter-vnet-rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.management-rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.outside-allowall-inbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.outside-allowall-outbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.panorama-allowall-outbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.vm-management-rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.vmseries-allowall-outbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.vmseries-mgmt-inbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_route_table.udr-inside](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet.subnet-inside](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.subnet-outside](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.subnet-panorama-mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.subnet_mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.mgmt-sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.panorama-mgmt-sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.sg-inside-associate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.sg-outside-associate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.rta](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.vnet-panorama-mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network.vnet-vmseries](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.fw-panorama-peer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.panorama-fw-peer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewall_vnet_prefix"></a> [firewall\_vnet\_prefix](#input\_firewall\_vnet\_prefix) | The private prefix used for all firewall networks. | `string` | `"10.110."` | no |
| <a name="input_location"></a> [location](#input\_location) | Region to deploy all networking resources. | `any` | n/a | yes |
| <a name="input_management_ips"></a> [management\_ips](#input\_management\_ips) | External IP addresses or prefixes that will be permitted direct access to the management network. | `map(any)` | n/a | yes |
| <a name="input_management_subnet"></a> [management\_subnet](#input\_management\_subnet) | The private network that terminates all FW and Panorama IP addresses - Joined with management\_vnet\_prefix. | `string` | `"0.0/24"` | no |
| <a name="input_management_vnet_prefix"></a> [management\_vnet\_prefix](#input\_management\_vnet\_prefix) | The private prefix used for the management virtual network. | `string` | `"10.255."` | no |
| <a name="input_name_fw_panorama_peer"></a> [name\_fw\_panorama\_peer](#input\_name\_fw\_panorama\_peer) | n/a | `string` | `"fw-panorama-peer"` | no |
| <a name="input_name_inter_vnet_rule"></a> [name\_inter\_vnet\_rule](#input\_name\_inter\_vnet\_rule) | n/a | `string` | `"inter-vnet-rule"` | no |
| <a name="input_name_management_rules"></a> [name\_management\_rules](#input\_name\_management\_rules) | n/a | `string` | `"panorama-mgmt-sgrule"` | no |
| <a name="input_name_outside_allowall_inbound"></a> [name\_outside\_allowall\_inbound](#input\_name\_outside\_allowall\_inbound) | n/a | `string` | `"outside-allowall-inbound"` | no |
| <a name="input_name_outside_allowall_outbound"></a> [name\_outside\_allowall\_outbound](#input\_name\_outside\_allowall\_outbound) | n/a | `string` | `"outside-allowall-outbound"` | no |
| <a name="input_name_panorama_allowall_outbound"></a> [name\_panorama\_allowall\_outbound](#input\_name\_panorama\_allowall\_outbound) | n/a | `string` | `"panorama-allowall-outbound"` | no |
| <a name="input_name_panorama_fw_peer"></a> [name\_panorama\_fw\_peer](#input\_name\_panorama\_fw\_peer) | n/a | `string` | `"panorama-fw-peer"` | no |
| <a name="input_name_panorama_sg"></a> [name\_panorama\_sg](#input\_name\_panorama\_sg) | n/a | `string` | `"sg-panorama-mgmt"` | no |
| <a name="input_name_panorama_subnet_mgmt"></a> [name\_panorama\_subnet\_mgmt](#input\_name\_panorama\_subnet\_mgmt) | n/a | `string` | `"net-panorama-mgmt"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to add to all the object names here. | `any` | n/a | yes |
| <a name="input_name_rg"></a> [name\_rg](#input\_name\_rg) | n/a | `string` | `"networks"` | no |
| <a name="input_name_sg_allowall"></a> [name\_sg\_allowall](#input\_name\_sg\_allowall) | n/a | `string` | `"sg-allowall"` | no |
| <a name="input_name_sg_mgmt"></a> [name\_sg\_mgmt](#input\_name\_sg\_mgmt) | n/a | `string` | `"sg-vmmgmt"` | no |
| <a name="input_name_subnet_inside"></a> [name\_subnet\_inside](#input\_name\_subnet\_inside) | n/a | `string` | `"net-inside"` | no |
| <a name="input_name_subnet_mgmt"></a> [name\_subnet\_mgmt](#input\_name\_subnet\_mgmt) | n/a | `string` | `"net-vmseries-mgmt"` | no |
| <a name="input_name_subnet_outside"></a> [name\_subnet\_outside](#input\_name\_subnet\_outside) | n/a | `string` | `"net-outside"` | no |
| <a name="input_name_udr_inside"></a> [name\_udr\_inside](#input\_name\_udr\_inside) | n/a | `string` | `"udr-inside"` | no |
| <a name="input_name_vm_management_rules"></a> [name\_vm\_management\_rules](#input\_name\_vm\_management\_rules) | n/a | `string` | `"vm-mgmt-sgrule"` | no |
| <a name="input_name_vmseries_allowall_outbound"></a> [name\_vmseries\_allowall\_outbound](#input\_name\_vmseries\_allowall\_outbound) | n/a | `string` | `"vmseries-allowall-outbound"` | no |
| <a name="input_name_vmseries_mgmt_inbound"></a> [name\_vmseries\_mgmt\_inbound](#input\_name\_vmseries\_mgmt\_inbound) | n/a | `string` | `"vmseries-mgmt-inbound"` | no |
| <a name="input_name_vnet_panorama_mgmt"></a> [name\_vnet\_panorama\_mgmt](#input\_name\_vnet\_panorama\_mgmt) | n/a | `string` | `"vnet-panorama-mgmt"` | no |
| <a name="input_name_vnet_vmseries"></a> [name\_vnet\_vmseries](#input\_name\_vnet\_vmseries) | n/a | `string` | `"vnet-vmseries"` | no |
| <a name="input_olb_private_ip"></a> [olb\_private\_ip](#input\_olb\_private\_ip) | The private IP address to assign to the Outgoing Load balancer frontend. This IP MUST fall in the private-subnet network. | `string` | `"10.110.0.21"` | no |
| <a name="input_private_subnet"></a> [private\_subnet](#input\_private\_subnet) | The private network behind or on the internal/private side of the VM series firewalls (eth1/2). | `string` | `"0.0/24"` | no |
| <a name="input_public_subnet"></a> [public\_subnet](#input\_public\_subnet) | The private network that is the external or public side of the VM series firewalls (eth1/1). | `string` | `"129.0/24"` | no |
| <a name="input_sep"></a> [sep](#input\_sep) | Separator | `string` | `"-"` | no |
| <a name="input_vm_management_subnet"></a> [vm\_management\_subnet](#input\_vm\_management\_subnet) | The subnet used for the management NICs on the vm-series. | `string` | `"255.0/24"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_outbound_route_table"></a> [outbound\_route\_table](#output\_outbound\_route\_table) | ID of UDR - can be used to direct traffic from a Spoke VNET to the Transit OLB. |
| <a name="output_panorama_mgmt_subnet"></a> [panorama\_mgmt\_subnet](#output\_panorama\_mgmt\_subnet) | Panorama Management subnet resource. |
| <a name="output_subnet_mgmt"></a> [subnet\_mgmt](#output\_subnet\_mgmt) | Management subnet resource. |
| <a name="output_subnet_private"></a> [subnet\_private](#output\_subnet\_private) | Inside/private subnet resource. |
| <a name="output_subnet_public"></a> [subnet\_public](#output\_subnet\_public) | Outside/public subnet resource. |
| <a name="output_vnet"></a> [vnet](#output\_vnet) | VNET resource. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

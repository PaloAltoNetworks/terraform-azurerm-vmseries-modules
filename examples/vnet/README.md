# Palo Alto Networks VNet Module Example

>Azure Virtual Network (VNet) is the fundamental building block for your private network in Azure. VNet enables many types of Azure resources, such as Azure Virtual Machines (VM), to securely communicate with each other, the internet, and on-premises networks. VNet is similar to a traditional network that you'd operate in your own data center, but brings with it additional benefits of Azure's infrastructure such as scale, availability, and isolation.

This folder shows an example of Terraform code that uses the [Palo Alto Networks VNet module](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/tree/develop/modules/vnet) to deploy a single Virtual Network and a number of network components associated within the VNet in Azure. 

## Usage

Create a `terraform.tfvars` file and copy the content of `example.tfvars` into it, adjust if needed.

```bash
$ terraform init
$ terraform apply
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13, <= 0.14 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=2.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=2.26.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vnet"></a> [vnet](#module\_vnet) | ../../modules/vnet |  |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space used by the virtual network. You can supply more than one address space. | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location of the resources that will be deployed. | `string` | n/a | yes |
| <a name="input_network_security_groups"></a> [network\_security\_groups](#input\_network\_security\_groups) | A map of Network Security Groups objects to create. The object `key` acts as the Network Security Group name.<br>List of arguments available to define a Network Security Group:<br>- `location` : Specifies the Azure location where to deploy the resource.<br>- `resource_group_name` : Name of an existing Resource Group in which to create the Network Security Group.<br>- `rules`: A list of objects representing a Network Security Rule. The object `key` acts as the name of the rule and<br>    needs to be unique across all rules in the Network Security Group.<br>    List of arguments available to define Network Security Rules:<br>    - `resource_group_name` : Name of an existing Resource Group in which to create the Network Security Rules.<br>    - `priority` : Specifies the priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. <br>    The lower the priority number, the higher the priority of the rule.<br>    - `direction` : The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are `Inbound` and `Outbound`.<br>    - `access` : Specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`.<br>    - `protocol` : Network protocol this rule applies to. Possible values include `Tcp`, `Udp`, `Icmp`, or `*` (which matches all).<br>    - `source_port_range` : List of source ports or port ranges.<br>    - `destination_port_range` : Destination Port or Range. Integer or range between `0` and `65535` or `*` to match any.<br>    - `source_address_prefix` : List of source address prefixes. Tags may not be used.<br>    - `destination_address_prefix` : CIDR or destination IP range or `*` to match any IP.<br><br><br>Example:<pre>{<br>  "network_security_group_1" = {<br>    location = "Australia Central"<br>    rules = {<br>      "AllOutbound" = {<br>        priority                   = 100<br>        direction                  = "Outbound"<br>        access                     = "Allow"<br>        protocol                   = "Tcp"<br>        source_port_range          = "*"<br>        destination_port_range     = "*"<br>        source_address_prefix      = "*"<br>        destination_address_prefix = "*"<br>      },<br>      "AllowSSH" = {<br>        priority                   = 200<br>        direction                  = "Inbound"<br>        access                     = "Allow"<br>        protocol                   = "Tcp"<br>        source_port_range          = "*"<br>        destination_port_range     = "22"<br>        source_address_prefix      = "*"<br>        destination_address_prefix = "*"<br>      }<br>    }<br>  },<br>  "network_security_group_2" = {<br>    rules = {}<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to use. | `string` | n/a | yes |
| <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables) | A map of objects describing a Route Table. The object `key` acts as the Route Table name.<br>List of arguments available to define a Route Table:<br>- `location` : Specifies the Azure location where to deploy the resource.<br>- `resource_group_name` : Name of an existing Resource Group in which to create the Route Table.<br>- `routes` (Optional) - A map of routes within a Route Table. <br>  List of arguments available to define a Route:<br>  - `resource_group_name` : Name of an existing Resource Group in which to create the Route Table.<br>  - `address_prefix` : The destination CIDR to which the route applies, such as `10.1.0.0/16`.<br>  - `next_hop_type` : The type of Azure hop the packet should be sent to.<br>  Possible values are: `VirtualNetworkGateway`, `VnetLocal`, `Internet`, `VirtualAppliance` and `None`.<br><br>Example:<pre>{<br>  "route_table_1" = {<br>    routes = {<br>      "route_1" = {<br>        address_prefix = "10.1.0.0/16"<br>        next_hop_type  = "vnetlocal"<br>      },<br>      "route_2" = {<br>        address_prefix = "10.2.0.0/16"<br>        next_hop_type  = "vnetlocal"<br>      },<br>    }<br>  },<br>  "route_table_2" = {<br>    routes = {},<br>  },<br>}</pre> | `any` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A map of subnet objects to create within a Virtual Network. The object `key` acts as the subnet name.<br>List of arguments available to define a subnet:<br>- `address_prefixes` : The address prefix to use for the subnet.<br>- `network_security_group_id` : The Network Security Group ID which should be associated with the subnet.<br>- `route_table_id` : The Route Table ID which should be associated with the subnet.<br>- `tags` : (Optional) A mapping of tags to assign to the resource.<br><br>Example:<pre>{<br>  "management" = {<br>    address_prefixes       = ["10.100.0.0/24"]<br>    network_security_group = "network_security_group_1"<br>    route_table            = "route_table_1"<br>  },<br>  "private" = {<br>    address_prefixes       = ["10.100.1.0/24"]<br>    network_security_group = "network_security_group_2"<br>    route_table            = "route_table_2"<br>  },<br>  "public" = {<br>    address_prefixes       = ["10.100.2.0/24"]<br>    network_security_group = "network_security_group_3"<br>    route_table            = "route_table_3"<br>  },<br>}</pre> | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to all of the created resources. | `map(any)` | `{}` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the VNet to create. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_security_group_ids"></a> [network\_security\_group\_ids](#output\_network\_security\_group\_ids) | The identifiers of the created Network Security Groups. |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The identifier of the Resource Group. |
| <a name="output_resource_group_location"></a> [resource\_group\_location](#output\_resource\_group\_location) | The location of the Resource Group. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the Resource Group. |
| <a name="output_route_table_id"></a> [route\_table\_id](#output\_route\_table\_id) | The identifier of the created Route Tables. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | The identifiers of the created Subnets. |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | The identifier of the created Virtual Network. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# Palo Alto Networks Panorama Module Example

>Panorama is a centralized management system that provides global visibility and control over multiple Palo Alto Networks next generation firewalls through an easy to use web-based interface. Panorama enables administrators to view aggregate or device-specific application, user, and content data and manage multiple Palo Alto Networks firewalls—all from a central location.

This folder shows an example of Terraform code that helps to deploy Panorama in Azure.

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13, < 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.7.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.7.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | ../../modules/bootstrap | n/a |
| <a name="module_panorama"></a> [panorama](#module\_panorama) | ../../modules/panorama | n/a |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | ../../modules/vnet | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_rule.mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | n/a | `list(string)` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |
| <a name="input_allow_inbound_mgmt_ips"></a> [allow\_inbound\_mgmt\_ips](#input\_allow\_inbound\_mgmt\_ips) | List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access management interface of Panorama. | `list(string)` | n/a | yes |
| <a name="input_avzone"></a> [avzone](#input\_avzone) | The availability zone to use, for example "1", "2", "3". Ignored if `enable_zones` is false. Use `avzone = null` to disable the use of Availability Zones. | `string` | `null` | no |
| <a name="input_avzones"></a> [avzones](#input\_avzones) | For better understanding this variable check description in module: ../modules/panorama/variables.tf<br>You can use command in terminal<pre>az vm list-skus --location REGION_NAME --zone --query '[0].locationInfo[0].zones'</pre>to check how many zones are available in your region. | `list(string)` | `[]` | no |
| <a name="input_custom_image_id"></a> [custom\_image\_id](#input\_custom\_image\_id) | n/a | `string` | `null` | no |
| <a name="input_enable_zones"></a> [enable\_zones](#input\_enable\_zones) | If false, the input `avzone` is ignored and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones. | `bool` | `true` | no |
| <a name="input_firewall_mgmt_prefixes"></a> [firewall\_mgmt\_prefixes](#input\_firewall\_mgmt\_prefixes) | n/a | `list(string)` | <pre>[<br>  "10.0.0.0/24"<br>]</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | Region to deploy Panorama into. | `string` | `""` | no |
| <a name="input_network_security_groups"></a> [network\_security\_groups](#input\_network\_security\_groups) | Map of Network Security Groups to create. The key of each entry acts as the Network Security Group name.<br>List of available attributes of each Network Security Group entry:<br>- `location` : (Optional) Specifies the Azure location where to deploy the resource.<br>- `rules`: A list of objects representing a Network Security Rule. The key of each entry acts as the name of the rule and<br>    needs to be unique across all rules in the Network Security Group.<br>    List of attributes available to define a Network Security Rule:<br>    - `priority` : Numeric priority of the rule. The value can be between 100 and 4096 and must be unique for each rule in the collection.<br>    The lower the priority number, the higher the priority of the rule.<br>    - `direction` : The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are `Inbound` and `Outbound`.<br>    - `access` : Specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`.<br>    - `protocol` : Network protocol this rule applies to. Possible values include `Tcp`, `Udp`, `Icmp`, or `*` (which matches all).<br>    - `source_port_range` : List of source ports or port ranges.<br>    - `destination_port_range` : Destination Port or Range. Integer or range between `0` and `65535` or `*` to match any.<br>    - `source_address_prefix` : List of source address prefixes. Tags may not be used.<br>    - `destination_address_prefix` : CIDR or destination IP range or `*` to match any IP.<br><br>Example:<pre>{<br>  "network_security_group_1" = {<br>    location = "Australia Central"<br>    rules = {<br>      "AllOutbound" = {<br>        priority                   = 100<br>        direction                  = "Outbound"<br>        access                     = "Allow"<br>        protocol                   = "Tcp"<br>        source_port_range          = "*"<br>        destination_port_range     = "*"<br>        source_address_prefix      = "*"<br>        destination_address_prefix = "*"<br>      },<br>      "AllowSSH" = {<br>        priority                   = 200<br>        direction                  = "Inbound"<br>        access                     = "Allow"<br>        protocol                   = "Tcp"<br>        source_port_range          = "*"<br>        destination_port_range     = "22"<br>        source_address_prefix      = "*"<br>        destination_address_prefix = "*"<br>      }<br>    }<br>  },<br>  "network_security_group_2" = {<br>    rules = {}<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_panorama_disk_type"></a> [panorama\_disk\_type](#input\_panorama\_disk\_type) | n/a | `string` | `"Standard_LRS"` | no |
| <a name="input_panorama_name"></a> [panorama\_name](#input\_panorama\_name) | n/a | `any` | n/a | yes |
| <a name="input_panorama_private_ip_address"></a> [panorama\_private\_ip\_address](#input\_panorama\_private\_ip\_address) | Optional static private IP address of Panorama, for example 192.168.11.22. If empty, Panorama uses dynamic assignment. | `string` | `null` | no |
| <a name="input_panorama_size"></a> [panorama\_size](#input\_panorama\_size) | n/a | `string` | `"Standard_D5_v2"` | no |
| <a name="input_panorama_sku"></a> [panorama\_sku](#input\_panorama\_sku) | n/a | `string` | `"byol"` | no |
| <a name="input_panorama_version"></a> [panorama\_version](#input\_panorama\_version) | n/a | `string` | `"10.0.3"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to create. | `string` | n/a | yes |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | n/a | `string` | `"nsg-panorama"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Default name of the storage account to create.<br>The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters. | `string` | `"pantfstorage"` | no |
| <a name="input_subnet_names"></a> [subnet\_names](#input\_subnet\_names) | n/a | `list(string)` | <pre>[<br>  "subnet1"<br>]</pre> | no |
| <a name="input_subnet_prefixes"></a> [subnet\_prefixes](#input\_subnet\_prefixes) | n/a | `list(string)` | <pre>[<br>  "10.0.0.0/24"<br>]</pre> | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of subnet objects to create within a virtual network. The key of each entry acts as the subnet name.<br>List of available attributes of each subnet entry:<br>- `address_prefixes` : The address prefix to use for the subnet.<br>- `network_security_group_id` : The Network Security Group identifier to associate with the subnet.<br>- `route_table_id` : The Route Table identifier to associate with the subnet.<br>- `tags` : (Optional) Map of tags to assign to the resource.<br><br>Example:<pre>{<br>  "management" = {<br>    address_prefixes       = ["10.100.0.0/24"]<br>    network_security_group = "network_security_group_1"<br>    route_table            = "route_table_1"<br>  },<br>  "private" = {<br>    address_prefixes       = ["10.100.1.0/24"]<br>    network_security_group = "network_security_group_2"<br>    route_table            = "route_table_2"<br>  },<br>  "public" = {<br>    address_prefixes       = ["10.100.2.0/24"]<br>    network_security_group = "network_security_group_3"<br>    route_table            = "route_table_3"<br>  },<br>}</pre> | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | Initial administrative username to use for Panorama. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-username-requirements-when-creating-a-vm). | `string` | `"panadmin"` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_panorama_url"></a> [panorama\_url](#output\_panorama\_url) | Panorama instance URL. |
| <a name="output_password"></a> [password](#output\_password) | Panorama administrator's initial password. |
| <a name="output_username"></a> [username](#output\_username) | Panorama administrator's initial username. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
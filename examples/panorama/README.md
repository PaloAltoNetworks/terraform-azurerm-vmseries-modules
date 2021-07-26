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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 2.42 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 2.42 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | ../../modules/bootstrap |  |
| <a name="module_nsg"></a> [nsg](#module\_nsg) | Azure/network-security-group/azurerm |  |
| <a name="module_panorama"></a> [panorama](#module\_panorama) | ../../modules/panorama |  |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | Azure/vnet/azurerm |  |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet_network_security_group_association.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | n/a | `list(any)` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |
| <a name="input_avzone"></a> [avzone](#input\_avzone) | n/a | `string` | `null` | no |
| <a name="input_custom_image_id"></a> [custom\_image\_id](#input\_custom\_image\_id) | n/a | `string` | `null` | no |
| <a name="input_firewall_mgmt_prefixes"></a> [firewall\_mgmt\_prefixes](#input\_firewall\_mgmt\_prefixes) | n/a | `list(any)` | <pre>[<br>  "10.0.0.0/24"<br>]</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | Region to deploy Panorama into. | `string` | `""` | no |
| <a name="input_management_ips"></a> [management\_ips](#input\_management\_ips) | A map where the keys are the IP addresses or ranges that are permitted to access the out-of-band management interfaces belonging to firewalls and Panorama devices. The map's values are priorities, integers in the range 102-60000 inclusive. All priorities should be unique. | `map(number)` | n/a | yes |
| <a name="input_panorama_name"></a> [panorama\_name](#input\_panorama\_name) | n/a | `string` | `"panorama"` | no |
| <a name="input_panorama_private_ip_address"></a> [panorama\_private\_ip\_address](#input\_panorama\_private\_ip\_address) | Optional static private IP address of Panorama, for example 192.168.11.22. If empty, Panorama uses dynamic assignment. | `string` | `null` | no |
| <a name="input_panorama_size"></a> [panorama\_size](#input\_panorama\_size) | n/a | `string` | `"Standard_D5_v2"` | no |
| <a name="input_panorama_sku"></a> [panorama\_sku](#input\_panorama\_sku) | n/a | `string` | `"byol"` | no |
| <a name="input_panorama_version"></a> [panorama\_version](#input\_panorama\_version) | n/a | `string` | `"10.0.3"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to create. | `string` | n/a | yes |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | n/a | `string` | `"nsg-panorama"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Default name of the storage account to create.<br>The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters. | `string` | `"pantfstorage"` | no |
| <a name="input_subnet_names"></a> [subnet\_names](#input\_subnet\_names) | n/a | `list(any)` | <pre>[<br>  "subnet1"<br>]</pre> | no |
| <a name="input_subnet_prefixes"></a> [subnet\_prefixes](#input\_subnet\_prefixes) | n/a | `list(any)` | <pre>[<br>  "10.0.0.0/24"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | Initial administrative username to use for Panorama. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-username-requirements-when-creating-a-vm). | `string` | `"panadmin"` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_panorama_admin_password"></a> [panorama\_admin\_password](#output\_panorama\_admin\_password) | Panorama administrator's initial password. |
| <a name="output_panorama_url"></a> [panorama\_url](#output\_panorama\_url) | Panorama instance URL. |
| <a name="output_username"></a> [username](#output\_username) | Panorama administrator's initial username. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
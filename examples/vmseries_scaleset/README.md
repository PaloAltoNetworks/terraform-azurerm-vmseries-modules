# Palo Alto Networks VM-Series Scalset Module Example

>Virtual Machine Scale Sets (VMSS) — A VMSS is a group of individual virtual machines (VMs) within the Microsoft Azure public cloud that administrators can configure and manage as a single unit. The firewall templates provided for auto scaling, create and manage a group of identical, load balanced VM-Series firewalls that are scaled up or down based on custom metrics published by the firewalls to Azure Application Insights. The scaling-in and scaling out operation can be based on configurable thresholds.

This folder shows an example of Terraform code that helps to deploy an auto-scaling tier of VM-Series firewalls using Azure VMSS.

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.12.29, <0.16 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | =2.58 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | =2.58 |
| <a name="provider_random"></a> [random](#provider\_random) | ~>3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_inbound-bootstrap"></a> [inbound-bootstrap](#module\_inbound-bootstrap) | ../../modules/bootstrap |  |
| <a name="module_inbound-lb"></a> [inbound-lb](#module\_inbound-lb) | ../../modules/loadbalancer |  |
| <a name="module_inbound-scaleset"></a> [inbound-scaleset](#module\_inbound-scaleset) | ../../modules/vmss |  |
| <a name="module_outbound-bootstrap"></a> [outbound-bootstrap](#module\_outbound-bootstrap) | ../../modules/bootstrap |  |
| <a name="module_outbound-lb"></a> [outbound-lb](#module\_outbound-lb) | ../../modules/loadbalancer |  |
| <a name="module_outbound-scaleset"></a> [outbound-scaleset](#module\_outbound-scaleset) | ../../modules/vmss |  |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | ../../modules/vnet |  |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/2.58/docs/resources/resource_group) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/2.58/docs/resources/storage_container) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space used by the virtual network. You can supply more than one address space. | `list(string)` | n/a | yes |
| <a name="input_files"></a> [files](#input\_files) | Map of all files to copy to bucket. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\`. For example `{"dir/my.txt" = "config/init-cfg.txt"}` | `map(string)` | `{}` | no |
| <a name="input_lb_private_name"></a> [lb\_private\_name](#input\_lb\_private\_name) | Name of the private load balancer. | `string` | `"lb_private"` | no |
| <a name="input_lb_public_name"></a> [lb\_public\_name](#input\_lb\_public\_name) | Name of the public-facing load balancer. | `string` | `"lb_public"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to use. | `string` | `"Australia Central"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix for all naming conventions - used globally | `string` | `"pantf"` | no |
| <a name="input_network_security_groups"></a> [network\_security\_groups](#input\_network\_security\_groups) | A map of Network Security Groups objects to create. | `map` | n/a | yes |
| <a name="input_olb_private_ip"></a> [olb\_private\_ip](#input\_olb\_private\_ip) | The private IP address to assign to the Outbound Load Balancer. This IP **must** fall in the `private_subnet` network. | `string` | `"10.110.0.21"` | no |
| <a name="input_password"></a> [password](#input\_password) | Initial administrative password to use for all systems. Set to null for an auto-generated password. | `string` | `null` | no |
| <a name="input_private_frontend_ips"></a> [private\_frontend\_ips](#input\_private\_frontend\_ips) | A map of objects describing private LB Frontend IP configurations and rules. See the module's documentation for details. | `any` | n/a | yes |
| <a name="input_public_frontend_ips"></a> [public\_frontend\_ips](#input\_public\_frontend\_ips) | A map of objects describing public LB Frontend IP configurations and rules. See the module's documentation for details. | `any` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to create. | `string` | n/a | yes |
| <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables) | A map of objects describing a Route Table. | `map` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Default name of the storage account to create.<br>The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters. | `string` | `"pantfstorage"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A map of subnet objects to create within a Virtual Network. | `map` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | Initial administrative username to use for all systems. | `string` | `"panadmin"` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the Virtual Network to create. | `string` | n/a | yes |
| <a name="input_vmseries_count"></a> [vmseries\_count](#input\_vmseries\_count) | Total number of VM series to deploy per direction (inbound/outbound). | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_PASSWORD"></a> [PASSWORD](#output\_PASSWORD) | PAN Device password |
| <a name="output_USERNAME"></a> [USERNAME](#output\_USERNAME) | PAN Device username |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

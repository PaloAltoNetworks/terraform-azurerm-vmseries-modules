# Palo Alto Networks VM-Series Scalset Module Example

>Virtual Machine Scale Sets (VMSS) — A VMSS is a group of individual virtual machines (VMs) within the Microsoft Azure public cloud that administrators can configure and manage as a single unit. The firewall templates provided for auto scaling, create and manage a group of identical, load balanced VM-Series firewalls that are scaled up or down based on custom metrics published by the firewalls to Azure Application Insights. The scaling-in and scaling out operation can be based on configurable thresholds.

This folder shows an example of Terraform code that helps to deploy an auto-scaling tier of VM-Series firewalls using Azure VMSS.

## Usage

Create a `terraform.tfvars` file and copy the content of `example.tfvars` into it, adjust if needed.

Create a `files/init-cfg.txt` file and copy the content of `files/init-cfg.sample.txt` into it, adjusting it. (Do not add the file to the repository if it contains secrets such as vm-auth-key.)

```sh
terraform init
terraform apply
```

## Cleanup

Execute:

```sh
terraform destroy -parallelism 1
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.29, < 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | = 2.64 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_inbound_bootstrap"></a> [inbound\_bootstrap](#module\_inbound\_bootstrap) | ../../modules/bootstrap | n/a |
| <a name="module_inbound_lb"></a> [inbound\_lb](#module\_inbound\_lb) | ../../modules/loadbalancer | n/a |
| <a name="module_inbound_scale_set"></a> [inbound\_scale\_set](#module\_inbound\_scale\_set) | ../../modules/vmss | n/a |
| <a name="module_outbound_bootstrap"></a> [outbound\_bootstrap](#module\_outbound\_bootstrap) | ../../modules/bootstrap | n/a |
| <a name="module_outbound_lb"></a> [outbound\_lb](#module\_outbound\_lb) | ../../modules/loadbalancer | n/a |
| <a name="module_outbound_scale_set"></a> [outbound\_scale\_set](#module\_outbound\_scale\_set) | ../../modules/vmss | n/a |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | ../../modules/vnet | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_rule.mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/2.64/docs/resources/network_security_rule) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/2.64/docs/resources/resource_group) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/2.64/docs/resources/storage_container) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space used by the virtual network. You can supply more than one address space. | `list(string)` | n/a | yes |
| <a name="input_allow_inbound_data_ips"></a> [allow\_inbound\_data\_ips](#input\_allow\_inbound\_data\_ips) | List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access public data interfaces of VM-Series.<br>If the list is empty, the contents of `allow_inbound_mgmt_ips` are substituted instead. | `list(string)` | `[]` | no |
| <a name="input_allow_inbound_mgmt_ips"></a> [allow\_inbound\_mgmt\_ips](#input\_allow\_inbound\_mgmt\_ips) | List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access management interfaces of VM-Series.<br>If you use Panorama, include its address in the list (as well as the secondary Panorama's). | `list(string)` | `[]` | no |
| <a name="input_common_vmseries_sku"></a> [common\_vmseries\_sku](#input\_common\_vmseries\_sku) | VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"bundle2"` | no |
| <a name="input_inbound_files"></a> [inbound\_files](#input\_inbound\_files) | Map of all files to copy to `inbound_storage_share_name`. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\`. For example `{"dir/my.txt" = "config/init-cfg.txt"}` | `map(string)` | `{}` | no |
| <a name="input_inbound_storage_share_name"></a> [inbound\_storage\_share\_name](#input\_inbound\_storage\_share\_name) | Name of storage share to be created that holds `files` for bootstrapping inbound VM-Series. | `string` | n/a | yes |
| <a name="input_inbound_vmseries_tags"></a> [inbound\_vmseries\_tags](#input\_inbound\_vmseries\_tags) | Map of tags to be associated with the inbound virtual machines, their interfaces and public IP addresses. | `map(string)` | `{}` | no |
| <a name="input_inbound_vmseries_version"></a> [inbound\_vmseries\_version](#input\_inbound\_vmseries\_version) | Inbound VM-series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"10.0.4"` | no |
| <a name="input_inbound_vmseries_vm_size"></a> [inbound\_vmseries\_vm\_size](#input\_inbound\_vmseries\_vm\_size) | Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported. | `string` | `"Standard_D3_v2"` | no |
| <a name="input_lb_private_name"></a> [lb\_private\_name](#input\_lb\_private\_name) | Name of the private load balancer. | `string` | `"lb_private"` | no |
| <a name="input_lb_public_name"></a> [lb\_public\_name](#input\_lb\_public\_name) | Name of the public-facing load balancer. | `string` | `"lb_public"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to use. | `string` | `"Australia Central"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix for all the names of the created Azure objects. It can end with a dash `-` character, if your naming convention prefers such separator. | `string` | `"pantf"` | no |
| <a name="input_network_security_groups"></a> [network\_security\_groups](#input\_network\_security\_groups) | Map of Network Security Groups to create. Refer to the `vnet` module documentation for more information. | `any` | n/a | yes |
| <a name="input_olb_private_ip"></a> [olb\_private\_ip](#input\_olb\_private\_ip) | The private IP address to assign to the outbound load balancer. This IP **must** fall in the `private_subnet` network. | `string` | `"10.110.0.21"` | no |
| <a name="input_outbound_files"></a> [outbound\_files](#input\_outbound\_files) | Map of all files to copy to `outbound_storage_share_name`. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\`. For example `{"dir/my.txt" = "config/init-cfg.txt"}` | `map(string)` | `{}` | no |
| <a name="input_outbound_storage_share_name"></a> [outbound\_storage\_share\_name](#input\_outbound\_storage\_share\_name) | Name of storage share to be created that holds `files` for bootstrapping outbound VM-Series. | `string` | n/a | yes |
| <a name="input_outbound_vmseries_tags"></a> [outbound\_vmseries\_tags](#input\_outbound\_vmseries\_tags) | Map of tags to be associated with the outbound virtual machines, their interfaces and public IP addresses. | `map(string)` | `{}` | no |
| <a name="input_outbound_vmseries_version"></a> [outbound\_vmseries\_version](#input\_outbound\_vmseries\_version) | Outbound VM-series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"10.0.4"` | no |
| <a name="input_outbound_vmseries_vm_size"></a> [outbound\_vmseries\_vm\_size](#input\_outbound\_vmseries\_vm\_size) | Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported. | `string` | `"Standard_D3_v2"` | no |
| <a name="input_password"></a> [password](#input\_password) | Initial administrative password to use for all systems. Set to null for an auto-generated password. | `string` | `null` | no |
| <a name="input_private_frontend_ips"></a> [private\_frontend\_ips](#input\_private\_frontend\_ips) | Map of objects describing frontend IP configurations and rules for the private load balancer. Refer to the `loadbalancer` module documentation for more information. | `any` | n/a | yes |
| <a name="input_public_frontend_ips"></a> [public\_frontend\_ips](#input\_public\_frontend\_ips) | Map of objects describing frontend IP configurations and rules for the inbound load balancer. Refer to the `loadbalancer` module documentation for more information. | `any` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to create. | `string` | n/a | yes |
| <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables) | Map of Route Tables to create. Refer to the `vnet` module documentation for more information. | `any` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Default name of the storage account to create.<br>The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters. | `string` | `"pantfstorage"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of Subnets to create. Refer to the `vnet` module documentation for more information. | `any` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | Initial administrative username to use for all systems. | `string` | `"panadmin"` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the Virtual Network to create. | `string` | n/a | yes |
| <a name="input_vmseries_count"></a> [vmseries\_count](#input\_vmseries\_count) | Total number of VM series to deploy per direction (inbound/outbound). | `number` | `1` | no |
| <a name="input_vnet_tags"></a> [vnet\_tags](#input\_vnet\_tags) | Map of tags to assign to the created virtual network and other network-related resources. By default equals to `inbound_vmseries_tags`. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_password"></a> [password](#output\_password) | Initial administrative password to use for VM-Series. |
| <a name="output_username"></a> [username](#output\_username) | Initial administrative username to use for VM-Series. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

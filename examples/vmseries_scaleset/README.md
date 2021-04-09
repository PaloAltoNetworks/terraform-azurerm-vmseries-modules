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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.12.29, <0.14 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>2.42 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>2.42 |
| <a name="provider_random"></a> [random](#provider\_random) | ~>3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | ../../modules/bootstrap |  |
| <a name="module_inbound-lb"></a> [inbound-lb](#module\_inbound-lb) | ../../modules/inbound-load-balancer |  |
| <a name="module_inbound-scaleset"></a> [inbound-scaleset](#module\_inbound-scaleset) | ../../modules/vmss |  |
| <a name="module_networks"></a> [networks](#module\_networks) | ../../modules/networking |  |
| <a name="module_outbound-lb"></a> [outbound-lb](#module\_outbound-lb) | ../../modules/outbound-load-balancer |  |
| <a name="module_outbound-scaleset"></a> [outbound-scaleset](#module\_outbound-scaleset) | ../../modules/vmss |  |
| <a name="module_outbound_bootstrap"></a> [outbound\_bootstrap](#module\_outbound\_bootstrap) | ../../modules/bootstrap |  |
| <a name="module_panorama"></a> [panorama](#module\_panorama) | ../../modules/panorama |  |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_files"></a> [files](#input\_files) | Map of all files to copy to bucket. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\`. For example `{"dir/my.txt" = "config/init-cfg.txt"}` | `map(string)` | `{}` | no |
| <a name="input_firewall_vnet_prefix"></a> [firewall\_vnet\_prefix](#input\_firewall\_vnet\_prefix) | The private prefix used for all firewall networks | `string` | `"10.110."` | no |
| <a name="input_frontend_ips"></a> [frontend\_ips](#input\_frontend\_ips) | A map of objects describing LB Frontend IP configurations and rules. See the module's documentation for details. | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to use. | `string` | `"Australia Central"` | no |
| <a name="input_management_ips"></a> [management\_ips](#input\_management\_ips) | A map where the keys are the IP addresses or ranges that are permitted to access the out-of-band management interfaces belonging to firewalls and Panorama devices. The map's values are priorities, integers in the range 102-60000 inclusive. All priorities should be unique. | `map(number)` | n/a | yes |
| <a name="input_management_subnet"></a> [management\_subnet](#input\_management\_subnet) | The private network that terminates all FW and Panorama IP addresses. | `string` | `"0.0/24"` | no |
| <a name="input_management_vnet_prefix"></a> [management\_vnet\_prefix](#input\_management\_vnet\_prefix) | The private prefix used for the management virtual network | `string` | `"10.255."` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix for all naming conventions - used globally | `string` | `"pantf"` | no |
| <a name="input_olb_private_ip"></a> [olb\_private\_ip](#input\_olb\_private\_ip) | The private IP address to assign to the Outgoing Load balancer frontend | `string` | `"10.110.0.21"` | no |
| <a name="input_panorama_sku"></a> [panorama\_sku](#input\_panorama\_sku) | Panorama SKU. | `string` | `"byol"` | no |
| <a name="input_panorama_version"></a> [panorama\_version](#input\_panorama\_version) | Panorama PAN-OS Software version. List published images with `az vm image list -o table --all --publisher paloaltonetworks --offer panorama` | `string` | `"9.0.5"` | no |
| <a name="input_password"></a> [password](#input\_password) | Initial administrative password to use for all systems. Set to null for an auto-generated password. | `string` | `null` | no |
| <a name="input_private_subnet"></a> [private\_subnet](#input\_private\_subnet) | The private network behind or on the internal side of the VM series firewalls (eth1/2) | `string` | `"0.0/24"` | no |
| <a name="input_public_subnet"></a> [public\_subnet](#input\_public\_subnet) | The private network that is the external or public side of the VM series firewalls (eth1/1) | `string` | `"129.0/24"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to use. | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Default name of the storage account to create.<br>The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters. | `string` | `"pantfstorage"` | no |
| <a name="input_username"></a> [username](#input\_username) | Initial administrative username to use for all systems. | `string` | `"panadmin"` | no |
| <a name="input_vm_management_subnet"></a> [vm\_management\_subnet](#input\_vm\_management\_subnet) | The subnet used for the management NICs on the vm-series | `string` | `"255.0/24"` | no |
| <a name="input_vmseries_count"></a> [vmseries\_count](#input\_vmseries\_count) | Total number of VM series to deploy per direction (inbound/outbound). | `number` | `1` | no |
| <a name="input_vmseries_sku"></a> [vmseries\_sku](#input\_vmseries\_sku) | VM-series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"bundle2"` | no |
| <a name="input_vmseries_version"></a> [vmseries\_version](#input\_vmseries\_version) | VM-series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"9.0.4"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_PANORAMA-IP"></a> [PANORAMA-IP](#output\_PANORAMA-IP) | The Public IP address of Panorama. |
| <a name="output_PASSWORD"></a> [PASSWORD](#output\_PASSWORD) | PAN Device password |
| <a name="output_USERNAME"></a> [USERNAME](#output\_USERNAME) | PAN Device username |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

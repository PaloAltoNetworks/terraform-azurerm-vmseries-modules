# Example of `vmseries` Terraform Module on Azure Cloud

The is a very minimal example of the `vmseries` module. It lacks any traffic inspection.
It creates a single VM-Series with a management-only interface. It can be usable for familiarizing
oneself with terraform, as well as a bed for creating a custom pan-os image.

To see a full VM-Series module usage, see the example from the directory [../transit_vnet_common](../transit_vnet_common). It deploys one of the VM-Series Reference Architectures in its entirety, including load balancing.

## NOTICE

This example contains some files that can contain sensitive data, namely `authcodes.sample` and `init-cfg.sample.txt`. Keep in mind that these files are here only as an example. Normally one should avoid placing them in a repository.

## Usage

Create a `terraform.tfvars` file and copy the content of `example.tfvars` into it, adjust if needed.

Then execute:

```sh
terraform init
terraform apply
terraform ouput -json password
```

Having the `username`, `password`, and `mgmt_ip_addresses`, use them to connect through ssh:

```sh
ssh <username>@<mgmt_ip_addresses>
```

## Cleanup

To delete all the resources created by the previous `apply` attempts, execute:

```sh
terraform destroy
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.29, < 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | ../../modules/bootstrap | n/a |
| <a name="module_vmseries"></a> [vmseries](#module\_vmseries) | ../../modules/vmseries | n/a |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | ../../modules/vnet | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_inbound_mgmt_ips"></a> [allow\_inbound\_mgmt\_ips](#input\_allow\_inbound\_mgmt\_ips) | List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access management interfaces of VM-Series.<br>If you use Panorama, include its address in the list (as well as the secondary Panorama's). | `list(string)` | n/a | yes |
| <a name="input_avzones"></a> [avzones](#input\_avzones) | After provider version 3.x you need to specify in which availability zone(s) you want to place IP.<br>ie: for zone-redundant with 3 availability zone in current region value will be:<pre>["1","2","3"]</pre>Use command<pre>az vm list-skus --location REGION_NAME --zone --query '[0].locationInfo[0].zones'</pre>to see how many AZ is<br>in current region. | `list(string)` | `[]` | no |
| <a name="input_common_vmseries_sku"></a> [common\_vmseries\_sku](#input\_common\_vmseries\_sku) | VM-Series SKU, for example `bundle1`, or `bundle2`. If it is `byol`, the VM-Series starts unlicensed. | `string` | n/a | yes |
| <a name="input_files"></a> [files](#input\_files) | Map of all files to copy to bucket. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\`. For example `{"dir/my.txt" = "config/init-cfg.txt"}` | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to use. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to create. | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Default name of the storage account to create.<br>The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters. | `string` | `"pantfstorage"` | no |
| <a name="input_storage_share_name"></a> [storage\_share\_name](#input\_storage\_share\_name) | Name of storage share to be created that holds `files` for bootstrapping. | `string` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | Initial administrative username. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-username-requirements-when-creating-a-vm). | `string` | n/a | yes |
| <a name="input_vm_series_version"></a> [vm\_series\_version](#input\_vm\_series\_version) | VMSeries PanOS Version | `string` | `"10.1.0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mgmt_ip_addresses"></a> [mgmt\_ip\_addresses](#output\_mgmt\_ip\_addresses) | IP Addresses for VM-Series management (https or ssh). |
| <a name="output_password"></a> [password](#output\_password) | Initial administrative password to use for VM-Series. |
| <a name="output_username"></a> [username](#output\_username) | Initial administrative username to use for VM-Series. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# Palo Alto Networks Bootstrap Module for Azure

A terraform module for deploying a storage account and the dependencies required
to [bootstrap a VM-Series firewalls in Azure](https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-the-vm-series-firewall-in-azure.html#idd51f75b8-e579-44d6-a809-2fafcfe4b3b6).

The module does *not* configure the bootstrap images, licenses, or configurations.

## Usage

See the examples/vm-series directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.12.29, <0.15 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>2.42 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>2.42 |
| <a name="provider_random"></a> [random](#provider\_random) | ~>3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_share.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_storage_share_directory.config](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share_directory) | resource |
| [azurerm_storage_share_directory.nonconfig](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share_directory) | resource |
| [azurerm_storage_share_file.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share_file) | resource |
| [random_id.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_storage_account"></a> [create\_storage\_account](#input\_create\_storage\_account) | If true, create a Storage Account and ignore `existing_storage_account`. | `bool` | `true` | no |
| <a name="input_existing_storage_account"></a> [existing\_storage\_account](#input\_existing\_storage\_account) | Name of the existing Storage Account object to use. Ignored when `create_storage_account` is true. | `string` | `null` | no |
| <a name="input_files"></a> [files](#input\_files) | Map of all files to copy to bucket. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\`. For example `{"dir/my.txt" = "config/init-cfg.txt"}` | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Region to deploy vm-series bootstrap resources. Ignored when using an `existing_storage_account`. | `string` | `null` | no |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | The minimum supported TLS version for the storage account. | `string` | `"TLS1_2"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to use. | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Default name of the storage account, if creating it. Ignored when `existing_storage_account` object is non-null.<br>The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters. | `string` | `"pantfstorage"` | no |
| <a name="input_storage_share_name"></a> [storage\_share\_name](#input\_storage\_share\_name) | Name of storage share to be created that holds `files` for bootstrapping. | `string` | `"bootstrapshare"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key for the Azure Storage Account. |
| <a name="output_storage_account"></a> [storage\_account](#output\_storage\_account) | The Azure Storage Account object used for the Bootstrap. |
| <a name="output_storage_share"></a> [storage\_share](#output\_storage\_share) | The File Share object within Azure Storage used for the Bootstrap. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

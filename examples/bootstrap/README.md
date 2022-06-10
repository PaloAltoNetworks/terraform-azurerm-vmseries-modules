# Palo Alto Networks Bootstrap Module Example

This Terraform example uses the [Palo Alto Networks Bootstrap module](../../modules/bootstrap) to deploy a Storage Account and the dependencies required
to [bootstrap a VM-Series firewall in Azure](https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-the-vm-series-firewall-in-azure.html#idd51f75b8-e579-44d6-a809-2fafcfe4b3b6).

The following resources will be deployed when using the provided example:
* 1 [Resource Group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group).
* 1 [Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview).
* 1 [File Share](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction#:~:text=Azure%20Files%20offers%20fully%20managed,cloud%20or%20on%2Dpremises%20deployments).

## Usage

Create a `terraform.tfvars` file and copy the content of `example.tfvars` into it, adjust the variables (in particular the `storage_account_name` should be unique).

```sh
terraform init
terraform apply
terraform output -json
```

## Cleanup

```sh
terraform destroy
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.29, < 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | = 2.64 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | = 2.64 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | = 2.64 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | ../../modules/bootstrap | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/2.64/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_files"></a> [files](#input\_files) | Map of all files to copy to bucket. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\`. For example `{"dir/my.txt" = "config/init-cfg.txt"}` | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Region to deploy the bootstrap resources into. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to create. | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Default name of the storage account to create.<br>The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters. | `string` | `"pantfstorage"` | no |
| <a name="input_storage_share_name"></a> [storage\_share\_name](#input\_storage\_share\_name) | Name of storage share to be created that holds `files` for bootstrapping. | `string` | `"bootstrapshare"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key for the Azure Storage Account. |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | Identifier of the Azure Storage Account object used for the Bootstrap. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Name of the Azure Storage Account object used for the Bootstrap. |
| <a name="output_storage_share_id"></a> [storage\_share\_id](#output\_storage\_share\_id) | Identifier of the File Share within Azure Storage. |
| <a name="output_storage_share_name"></a> [storage\_share\_name](#output\_storage\_share\_name) | Name of the File Share within Azure Storage. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
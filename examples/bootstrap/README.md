# Palo Alto Networks Bootstrap Module Example

This Terraform example uses the [Palo Alto Networks Bootstrap module](../../modules/bootstrap/README.md) to deploy a Storage Account and dependencies required
to [bootstrap a VM-Series firewall in Azure](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-the-vm-series-firewall-in-azure).

This example covers creation of a single Storage Account with two File Shares: one for Next Generation Firewalls handling inbound traffic and one for firewalls handling outbound and east-west (OBEW) traffic.

The following resources will be deployed when using the provided example:
* 1 [Resource Group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group)
* 1 [Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview)
* 2 [File Shares](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction#:~:text=Azure%20Files%20offers%20fully%20managed,cloud%20or%20on%2Dpremises%20deployments).

## NOTICE

This example contains some files that can contain sensitive data, namely `authcodes.sample` and `init-cfg.sample.txt`. Keep in mind that these files are here only as an example. Normally one should avoid placing them in a repository.

## Usage

Create a `terraform.tfvars` file and copy the content of `example.tfvars` into it, adjust the variables (in particular the `storage_account_name` should be unique).

```sh
terraform init
terraform apply
terraform output   # optional, this command will give you the terraform output only
```

## Cleanup

```sh
terraform destroy
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15, < 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_inbound_bootstrap"></a> [inbound\_bootstrap](#module\_inbound\_bootstrap) | ../../modules/bootstrap | n/a |
| <a name="module_obew_bootstrap"></a> [obew\_bootstrap](#module\_obew\_bootstrap) | ../../modules/bootstrap | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_inbound_files"></a> [inbound\_files](#input\_inbound\_files) | Map of all files to copy to a File Share. This represents files for inbound firewall.<br><br>The keys are local paths, values - remote paths. Always use slash `/` as directory separator (unix-like). | `map(string)` | `{}` | no |
| <a name="input_inbound_storage_share_name"></a> [inbound\_storage\_share\_name](#input\_inbound\_storage\_share\_name) | Name of Storage Share that will host files for bootstrapping a firewall protecting inbound traffic. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region to deploy the bootstrap resources into. | `string` | n/a | yes |
| <a name="input_obew_files"></a> [obew\_files](#input\_obew\_files) | Map of all files to copy to a File Share. This represents files for OBEW firewall.<br><br>The keys are local paths, values - remote paths. Always use slash `/` as directory separator (unix-like). | `map(string)` | `{}` | no |
| <a name="input_obew_storage_share_name"></a> [obew\_storage\_share\_name](#input\_obew\_storage\_share\_name) | Name of Storage Share that will host files for bootstrapping a firewall protecting OBEW traffic. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to create. | `string` | n/a | yes |
| <a name="input_retention_policy_days"></a> [retention\_policy\_days](#input\_retention\_policy\_days) | Log retention policy in days | `number` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the Storage Account to create.<br>The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length and may include only numbers and lowercase letters. | `string` | n/a | yes |
| <a name="input_storage_acl"></a> [storage\_acl](#input\_storage\_acl) | If `true`, storage account network rules will be activated with Deny default statement. | `bool` | n/a | yes |
| <a name="input_storage_allow_inbound_public_ips"></a> [storage\_allow\_inbound\_public\_ips](#input\_storage\_allow\_inbound\_public\_ips) | List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access the storage.<br>Only public IPs are allowed - RFC1918 address space is not permitted.<br>Remember to include the IP address you are running terraform from. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key for the Azure Storage Account. |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | Identifier of the Azure Storage Account object used for the Bootstrap. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Name of the Azure Storage Account object used for the Bootstrap. |
| <a name="output_storage_share_ids"></a> [storage\_share\_ids](#output\_storage\_share\_ids) | Identifiers of the File Shares within Azure Storage. |
| <a name="output_storage_share_names"></a> [storage\_share\_names](#output\_storage\_share\_names) | Names of the File Shares within Azure Storage. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| terraform | >=0.12.29, <0.14 |
| azurerm | ~>2.42 |
| azurerm | ~>2.42 |
| random | ~>3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~>2.42 ~>2.42 |
| random | ~>3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create\_storage\_account | If true, create a Storage Account and a Resource Group and ignore `existing_storage_account`. | `bool` | `true` | no |
| existing\_storage\_account | Name of the existing Storage Account object to use. Ignored when `create_storage_account` is true. | `string` | `null` | no |
| files | Map of all files to copy to bucket. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\`. For example `{"dir/my.txt" = "config/init-cfg.txt"}` | `map(string)` | `{}` | no |
| location | Region to deploy vm-series bootstrap resources. Ignored when using an `existing_storage_account`. | `string` | `null` | no |
| resource\_group\_name | Name of the Resource Group to use. | `string` | n/a | yes |
| storage\_account\_name | Default name of the storage account, if creating it. Ignored when `existing_storage_account` object is non-null.<br>The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters. | `string` | `"pantfstorage"` | no |
| storage\_share\_name | Name of storage share to be created that holds `files` for bootstrapping. | `string` | `"bootstrapshare"` | no |

## Outputs

| Name | Description |
|------|-------------|
| primary\_access\_key | The primary access key for the Azure Storage Account. |
| storage\_account | The Azure Storage Account object used for the Bootstrap. |
| storage\_share | The File Share object within Azure Storage used for the Bootstrap. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

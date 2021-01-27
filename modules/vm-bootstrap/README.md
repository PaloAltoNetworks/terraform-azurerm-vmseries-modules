Palo Alto Networks VM-Bootstrap Module for Azure
===========

A terraform module for deploying a storage account and the dependencies required
to [bootstrap a VM-Series firewalls in Azure](https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-the-vm-series-firewall-in-azure.html#idd51f75b8-e579-44d6-a809-2fafcfe4b3b6).

The module does *not* configure the bootstrap images, licenses, or configurations.

Usage
-----

See the examples/vm-series directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >=0.12.29, <0.14 |
| azurerm | >=2.26.0 |
| random | ~>3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >=2.26.0 |
| random | ~>3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bootstrap\_key\_lifetime | Default key lifetime for bootstrap. | `string` | `"8760"` | no |
| create\_storage\_account | If true, create a Storage Account and a Resource Group and ignore `existing_storage_account`. | `bool` | `true` | no |
| existing\_storage\_account | The existing Storage Account object to use. Ignored when `create_storage_account` is true. | `any` | `null` | no |
| files | Map of all files to copy to bucket. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\`. For example `{"dir/my.txt" = "config/init-cfg.txt"}` | `map(string)` | `{}` | no |
| location | Region to deploy vm-series bootstrap resources. Ignored when using an `existing_storage_account`. | `string` | `null` | no |
| name\_inbound\_bootstrap\_storage\_share | n/a | `string` | `"ibbootstrapshare"` | no |
| name\_outbound-bootstrap-storage-share | n/a | `string` | `"obbootstrapshare"` | no |
| name\_prefix | Prefix to add to all the object names here. | `string` | n/a | yes |
| resource\_group\_name | Name of the resource group, if creating it. Ignored when `existing_storage_account` object is non-null. | `string` | `null` | no |
| storage\_account\_name | Name of the storage account, if creating it. Ignored when `existing_storage_account` object is non-null. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| bootstrap-storage-account | Bootstrap storage account resource |
| inbound-bootstrap-share-name | Name of storage share, used to store inbound firewall bootstrap configuration |
| outbound-bootstrap-share-name | Name of storage share, used to store outbound firewall bootstrap configuration |
| storage-key | Primary access key associated with the bootstrap storage account |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

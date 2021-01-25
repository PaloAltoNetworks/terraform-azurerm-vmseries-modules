Palo Alto Networks VM-Bootstrap Module for Azure
===========

A terraform module for deploying a storage account and the dependencies required to bootstrap a VM-Series firewalls in Azure.

The module does *not* configure the bootstrap images, licenses, or configurations.

Usage
-----

```hcl
module "vm-bootstrap" {
  source               = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/vm-bootstrap"
  location             = "Australia Central"
  name_prefix          = "panostf"
  name_bootstrap_share = "bootstrap"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| azurerm | >=2.26.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >=2.26.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bootstrap\_key\_lifetime | Default key lifetime for bootstrap. | `string` | `"8760"` | no |
| location | Region to deploy vm-series bootstrap resources. | `any` | n/a | yes |
| name\_bootstrap\_share | n/a | `string` | `"bootstrap"` | no |
| name\_inbound\_bootstrap\_storage\_share | n/a | `string` | `"ibbootstrapshare"` | no |
| name\_outbound-bootstrap-storage-share | n/a | `string` | `"obbootstrapshare"` | no |
| name\_prefix | Prefix to add to all the object names here | `any` | n/a | yes |
| name\_rg | n/a | `string` | `"rg-bootstrap"` | no |
| name\_vm\_sc | n/a | `string` | `"vm-container"` | no |
| sep | Seperator | `string` | `"-"` | no |

## Outputs

| Name | Description |
|------|-------------|
| bootstrap-storage-account | Bootstrap storage account resource |
| inbound-bootstrap-share-name | Name of storage share, used to store inbound firewall bootstrap configuration |
| outbound-bootstrap-share-name | Name of storage share, used to store outbound firewall bootstrap configuration |
| storage-container-name | Name of storage container available to store VM series disks |
| storage-key | Primary access key associated with the bootstrap storage account |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


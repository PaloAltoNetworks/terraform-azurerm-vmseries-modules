Palo Alto Networks VNet Module for Azure
===========

A terraform module for deploying a Virtual Network and its components required for the VM-Series firewalls in Azure.

Usage
-----

```hcl
module "vnet" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/vnet"

  location             = "East US"
  resource_group_name  = "some-rg"
  virtual_network_name = "some-vnet"
  subnets = {
    "mgmt" = {
      name             = "mgmt"
      address_prefixes = ["10.0.7.0/24"]
    }
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >=0.12.29, <0.14 |

## Providers

| Name | Version |
|------|---------|
| azurerm | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| address\_space | Address space for VNet. | `list(string)` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |
| existing\_vnet | Enable this option if you have already created Virtual Network. | `bool` | `false` | no |
| location | Location of the resources that will be deployed. | `string` | n/a | yes |
| resource\_group\_name | Name of the Resource Group to use. | `string` | n/a | yes |
| subnets | Definition of subnets to create. | `any` | n/a | yes |
| virtual\_network\_name | Name of the Virtual Network to create. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| location | n/a |
| resource\_group | n/a |
| subnets | n/a |
| virtual\_network | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

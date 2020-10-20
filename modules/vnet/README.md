## VNET module

## Overview
This module creates new environment (Resource Group, Virtual Network and Subnets) in Azure cloud for greenfield installation.

## Usage
```hcl
module "vnet" {
  source               = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/vnet"
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

## Providers
| Name | Version |
|------|---------|
| azurerm | tested with: >=2.26.0 |

## Required resources
none

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| location | Location (region) where to create new resources | `string` | none | yes |
| resource_group_name | Name of the Resource Group in which Virtual Network and Subnets will be created | `string` | none | yes |
| virtual_network_name | Name of the Virtual Network in which new Subnets will be created | `string` | none | yes |
| address_space | Address space to use inside newly created Virtual Network | `list(string)` | ["10.0.0.0/16"] | no |
| subnets | Map with definition of subnets to create | `map(map)` | none | yes |

<br>

### "subnets" variable definition
The `subnets` variable is a map of maps, where each map represents a single subnet.
There is brownfield support for existing subnet, for this only required to specify `name` and `existing = true`.

The subnet map has the following inputs available (please see examples folder for additional references):

| Name | Description | Type | Default | Required | Brownfield Required
|------|-------------|------|-------|-------|-------|
| name | The name of the new / existing subnet | string | - | yes | yes |
| existing | Flag only if referencing an existing subnet  | bool | - | no | yes |
| address_prefixes | The CIDR formatted IP ranges | map | - | yes | no |

<br>

## Outputs
| Name | Description | Type |
|------|-------------|------|
| location | Location (region) where resources were created | string |
| resource_group | Newly created Resource Group | map |
| virtual_network | Newly cretaed Virtual Network | map |
| subnets | Newly created subnets | map of maps |

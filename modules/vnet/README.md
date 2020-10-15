## VNET module

## Overview
This module creates new environment (Resource Group, Virtual Network and Subnets) in Azure cloud for greenfield installation.

## Usage
```
module "vnet" {
  source               = "../../../modules/azurerm/vnet"
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
| location | Location (region) where to create new resources | string | none | yes |
| resource_group_name | Name of the Resource Group in which Virtual Network and Subnets will be created | string | none | yes |
| virtual_network_name | Name of the Virtual Network in which new Subnets will be created | string | none | yes |
| address_space | Address space to use inside newly created Virtual Network | list od strings | ["10.0.0.0/16"] | no |
| subnets | Map with definition of subnets to create | map(map) | none | yes |

## Outputs
| Name | Description | Type |
|------|-------------|------|
| location | Location (region) where resources were created | string |
| resource_group | Newly created Resource Group | map |
| virtual_network | Newly cretaed Virtual Network | map |
| subnets | Newly created subnets | map of maps |

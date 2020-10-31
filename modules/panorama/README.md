networking terraform module
===========

A terraform module for deploying a working Panorama instance in Azure.

Usage
-----

```hcl
module "panorama" {
  source      = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/panorama"
  location    = "Australia Central"
  name_prefix = "panostf"
  password    = "your-password"
}
```

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
| location | Region to deploy panorama into. | `any` | n/a | yes |
| name\_mgmt | n/a | `string` | `"nic-mgmt"` | no |
| name\_panorama | n/a | `string` | `"panorama"` | no |
| name\_panorama\_pip\_mgmt | n/a | `string` | `"panorama-pip"` | no |
| name\_prefix | Prefix to add to all the object names here | `any` | n/a | yes |
| name\_rg | n/a | `string` | `"rg-panorama"` | no |
| panorama\_size | Default size for Panorama | `string` | `"Standard_D5_v2"` | no |
| panorama\_sku | Panorama SKU - list available with az vm image list --publisher paloaltonetworks --all | `string` | `"byol"` | no |
| panorama\_version | Panorama Software version | `string` | `"9.0.5"` | no |
| password | Panorama Password | `any` | n/a | yes |
| sep | Seperator | `string` | `"-"` | no |
| subnet\_mgmt | Management subnet. | `any` | n/a | yes |
| username | Panorama Username | `string` | `"panadmin"` | no |

## Outputs

| Name | Description |
|------|-------------|
| panorama-publicip | Panorama Public IP address |
| resource-group | Panorama Resource group resource |


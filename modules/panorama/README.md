Palo Alto Networks Panorama Module for Azure
===========

A terraform module for deploying a working Panorama instance in Azure.

Usage
-----

```hcl
module "panorama" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/panorama"

  location    = "Australia Central"
  name_prefix = "pan"
  password    = "your-password"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >=0.12.29, <=0.14 |
| azurerm | >=2.26.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >=2.26.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| Logical\_unit\_number | The Logical Unit Number of the Data Disk, which needs to be unique within the Virtual Machine. Changing this forces a new resource to be created. | `string` | `"10"` | no |
| enable\_logging\_disk | Enable / Disable attaching a managed disk for Panorama logging | `bool` | `false` | no |
| location | Region to deploy panorama into. | `any` | n/a | yes |
| logging\_disk\_size | Panorama logging disk size in GB | `string` | `"2000"` | no |
| name\_mgmt | n/a | `string` | `"nic-mgmt"` | no |
| name\_panorama | n/a | `string` | `"panorama"` | no |
| name\_panorama\_pip\_mgmt | n/a | `string` | `"panorama-pip"` | no |
| name\_prefix | Prefix to add to all the object names here. | `any` | n/a | yes |
| name\_rg | n/a | `string` | `"rg-panorama"` | no |
| panorama\_ha | Enable / Disable Panorama HA | `bool` | `false` | no |
| panorama\_ha\_suffix\_map | n/a | `list(string)` | <pre>[<br>  "a",<br>  "b"<br>]</pre> | no |
| panorama\_size | Virtual Machine size. | `string` | `"Standard_D5_v2"` | no |
| panorama\_sku | Panorama SKU. | `string` | `"byol"` | no |
| panorama\_version | Panorama PAN-OS Software version. List published images with `az vm image list -o table --all --publisher paloaltonetworks --offer panorama` | `string` | `"10.0.3"` | no |
| password | Initial administrative password to use for Panorama. | `string` | n/a | yes |
| sep | Separator used in the names of the generated resources. May be empty. | `string` | `"-"` | no |
| subnet\_mgmt | Panorama's management subnet ID. | `any` | n/a | yes |
| username | Initial administrative username to use for Panorama. | `string` | `"panadmin"` | no |

## Outputs

| Name | Description |
|------|-------------|
| panorama-publicip | Panorama Public IP addresses |
| resource-group | Panorama Resource group resource |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
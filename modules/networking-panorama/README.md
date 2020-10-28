networking terraform module
===========

A terraform module for deploying the networking requirements for Panorama in Azure. 

Usage
-----

```hcl
module "networks" {
  source         = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/networking-panorama"
  location    = "Australia Central"
  name_prefix = "panostf"
  management_ips = {
      "124.171.153.28" : 100,
    }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | Region to install vm-series and dependencies. | `any` | n/a | yes |
| management\_ips | External IP addresses or prefixes that will be permitted direct access to the management network. | `map(any)` | n/a | yes |
| management\_subnet | The private network that terminates all FW and Panorama IP addresses - Joined with management\_vnet\_prefix | `string` | `"0.0/24"` | no |
| management\_vnet\_prefix | The private prefix used for the management virtual network | `string` | `"10.255."` | no |
| name\_management\_rules | n/a | `string` | `"panorama-mgmt-sgrule"` | no |
| name\_panorama\_allowall\_outbound | n/a | `string` | `"panorama-allowall-outbound"` | no |
| name\_panorama\_sg | n/a | `string` | `"sg-panorama-mgmt"` | no |
| name\_panorama\_subnet\_mgmt | n/a | `string` | `"net-panorama-mgmt"` | no |
| name\_prefix | Prefix to add to all the object names here | `any` | n/a | yes |
| name\_rg | n/a | `string` | `"rg-panorama-networks"` | no |
| name\_vnet\_panorama\_mgmt | n/a | `string` | `"vnet-panorama-mgmt"` | no |
| sep | Separator | `string` | `"-"` | no |

## Outputs

| Name | Description |
|------|-------------|
| panorama-mgmt-subnet | Panorama Management subnet resource. |



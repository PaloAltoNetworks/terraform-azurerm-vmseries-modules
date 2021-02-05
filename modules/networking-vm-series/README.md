Palo Alto Networks Networking Module for Azure
===========

A terraform module for deploying the networking components required for VM-Series firewalls in Azure.

Usage
-----

```hcl
module "networks" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/networking-vm-series"

  location       = "Australia Central"
  name_prefix    = "pan"
  management_ips = {
      "124.171.153.28" : 100,
    }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >=0.12.29, <0.14 |
| azurerm | >=2.26.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >=2.26.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| firewall\_vnet\_prefix | The private prefix used for all firewall networks. | `string` | `"10.110."` | no |
| location | Region to deploy vm-series networking resources. | `any` | n/a | yes |
| management\_ips | External IP addresses or prefixes that will be permitted direct access to the management network. | `map(any)` | n/a | yes |
| management\_subnet | The private network that terminates all FW and Panorama IP addresses - Joined with management\_vnet\_prefix. | `string` | `"0.0/24"` | no |
| management\_vnet\_prefix | The private prefix used for the management virtual network. | `string` | `"10.255."` | no |
| name\_inter\_vnet\_rule | n/a | `string` | `"inter-vnet-rule"` | no |
| name\_management\_rules | n/a | `string` | `"mgmt-sgrule"` | no |
| name\_outside\_allowall\_inbound | n/a | `string` | `"outside-allowall-inbound"` | no |
| name\_outside\_allowall\_outbound | n/a | `string` | `"outside-allowall-outbound"` | no |
| name\_panorama\_allowall\_outbound | n/a | `string` | `"panorama-allowall-outbound"` | no |
| name\_prefix | Prefix to add to all the object names here. | `any` | n/a | yes |
| name\_rg | n/a | `string` | `"rg-networks-vmseries"` | no |
| name\_sg\_allowall | n/a | `string` | `"sg-allowall"` | no |
| name\_sg\_mgmt | n/a | `string` | `"sg-vmmgmt"` | no |
| name\_subnet\_inside | n/a | `string` | `"net-inside"` | no |
| name\_subnet\_mgmt | n/a | `string` | `"net-vmseries-mgmt"` | no |
| name\_subnet\_outside | n/a | `string` | `"net-outside"` | no |
| name\_udr\_inside | n/a | `string` | `"udr-inside"` | no |
| name\_vm\_management\_rules | n/a | `string` | `"vm-mgmt-sgrule"` | no |
| name\_vmseries\_allowall\_outbound | n/a | `string` | `"vmseries-allowall-outbound"` | no |
| name\_vmseries\_mgmt\_inbound | n/a | `string` | `"vmseries-mgmt-inbound"` | no |
| name\_vnet\_panorama\_mgmt | n/a | `string` | `"vnet-panorama-mgmt"` | no |
| name\_vnet\_vmseries | n/a | `string` | `"vnet-vmseries"` | no |
| olb\_private\_ip | The private IP address to assign to the Outgoing Load balancer frontend. This IP MUST fall in the private-subnet network. | `string` | `"10.110.0.21"` | no |
| private\_subnet | The private network behind or on the internal/private side of the VM series firewalls (eth1/2). | `string` | `"0.0/24"` | no |
| public\_subnet | The private network that is the external or public side of the VM series firewalls (eth1/1). | `string` | `"129.0/24"` | no |
| sep | Separator | `string` | `"-"` | no |
| vm\_management\_subnet | The subnet used for the management NICs on the vm-series. | `string` | `"255.0/24"` | no |

## Outputs

| Name | Description |
|------|-------------|
| outbound-route-table | ID of UDR - can be used to direct traffic from a Spoke VNET to the Transit OLB. |
| subnet-private | Inside/private subnet resource. |
| subnet-public | Outside/public subnet resource. |
| subnet\_mgmt | Management subnet resource. |
| vnet | VNET resource. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

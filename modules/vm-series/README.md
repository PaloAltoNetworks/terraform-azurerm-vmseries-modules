networking terraform module
===========

A terraform module for deploying standalone (non-scale-set) VM series firewalls in Azure.

This module deploys a single VM-series

Usage
-----

```hcl
module "vm-series" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/vm-series"

  location                      = "Australia Central"
  name_prefix                   = "panostf"
  password                      = "your-password"
  subnet-mgmt                   = azurerm_subnet.subnet-mgmt
  subnet-private                = azurerm_subnet.subnet-private
  subnet-public                 = module.networks.subnet-public
  bootstrap-storage-account     = module.panorama.bootstrap-storage-account
  bootstrap-share-name          = "sharename"
  vhd-container                 = "vhd-storage-container-name"
  lb_backend_pool_id            = "private-backend-pool-id"
}
```

The module only supports Azure regions that have more than one fault domain. (As of 2021, the only two regions impacted are SouthCentralUSSTG and CentralUSEUAP. [Instruction to re-check regions](https://docs.microsoft.com/en-us/azure/virtual-machines/manage-availability#use-managed-disks-for-vms-in-an-availability-set) in future.) The reason is that the module uses Availability Sets with Managed Disks.

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
| bootstrap-share-name | Azure File share for bootstrap config | `any` | n/a | yes |
| bootstrap-storage-account | Storage account setup for bootstrapping | `any` | n/a | yes |
| lb\_backend\_pool\_id | ID Of inbound load balancer backend pool to associate with the VM series firewall | `any` | n/a | yes |
| location | Region to install vm-series and dependencies. | `any` | n/a | yes |
| name\_az | n/a | `string` | `"ib-vm-az"` | no |
| name\_fw\_ip\_mgmt | n/a | `string` | `"ib-fw-ip-mgmt"` | no |
| name\_fw\_ip\_private | n/a | `string` | `"ib-fw-ip-private"` | no |
| name\_fw\_ip\_public | n/a | `string` | `"ib-fw-ip-public"` | no |
| name\_inbound\_fw | n/a | `string` | `"ib-fw"` | no |
| name\_nic\_fw\_mgmt | n/a | `string` | `"ib-nic-fw-mgmt"` | no |
| name\_nic\_fw\_private | n/a | `string` | `"ib-nic-fw-private"` | no |
| name\_nic\_fw\_public | n/a | `string` | `"ib-nic-fw-public"` | no |
| name\_pip\_fw\_mgmt | n/a | `string` | `"ib-fw-pip"` | no |
| name\_pip\_fw\_public | n/a | `string` | `"ib-pip-fw-public"` | no |
| name\_prefix | Prefix to add to all the object names here | `any` | n/a | yes |
| password | VM-Series Password | `any` | n/a | yes |
| resource\_group | The resource group for VM series. | `any` | n/a | yes |
| sep | Seperator | `string` | `"-"` | no |
| subnet-mgmt | Management subnet. | `any` | n/a | yes |
| subnet-private | internal/private subnet resource | `any` | n/a | yes |
| subnet-public | External/public subnet resource | `any` | n/a | yes |
| username | VM-Series Username | `string` | `"panadmin"` | no |
| vm\_count | Count of VM-series of each type (inbound/outbound) to deploy. Min 2 required for production. | `number` | `2` | no |
| vm\_series\_sku | VM-series SKU - list available with az vm image list --publisher paloaltonetworks --all | `string` | `"bundle2"` | no |
| vm\_series\_version | VM-series Software version | `string` | `"9.0.4"` | no |
| vmseries\_size | Default size for VM series | `string` | `"Standard_D5_v2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| inbound-fw-pips | Inbound firewall Public IPs |


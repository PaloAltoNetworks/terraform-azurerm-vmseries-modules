Palo Alto Networks VMSS Module for Azure
===========

A terraform module for VMSS VM-Series firewalls in Azure.

Usage
-----

```hcl
module "vmss" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/vmss"

  location                  = "Australia Central"
  name_prefix               = "pan"
  password                  = "your-password"
  subnet-mgmt               = azurerm_subnet.subnet-mgmt
  subnet-private            = azurerm_subnet.subnet-private
  subnet-public             = module.networks.subnet-public
  bootstrap_storage_account = module.panorama.bootstrap_storage_account
  bootstrap-share-name      = "inboundsharename"
  vhd-container             = "vhd-storage-container-id"
  lb_backend_pool_id        = "private-backend-pool-id"
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
| bootstrap\_share\_name | File share for bootstrap config | `any` | n/a | yes |
| bootstrap\_storage\_account | Storage account setup for bootstrapping | `any` | n/a | yes |
| lb\_backend\_pool\_id | ID Of inbound load balancer backend pool to associate with the VM series firewall | `any` | n/a | yes |
| location | Region to install VM Series Scale sets and dependencies. | `any` | n/a | yes |
| name\_domain\_name\_label | n/a | `string` | `"inbound-vm-mgmt"` | no |
| name\_fw | n/a | `string` | `"inbound-fw"` | no |
| name\_fw\_mgmt\_pip | n/a | `string` | `"inbound-fw-mgmt-pip"` | no |
| name\_mgmt\_nic\_ip | n/a | `string` | `"inbound-nic-fw-mgmt"` | no |
| name\_mgmt\_nic\_profile | n/a | `string` | `"inbound-nic-fw-mgmt-profile"` | no |
| name\_prefix | Prefix to add to all the object names here | `any` | n/a | yes |
| name\_private\_nic\_ip | n/a | `string` | `"inbound-nic-fw-private"` | no |
| name\_private\_nic\_profile | n/a | `string` | `"inbound-nic-fw-private-profile"` | no |
| name\_public\_nic\_ip | n/a | `string` | `"inbound-nic-fw-public"` | no |
| name\_public\_nic\_profile | n/a | `string` | `"inbound-nic-fw-public-profile"` | no |
| name\_rg | n/a | `string` | `"vmseries-rg"` | no |
| name\_scale\_set | n/a | `string` | `"inbound-scaleset"` | no |
| password | Initial administrative password to use for VM-Series. | `string` | n/a | yes |
| sep | Seperator | `string` | `"-"` | no |
| subnet-private | internal/private subnet | `any` | n/a | yes |
| subnet-public | External/public subnet | `any` | n/a | yes |
| subnet\_mgmt | Management subnet. | `any` | n/a | yes |
| username | Initial administrative username to use for VM-Series. | `string` | `"panadmin"` | no |
| vhd-container | Storage container for storing VMSS instance VHDs. | `any` | n/a | yes |
| vm\_count | Minimum instances per scale set. | `number` | `2` | no |
| vm\_series\_sku | VM-series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"bundle2"` | no |
| vm\_series\_version | VM-series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"9.0.4"` | no |
| vm\_size | Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported. | `string` | `"Standard_D3_v2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| inbound-scale-set-name | Name of inbound scale set |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


networking terraform module
===========

A terraform module for deploying standalone (non-scale-set) VM series firewalls in Azure.

Usage
-----

```hcl
module "vm-series" {
  source      = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/standalone-vm-series"
  location    = "Australia Central"
  name_prefix = "panostf"
  password    = "your-password"
  subnet-mgmt    = azurerm_subnet.subnet-mgmt
  subnet-private = azurerm_subnet.subnet-private
  subnet-public  = module.networks.subnet-public
  bootstrap-storage-account     = module.panorama.bootstrap-storage-account
  inbound-bootstrap-share-name  = "inboundsharename"
  outbound-bootstrap-share-name = "outboundsharename"
  vhd-container           = "vhd-storage-container-name"
  private_backend_pool_id = "private-backend-pool-id"
  public_backend_pool_id  = "public-backend-pool-id"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bootstrap-storage-account | Storage account setup for bootstrapping | `any` | n/a | yes |
| inbound-bootstrap-share-name | Azure File share for bootstrap config | `any` | n/a | yes |
| inbound\_lb\_backend\_pool\_id | ID Of inbound load balancer backend pool to associate with the VM series firewall | `string` | `""` | no |
| location | Region to install vm-series and dependencies. | `any` | n/a | yes |
| name\_ib\_az | n/a | `string` | `"ib-vm-az"` | no |
| name\_ib\_fw\_ip\_mgmt | n/a | `string` | `"ib-fw-ip-mgmt"` | no |
| name\_ib\_fw\_ip\_private | n/a | `string` | `"ib-fw-ip-private"` | no |
| name\_ib\_fw\_ip\_public | n/a | `string` | `"ib-fw-ip-public"` | no |
| name\_ib\_nic\_fw\_mgmt | n/a | `string` | `"ib-nic-fw-mgmt"` | no |
| name\_ib\_nic\_fw\_private | n/a | `string` | `"ib-nic-fw-private"` | no |
| name\_ib\_nic\_fw\_public | n/a | `string` | `"ib-nic-fw-public"` | no |
| name\_ib\_pip\_fw\_mgmt | n/a | `string` | `"ib-fw-pip"` | no |
| name\_ib\_pip\_fw\_public | n/a | `string` | `"ib-pip-fw-public"` | no |
| name\_inbound\_fw | n/a | `string` | `"ib-fw"` | no |
| name\_ob\_az | n/a | `string` | `"ob-vm-az"` | no |
| name\_ob\_fw\_ip\_mgmt | n/a | `string` | `"ob-fw-ip-mgmt"` | no |
| name\_ob\_fw\_ip\_private | n/a | `string` | `"ob-fw-ip-private"` | no |
| name\_ob\_fw\_ip\_public | n/a | `string` | `"ob-fw-ip-public"` | no |
| name\_ob\_nic\_fw\_mgmt | n/a | `string` | `"ob-nic-fw-mgmt"` | no |
| name\_ob\_nic\_fw\_private | n/a | `string` | `"ob-nic-fw-private"` | no |
| name\_ob\_nic\_fw\_public | n/a | `string` | `"ob-nic-fw-public"` | no |
| name\_ob\_pip\_fw\_mgmt | n/a | `string` | `"ob-fw-pip"` | no |
| name\_ob\_pip\_fw\_public | n/a | `string` | `"ob-pip-fw-public"` | no |
| name\_outbound\_fw | n/a | `string` | `"ob-fw"` | no |
| name\_prefix | Prefix to add to all the object names here | `any` | n/a | yes |
| outbound-bootstrap-share-name | Azure File share for bootstrap config | `any` | n/a | yes |
| outbound\_lb\_backend\_pool\_id | ID Of outbound load balancer backend pool to associate with the VM series firewall | `string` | `""` | no |
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
| outbound-fw-pips | outbound firewall Public IPs |



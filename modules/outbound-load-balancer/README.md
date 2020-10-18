outbound-load-balancer terraform module
===========

A terraform module for creating all the networking components required for VM series firewalls in Azure.

Usage
-----

```hcl
module "outbound-lb" {
  source           = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/networking"
  location         = "Australia Central"
  name_prefix      = "panostf"
  backend-subnet   = "subnet-id"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| backend-subnet | Subnet to provision the load balancer in, must be the same as the private/internal subnet of VM-series. | `any` | n/a | yes |
| location | Region to install vm-series and dependencies. | `any` | n/a | yes |
| name\_lb | n/a | `string` | `"olb"` | no |
| name\_lb\_backend | n/a | `string` | `"olb-backend"` | no |
| name\_lb\_fip | n/a | `string` | `"olb-fib"` | no |
| name\_lb\_rule | n/a | `string` | `"lbrule-outbound"` | no |
| name\_prefix | Prefix to add to all the object names here | `any` | n/a | yes |
| name\_probe | n/a | `string` | `"olb-probe-80"` | no |
| name\_rg | n/a | `string` | `"olb-rg"` | no |
| private-ip | Private IP address to assign to the frontend of the loadbalancer | `any` | n/a | yes |
| sep | Separator | `string` | `"-"` | no |

## Outputs

| Name | Description |
|------|-------------|
| backend-pool-id | ID of outbound load balancer backend address pool. |
| frontend-ip-configs | IP configuration resources from outbound load balancers. |

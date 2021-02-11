Palo Alto Networks Outbound-Load-Balancer Module for Azure
===========

A terraform module for deploying an Outbound-Load-Balancer required for VM-Series firewalls in Azure.

Usage
-----

```hcl
module "outbound-lb" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/networking"

  location         = "Australia Central"
  name_prefix      = "pan"
  backend-subnet   = "subnet-id"
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
| backend-subnet | ID of Subnet to provision the load balancer in, must be the same as the private/internal subnet of VM-series. | `any` | n/a | yes |
| location | Region to deploy all load balancer resources. | `string` | n/a | yes |
| name\_lb | n/a | `string` | `"olb"` | no |
| name\_lb\_backend | n/a | `string` | `"olb-backend"` | no |
| name\_lb\_fip | n/a | `string` | `"olb-fib"` | no |
| name\_lb\_rule | n/a | `string` | `"lbrule-outbound"` | no |
| name\_prefix | Prefix to add to all the object names here | `string` | n/a | yes |
| name\_probe | n/a | `string` | `"olb-probe-80"` | no |
| private-ip | Private IP address to assign to the frontend of the loadbalancer | `string` | `"10.110.0.21"` | no |
| resource\_group\_name | Name of the Resource Group to use. | `string` | n/a | yes |
| sep | Separator | `string` | `"-"` | no |

## Outputs

| Name | Description |
|------|-------------|
| backend-pool-id | ID of outbound load balancer backend address pool. |
| frontend-ip-configs | IP configuration resources from outbound load balancers. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

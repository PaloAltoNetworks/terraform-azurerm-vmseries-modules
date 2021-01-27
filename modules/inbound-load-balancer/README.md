# Palo Alto Networks Inbound Load Balancer Module for Azure

A terraform module for deploying an Inbound Load Balancer for VM-Series firewalls. Supports both standalone and scaleset deployments.

## Usage

```hcl
# Deploy the inbound load balancer for traffic into the azure environment
module "inbound-lb" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/inbound-load-balancer"

  location    = "Australia Central"
  name_prefix = "panostf"
  rules       = {
                  "myssh" = {
                    protocol = "Tcp"
                    port     = 22
                  }
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
| location | Region to deploy load balancer and dependencies. | `any` | n/a | yes |
| name\_backend | n/a | `string` | `"lb-backend"` | no |
| name\_lb | n/a | `string` | `"lb"` | no |
| name\_prefix | Prefix to add to all the object names here | `any` | n/a | yes |
| name\_probe | n/a | `string` | `"lb-probe"` | no |
| name\_rg | n/a | `string` | `"lb-rg"` | no |
| rules | A map of inbound LB rules. Useful for testing. | `map` | <pre>{<br>  "default80": {<br>    "port": 80,<br>    "protocol": "Tcp"<br>  }<br>}</pre> | no |
| sep | Seperator | `string` | `"-"` | no |

## Outputs

| Name | Description |
|------|-------------|
| backend-pool-id | The ID of the backend pool. |
| frontend-ip-configs | IP config resources of the load balancer. |
| pip-ips | All PIPs associated with the inbound load balancer. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

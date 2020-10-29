inbound-load-balancer terraform module
===========

A terraform module for creating an Inbound Load Balancer for use with PANOS VM series. Supports both standalone and  
scaleset deployments.

Usage
-----

```hcl
# Deploy the inbound load balancer for traffic into the azure environment
module "inbound-lb" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/inbound-load-balancer"

  location    = "Australia Central"
  name_prefix = "panostf"
  rules       = [{
                  port      = 80
                  name      = "testweb"
                  protocol  = "Tcp"
                  },
                  {
                    port      = 22
                    name      = "testssh"
                    protocol  = "Tcp"
                }]
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
| location | Region to deploy load balancer and dependencies. | `any` | n/a | yes |
| name\_backend | n/a | `string` | `"lb-backend"` | no |
| name\_lb | n/a | `string` | `"lb"` | no |
| name\_lbrule | n/a | `string` | `"lbrule"` | no |
| name\_prefix | Prefix to add to all the object names here | `any` | n/a | yes |
| name\_probe | n/a | `string` | `"lb-probe"` | no |
| name\_rg | n/a | `string` | `"lb-rg"` | no |
| rules | A list[objects] of ports and names that will be assigned to inbound LB rules. Useful for testing. | <pre>list(object({<br>    port = number<br>    name = string<br>    protocol = string<br>  }))</pre> | <pre>[<br>  {<br>    "name": "default-rule",<br>    "port": 80,<br>    "protocol": "Tcp"<br>  }<br>]</pre> | no |
| sep | Seperator | `string` | `"-"` | no |

## Outputs

| Name | Description |
|------|-------------|
| backend-pool-id | The ID of the backend pool. |
| frontend-ip-configs | IP config resources of the load balancer. |
| pip-ips | All PIPs associated with the inbound load balancer. |


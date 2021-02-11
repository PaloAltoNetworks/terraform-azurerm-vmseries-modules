# Palo Alto Networks Inbound Load Balancer Module for Azure

A terraform module for deploying an Inbound Load Balancer for VM-Series firewalls. Supports both standalone and scaleset deployments.

## Usage

```hcl
# Deploy the inbound load balancer for traffic into the azure environment
module "inbound-lb" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/inbound-load-balancer"

  location            = "Australia Central"
  resource_group_name = "some-rg"
  name_prefix         = "pan"
  frontend_ips = {
    "frontend01" = {
      create_public_ip = true
      rules = {
        "balancessh" = {
          protocol = "Tcp"
          port     = 22
        }
      }
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
| frontend\_ips | A map of objects describing LB Frontend IP configurations. Keys of the map are the names and values are { create\_public\_ip, public\_ip\_address\_id, rules }. Example:<pre>{<br>  "pip-existing" = {<br>    create_public_ip     = false<br>    public_ip_address_id = azurerm_public_ip.this.id<br>    rules = {<br>      "balancessh" = {<br>        protocol = "Tcp"<br>        port     = 22<br>      }<br>      "balancehttp" = {<br>        protocol = "Tcp"<br>        port     = 80<br>      }<br>    }<br>  }<br>  "pip-created" = {<br>    create_public_ip = true<br>    rules = {<br>      "balancessh" = {<br>        protocol = "Tcp"<br>        port     = 22<br>      }<br>      "balancehttp" = {<br>        protocol = "Tcp"<br>        port     = 80<br>      }<br>    }<br>  }<br>}</pre> | `any` | n/a | yes |
| location | Region to deploy load balancer and dependencies. | `string` | n/a | yes |
| name\_backend | n/a | `string` | `"lb-backend"` | no |
| name\_lb | n/a | `string` | `"lb"` | no |
| name\_prefix | Prefix to add to all the object names here | `string` | n/a | yes |
| name\_probe | n/a | `string` | `"lb-probe"` | no |
| resource\_group\_name | Name of the Resource Group to use. | `string` | n/a | yes |
| sep | Seperator | `string` | `"-"` | no |

## Outputs

| Name | Description |
|------|-------------|
| backend-pool-id | The ID of the backend pool. |
| frontend-ip-configs | IP config resources of the load balancer. |
| pip-ips | All PIPs associated with the inbound load balancer. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

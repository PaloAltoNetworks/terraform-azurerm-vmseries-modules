# Palo Alto Networks Inbound Load Balancer Module for Azure

A terraform module for deploying an Inbound Load Balancer for VM-Series firewalls. Supports both standalone and scaleset deployments.

## Usage

```hcl
# Deploy the inbound load balancer for traffic into the azure environment
module "inbound-lb" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/inbound-load-balancer"

  location     = "Australia Central"
  name_prefix  = "pan"
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.12.29, <0.14 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=2.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=2.26.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_lb.lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.lb-backend](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_probe.probe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.lb-rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.rg-lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_frontend_ips"></a> [frontend\_ips](#input\_frontend\_ips) | A map of objects describing LB Frontend IP configurations. Keys of the map are the names and values are { create\_public\_ip, public\_ip\_address\_id, rules }. Example:<pre>{<br>  "pip-existing" = {<br>    create_public_ip     = false<br>    public_ip_address_id = azurerm_public_ip.this.id<br>    rules = {<br>      "balancessh" = {<br>        protocol = "Tcp"<br>        port     = 22<br>      }<br>      "balancehttp" = {<br>        protocol = "Tcp"<br>        port     = 80<br>      }<br>    }<br>  }<br>  "pip-created" = {<br>    create_public_ip = true<br>    rules = {<br>      "balancessh" = {<br>        protocol = "Tcp"<br>        port     = 22<br>      }<br>      "balancehttp" = {<br>        protocol = "Tcp"<br>        port     = 80<br>      }<br>    }<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region to deploy load balancer and dependencies. | `any` | n/a | yes |
| <a name="input_name_backend"></a> [name\_backend](#input\_name\_backend) | n/a | `string` | `"lb-backend"` | no |
| <a name="input_name_lb"></a> [name\_lb](#input\_name\_lb) | n/a | `string` | `"lb"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to add to all the object names here | `any` | n/a | yes |
| <a name="input_name_probe"></a> [name\_probe](#input\_name\_probe) | n/a | `string` | `"lb-probe"` | no |
| <a name="input_name_rg"></a> [name\_rg](#input\_name\_rg) | n/a | `string` | `"lb-rg"` | no |
| <a name="input_sep"></a> [sep](#input\_sep) | Seperator | `string` | `"-"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend-pool-id"></a> [backend-pool-id](#output\_backend-pool-id) | The ID of the backend pool. |
| <a name="output_frontend-ip-configs"></a> [frontend-ip-configs](#output\_frontend-ip-configs) | IP config resources of the load balancer. |
| <a name="output_pip-ips"></a> [pip-ips](#output\_pip-ips) | All PIPs associated with the inbound load balancer. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

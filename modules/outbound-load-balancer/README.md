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
| [azurerm_resource_group.rg-lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend-subnet"></a> [backend-subnet](#input\_backend-subnet) | ID of Subnet to provision the load balancer in, must be the same as the private/internal subnet of VM-series. | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region to deploy all load balancer resources. | `any` | n/a | yes |
| <a name="input_name_lb"></a> [name\_lb](#input\_name\_lb) | n/a | `string` | `"olb"` | no |
| <a name="input_name_lb_backend"></a> [name\_lb\_backend](#input\_name\_lb\_backend) | n/a | `string` | `"olb-backend"` | no |
| <a name="input_name_lb_fip"></a> [name\_lb\_fip](#input\_name\_lb\_fip) | n/a | `string` | `"olb-fib"` | no |
| <a name="input_name_lb_rule"></a> [name\_lb\_rule](#input\_name\_lb\_rule) | n/a | `string` | `"lbrule-outbound"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to add to all the object names here | `any` | n/a | yes |
| <a name="input_name_probe"></a> [name\_probe](#input\_name\_probe) | n/a | `string` | `"olb-probe-80"` | no |
| <a name="input_name_rg"></a> [name\_rg](#input\_name\_rg) | n/a | `string` | `"olb-rg"` | no |
| <a name="input_private-ip"></a> [private-ip](#input\_private-ip) | Private IP address to assign to the frontend of the loadbalancer | `string` | `"10.110.0.21"` | no |
| <a name="input_sep"></a> [sep](#input\_sep) | Separator | `string` | `"-"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend-pool-id"></a> [backend-pool-id](#output\_backend-pool-id) | ID of outbound load balancer backend address pool. |
| <a name="output_frontend-ip-configs"></a> [frontend-ip-configs](#output\_frontend-ip-configs) | IP configuration resources from outbound load balancers. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

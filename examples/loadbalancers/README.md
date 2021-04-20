# Palo Alto Networks Inbound/Outbound Load Balancer Module Example

This folder shows an example of Terraform code that helps to deploy an Inbound/Outbound Load Balancer for the VM-Series firewall in Azure.

## Usage

Create a `terraform.tfvars` file and copy the content of `example.tfvars` into it, adjust if needed.

```bash
$ terraform init
$ terraform apply
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13, <0.14 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>2.42 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_private_lb"></a> [private\_lb](#module\_private\_lb) | ../../modules/loadbalancer |  |
| <a name="module_public_lb"></a> [public\_lb](#module\_public\_lb) | ../../modules/loadbalancer |  |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Region to deploy load balancer and dependencies. | `string` | `""` | no |
| <a name="input_name_lb"></a> [name\_lb](#input\_name\_lb) | The loadbalancer name. | `string` | n/a | yes |
| <a name="input_name_probe"></a> [name\_probe](#input\_name\_probe) | The loadbalancer probe name. | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to create. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_backend_pool_ids"></a> [private\_backend\_pool\_ids](#output\_private\_backend\_pool\_ids) | The ID of the private backend pools. |
| <a name="output_private_frontend_ip_configs"></a> [private\_frontend\_ip\_configs](#output\_private\_frontend\_ip\_configs) | The IP addresses of the frontends of the private Load Balancer. |
| <a name="output_public_backend_pool_ids"></a> [public\_backend\_pool\_ids](#output\_public\_backend\_pool\_ids) | The ID of the backend public pools. |
| <a name="output_public_frontend_ip_configs"></a> [public\_frontend\_ip\_configs](#output\_public\_frontend\_ip\_configs) | The IP addresses of the frontends of the public Load Balancer. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
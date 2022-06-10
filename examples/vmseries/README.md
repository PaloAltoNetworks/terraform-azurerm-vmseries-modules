# Example of `vmseries` Terraform Module on Azure Cloud

The is a very minimal example of the `vmseries` module. It lacks any traffic inspection.
It creates a single VM-Series with a management-only interface. It can be usable for familiarizing
oneself with terraform, as well as a bed for creating a custom pan-os image.

To see a full VM-Series module usage, see the example from the directory [../transit_vnet_common](../transit_vnet_common). It deploys one of the VM-Series Reference Architectures in its entirety, including load balancing.

## Usage

Create a `terraform.tfvars` file and copy the content of `example.tfvars` into it, adjust if needed.

Then execute:

```sh
terraform init
terraform apply
terraform ouput -json password
```

Having the `username`, `password`, and `mgmt_ip_addresses`, use them to connect through ssh:

```sh
ssh <username>@<mgmt_ip_addresses>
```

## Cleanup

To delete all the resources created by the previous `apply` attempts, execute:

```sh
terraform destroy
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.29, < 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | = 2.64 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | = 2.64 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vmseries"></a> [vmseries](#module\_vmseries) | ../../modules/vmseries | n/a |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | ../../modules/vnet | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/2.64/docs/resources/resource_group) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_inbound_mgmt_ips"></a> [allow\_inbound\_mgmt\_ips](#input\_allow\_inbound\_mgmt\_ips) | List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access management interfaces of VM-Series.<br>If you use Panorama, include its address in the list (as well as the secondary Panorama's). | `list(string)` | n/a | yes |
| <a name="input_common_vmseries_sku"></a> [common\_vmseries\_sku](#input\_common\_vmseries\_sku) | VM-Series SKU, for example `bundle1`, or `bundle2`. If it is `byol`, the VM-Series starts unlicensed. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to use. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to create. | `string` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | Initial administrative username. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-username-requirements-when-creating-a-vm). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mgmt_ip_addresses"></a> [mgmt\_ip\_addresses](#output\_mgmt\_ip\_addresses) | IP Addresses for VM-Series management (https or ssh). |
| <a name="output_password"></a> [password](#output\_password) | Initial administrative password to use for VM-Series. |
| <a name="output_username"></a> [username](#output\_username) | Initial administrative username to use for VM-Series. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

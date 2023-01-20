# Palo Alto Networks Transit VNet Common Example

This folder shows an example of Terraform code that helps to deploy a [Transit VNet design model](https://www.paloaltonetworks.com/resources/guides/azure-transit-vnet-deployment-guide-common-firewall-option) (common firewall option) with a VM-Series firewall on Microsoft Azure.

## NOTICE

This example contains some files that can contain sensitive data, namely `authcodes.sample` and `init-cfg.sample.txt`. Keep in mind that these files are here only as an example. Normally one should avoid placing them in a repository.

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13, < 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | ../../modules/loadbalancer | n/a |
| <a name="module_vmseries"></a> [vmseries](#module\_vmseries) | ../../modules/vmseries | n/a |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | ../../modules/vnet | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space used by the virtual network. You can supply more than one address space. | `list(string)` | n/a | yes |
| <a name="input_enable_zones"></a> [enable\_zones](#input\_enable\_zones) | If `true`, enable zone support for resources. | `bool` | `true` | no |
| <a name="input_load_balancers"></a> [load\_balancers](#input\_load\_balancers) | A map containing configuration for all (private and public) Load Balancer that will be created in this deployment.<br><br>Key is the name of the Load Balancer as it will be available in Azure. This name is also used to reference the Load Balancer further in the code.<br>Value is an object containing following properties:<br><br>- `network_security_group_name`: (public LB) a name of a security group created with the `vnet_security` module, an ingress rule will be created in that NSG for each listener. <br>- `network_security_allow_source_ips`: (public LB) a list of IP addresses that will used in the ingress rules.<br>- `frontend_ips`: (both) a map configuring both a listener and a load balancing rule, key is the name that will be used as an application name inside LB config as well as to create a rule in NSG (for public LBs), value is an object with the following properties:<br>  - `create_public_ip`: (public LB) defaults to `false`, when set to `true` a Public IP will be created and associated with a listener<br>  - `public_ip_name`: (public LB) defaults to `null`, when `create_public_ip` is set to `false` this property is used to reference an existing Public IP object in Azure<br>  - `public_ip_resource_group`: (public LB) defaults to `null`, when using an existing Public IP created in a different Resource Group than the currently used use this property is to provide the name of that RG<br>  - `private_ip_address`: (private LB) defaults to `null`, specify a static IP address that will be used by a listener<br>  - `subnet_name`: (private LB) defaults to `null`, when `private_ip_address` is set specifies a subnet to which the LB will be attached, in case of VMSeries this should be a internal/trust subnet<br>  - `zones` - defaults to `null`, specify in which zones you want to create frontend IP address. Pass list with zone coverage, ie: `["1","2","3"]`<br>  - `rules` - a map configuring the actual rules load balancing rules, a key is a rule name, a value is an object with the following properties:<br>    - `protocol`: protocol used by the rule, can be one the following: `TCP`, `UDP` or `All` when creating an HA PORTS rule<br>    - `port`: port used by the rule, for HA PORTS rule set this to `0`<br><br>Example of a public Load Balancer:<pre>"public_https_app" = {<br>  network_security_group_name = "untrust_nsg"<br>  network_security_allow_source_ips = [ "1.2.3.4" ]<br>  frontend_ips = {<br>    "https_app_1" = {<br>      create_public_ip = true<br>      rules = {<br>        "balanceHttps" = {<br>          protocol = "Tcp"<br>          port     = 443<br>        }<br>      }<br>    }<br>  }<br>}</pre>Example of a private Load Balancer with HA PORTS rule:<pre>"ha_ports" = {<br>  frontend_ips = {<br>    "ha-ports" = {<br>      subnet_name        = "trust_snet"<br>      private_ip_address = "10.0.0.1"<br>      rules = {<br>        HA_PORTS = {<br>          port     = 0<br>          protocol = "All"<br>        }<br>      }<br>    }<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to use. | `string` | `"East US 2"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix for all the names of the created Azure objects. It can end with a dash `-` character, if your naming convention prefers such separator. | `string` | `"example-"` | no |
| <a name="input_network_security_groups"></a> [network\_security\_groups](#input\_network\_security\_groups) | Definition of Network Security Groups to create. Refer to the `vnet` module documentation for more information. | `any` | `{}` | no |
| <a name="input_password"></a> [password](#input\_password) | Initial administrative password to use for all systems. Set to null for an auto-generated password. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to create. If not provided, it will be auto-generated. | `string` | `"transit-vnet-common"` | no |
| <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables) | Definition of Route Tables to create. Refer to the `vnet` module documentation for more information. | `any` | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Definition of Subnets to create. Refer to the `vnet` module documentation for more information. | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the created resources. | `map(string)` | <pre>{<br>  "CreatedBy": "Palo Alto Networks",<br>  "CreatedWith": "Terraform"<br>}</pre> | no |
| <a name="input_username"></a> [username](#input\_username) | Initial administrative username to use for all systems. | `string` | `"panadmin"` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the VNet to create. | `string` | n/a | yes |
| <a name="input_vmseries"></a> [vmseries](#input\_vmseries) | Map of virtual machines to create to run VM-Series - inbound firewalls. Keys are the individual names, values<br>are objects containing attributes unique to that individual virtual machine:<br><br>- `avzone`: the Azure Availability Zone identifier ("1", "2", "3"). Default is "1" in order to avoid non-HA deployments.<br>- `availability_set_name` : a name of an Availability Set as declared in `availability_set` property. Specify when HA is required but cannot go for zonal deployment.<br>- `bootstrap_options`: Bootstrap options to pass to VM-Series instances, semicolon separated values.<br>- `add_to_appgw_backend` : bool, `false` by default, set this to `true` to add this backend to an Application Gateway.<br><br>- `interfaces`: a list containing configuration of all NICs assigned to a VM. Order is important as the interfaces are assigned to a VM in the order specified in this list. The management interface should be the first one. Following properties are available:<br>  - `name`: (string) a name of an interface<br>  - `subnet_name`: (string) a name of a subnet as created in using `vnet_security` module<br>  - `create_pip`: (boolean) flag to create Public IP for an interface, defaults to `false`<br>  - `backend_pool_lb_name`: (string) name of a Load Balancer created with the `loadbalancer` module to which a VM should be assigned, defaults to `null`<br>  - `private_ip_address`: (string) a static IP address that should be assigned to an interface, defaults to `null` (in that case DHCP is used)<br><br>Example:<pre>{<br>  "fw00" = {<br>    bootstrap_options = "type=dhcp-client"<br>    avzone = 1<br>    interfaces = {<br>      mgmt = {<br>        subnet_name        = "mgmt"<br>        create_pip         = true<br>        private_ip_address = "10.0.0.1"<br>      }<br>      trust = {<br>        subnet_name          = "trust"<br>        private_ip_address   = "10.0.1.1"<br>        backend_pool_lb_name = "private_lb"<br>      }<br>    }<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_vmseries_sku"></a> [vmseries\_sku](#input\_vmseries\_sku) | VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | n/a | yes |
| <a name="input_vmseries_version"></a> [vmseries\_version](#input\_vmseries\_version) | VM-Series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | n/a | yes |
| <a name="input_vmseries_vm_size"></a> [vmseries\_vm\_size](#input\_vmseries\_vm\_size) | Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_frontend_ips"></a> [frontend\_ips](#output\_frontend\_ips) | IP Addresses of the load balancers. |
| <a name="output_mgmt_ip_addresses"></a> [mgmt\_ip\_addresses](#output\_mgmt\_ip\_addresses) | IP Addresses for VM-Series management (https or ssh). |
| <a name="output_password"></a> [password](#output\_password) | Initial administrative password to use for VM-Series. |
| <a name="output_username"></a> [username](#output\_username) | Initial administrative username to use for VM-Series. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

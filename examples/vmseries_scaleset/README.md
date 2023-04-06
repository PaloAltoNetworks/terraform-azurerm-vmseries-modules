# Palo Alto Networks VM-Series Scaleset Module Example

Virtual Machine Scale Sets (VMSS) is a group of individual virtual machines (VMs) within the Microsoft Azure public cloud that administrators can configure and manage as a single unit.

This folder shows an example of Terraform code that deploys an auto-scaling set of VM-Series firewalls using Azure VMSS. The templates provided for auto scaling create and manage a group of identical, load-balanced VM-Series VMs that are scaled up or down based on custom metrics published by the firewalls to Azure Application Insights. The scaling-in and scaling-out operations are based on configurable thresholds.

This is not a complete autoscaling solution, the missing part is de-licensing, intended to be achieved either by:

- Panorama's plugin `azure` v2.0.3. (The v3 is incompatible.)
- Panorama's plugin `sw_fw_license` v1. (See the [documentation](https://docs-new.paloaltonetworks.com/vm-series/10-1/vm-series-deployment/license-the-vm-series-firewall/use-panorama-based-software-firewall-license-management.html).)

## NOTICE

This example contains some files that can contain sensitive data, namely `authcodes.sample` and `init-cfg.sample.txt`. Keep in mind that these files are here only as an example. Normally one should avoid placing them in a repository.

## Usage

1. Create a `terraform.tfvars` file and copy the content of `example.tfvars` into it, adjust if needed.

1. Create an `inbound_files/init-cfg.txt` file and copy the content of `inbound_files/init-cfg.sample.txt` into it, adjusting it. (Do not commit the file to any remote repository if it contains secrets such as vm-auth-key.)

1. Similarly, create an `outbound_files/init-cfg.txt`.

1. If you are using bring-your-own-license (BYOL) variant:

    - similarly create an `inbound_files/authcodes` and `outbound_files/authcodes`,
    - prepare a compatible licensing API key on Panorama (if it does not match, you will not be able to reclaim your authcodes after scale-in reduces the number of VM-Series).

1. Use terraform from the same directory as this README.md file:

    ```sh
    terraform init
    terraform apply
    terraform output -json
    ```

1. Using the outputs, on your Panorama UI or VM-Series UI configure DNAT for inbound traffic.

## Custom Metrics

Firewalls can publish custom metrics (for example `panSessionUtilization`) to Azure Application Insights to improve the autoscaling.
This however requires manual initialization: copy the output `metrics_instrumentation_key_inbound` and paste it into your
PAN-OS webUI -> Device -> VM-Series -> Azure -> Instrumentation Key with interval of 1 minute. Same for the output `metrics_instrumentation_key_outbound`. This module solely
completes the Step 1 of the [official procedure](https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/set-up-the-vm-series-firewall-on-azure/enable-azure-application-insights-on-the-vm-series-firewall.html).

If you manage the configuration from Panorama, this can be done in the same place, however the PAN-OS `VM-Series plugin` needs to be installed **on both** Panorama and VM-Series.

The metrics gathered within a single Azure Application Insights instance provided by the module, cannot be split to obtain
back a result for solely a single firewall. Thus for example if three firewalls use the same Instrumentation Key and report
their respective session utilizations as 90%, 20%, 10%, it is possible to see in Azure the average of 40%, the sum of 120%, the max of 90%, but it is *not possible* to know which of the firewalls reported the 90% utilization.

## Panorama Sharing Consideration

Panorama's plugin `azure` v2 has certain limitations:

- One Azure Service Principal per one Azure Subscription only. If you only have a single Subscription and you need another Service Principal, use another Panorama (or another Panorama pair).
- One Azure Resource Group per one Panorama Device Group and vice versa. This is why this example uses two RGs, because inbound and outbound are in different Panorama Device Groups.

Create Azure Service Principal [manually](https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/set-up-the-vm-series-firewall-on-azure/about-the-vm-series-firewall-on-azure/vm-series-on-azure-service-principal-permissions.html#idd6bb5037-de5b-4769-aaa8-e2b08a103c5f).

To avoid logging excessive plugin errors, supply your own Azure Service Bus and RootManageSharedAccessKey on your Panorama UI -> Plugins -> Azure.

## Cleanup

Execute:

```sh
terraform destroy
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1, < 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ai"></a> [ai](#module\_ai) | ../../modules/application_insights | n/a |
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | ../../modules/loadbalancer | n/a |
| <a name="module_natgw"></a> [natgw](#module\_natgw) | ../../modules/natgw | n/a |
| <a name="module_vmss"></a> [vmss](#module\_vmss) | ../../modules/vmss | n/a |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | ../../modules/vnet | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_insights"></a> [application\_insights](#input\_application\_insights) | A map defining Azure Application Insights. There are three ways to use this variable:<br><br>* when the value is set to `null` (default) no AI is created<br>* when the value is a map containing `name` key (other keys are optional) a single AI instance will be created under the name that is the value of the `name` key<br>* when the value is an empty map or a map w/o the `name` key, an AI instance per each VMSeries VM will be created. All instances will share the same configuration. All instances will have names corresponding to their VM name.<br><br>Names for all AI instances are prefixed with `var.name_prefix`.<br><br>Properties supported (for details on each property see [modules documentation](../modules/application\_insights/README.md)):<br><br>- `name` : (optional, string) a name of a single AI instance<br>- `workspace_mode` : (optional, bool) defaults to `true`, use AI Workspace mode instead of the Classical (deprecated)<br>- `workspace_name` : (optional, string) defaults to AI name suffixed with `-wrkspc`, name of the Log Analytics Workspace created when AI is deployed in Workspace mode<br>- `workspace_sku` : (optional, string) defaults to PerGB2018, SKU used by WAL, see module documentation for details<br>- `metrics_retention_in_days` : (optional, number) defaults to current Azure default value, see module documentation for details<br><br>Example of an AIs created per VM, in Workspace mode, with metrics retention set to 1 year:<pre>vmseries = {<br>  'vm-1' = {<br>    ....<br>  }<br>  'vm-2' = {<br>    ....<br>  }<br>}<br><br>application_insights = {<br>  metrics_retention_in_days = 365<br>}</pre> | `map(string)` | `null` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | When set to `true` it will cause a Resource Group creation. Name of the newly specified RG is controlled by `resource_group_name`.<br>When set to `false` the `resource_group_name` parameter is used to specify a name of an existing Resource Group. | `bool` | `true` | no |
| <a name="input_enable_zones"></a> [enable\_zones](#input\_enable\_zones) | If `true`, enable zone support for resources. | `bool` | `true` | no |
| <a name="input_load_balancers"></a> [load\_balancers](#input\_load\_balancers) | A map containing configuration for all (private and public) Load Balancer that will be created in this deployment.<br><br>Following properties are available (for details refer to module's documentation):<br><br>- `name`: name of the Load Balancer resource.<br>- `network_security_group_name`: (public LB) a name of a security group, an ingress rule will be created in that NSG for each listener. **NOTE** this is the FULL NAME of the NSG (including prefixes).<br>- `network_security_group_rg_name`: (public LB) a name of a resource group for the security group, to be used when the NSG is hosted in a different RG than the one described in `var.resource_group_name`.<br>- `network_security_allow_source_ips`: (public LB) a list of IP addresses that will used in the ingress rules.<br>- `avzones`: (both) for regional Load Balancers, a list of supported zones (this has different meaning for public and private LBs - please refer to module's documentation for details).<br>- `frontend_ips`: (both) a map configuring both a listener and a load balancing rule, key is the name that will be used as an application name inside LB config as well as to create a rule in NSG (for public LBs), value is an object with the following properties:<br>  - `create_public_ip`: (public LB) defaults to `false`, when set to `true` a Public IP will be created and associated with a listener<br>  - `public_ip_name`: (public LB) defaults to `null`, when `create_public_ip` is set to `false` this property is used to reference an existing Public IP object in Azure<br>  - `public_ip_resource_group`: (public LB) defaults to `null`, when using an existing Public IP created in a different Resource Group than the currently used use this property is to provide the name of that RG<br>  - `private_ip_address`: (private LB) defaults to `null`, specify a static IP address that will be used by a listener<br>  - `subnet_name`: (private LB) defaults to `null`, when `private_ip_address` is set specifies a subnet to which the LB will be attached, in case of VMSeries this should be a internal/trust subnet<br>  - `rules` - a map configuring the actual rules load balancing rules, a key is a rule name, a value is an object with the following properties:<br>    - `protocol`: protocol used by the rule, can be one the following: `TCP`, `UDP` or `All` when creating an HA PORTS rule<br>    - `port`: port used by the rule, for HA PORTS rule set this to `0`<br><br>Example of a public Load Balancer:<pre>"public_lb" = {<br>  name                              = "https_app_lb"<br>  network_security_group_name       = "untrust_nsg"<br>  network_security_allow_source_ips = ["1.2.3.4"]<br>  avzones                           = ["1", "2", "3"]<br>  frontend_ips = {<br>    "https_app_1" = {<br>      create_public_ip = true<br>      rules = {<br>        "balanceHttps" = {<br>          protocol = "Tcp"<br>          port     = 443<br>        }<br>      }<br>    }<br>  }<br>}</pre>Example of a private Load Balancer with HA PORTS rule:<pre>"private_lb" = {<br>  name = "ha_ports_internal_lb<br>  frontend_ips = {<br>    "ha-ports" = {<br>      vnet_name          = "trust_vnet"<br>      subnet_name        = "trust_snet"<br>      private_ip_address = "10.0.0.1"<br>      rules = {<br>        HA_PORTS = {<br>          port     = 0<br>          protocol = "All"<br>        }<br>      }<br>    }<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to use. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix that will be added to all created resources.<br>There is no default delimiter applied between the prefix and the resource name. Please include the delimiter in the actual prefix.<br><br>Example:<pre>name_prefix = "test-"</pre>NOTICE. This prefix is not applied to existing resources. If you plan to reuse i.e. a VNET please specify it's full name, even if it is also prefixed with the same value as the one in this property. | `string` | `""` | no |
| <a name="input_natgws"></a> [natgws](#input\_natgws) | A map defining Nat Gateways. <br><br>Please note that a NatGW is a zonal resource, this means it's always placed in a zone (even when you do not specify one explicitly). Please refer to Microsoft documentation for notes on NatGW's zonal resiliency. <br><br>Following properties are supported:<br><br>- `name` : a name of the newly created NatGW.<br>- `create_natgw` : (default: `true`) create or source (when `false`) an existing NatGW. Created or sourced: the NatGW will be assigned to a subnet created by the `vnet` module.<br>- `resource_group_name : name of a Resource Group hosting the NatGW (newly create or the existing one).<br>- `zone` : Availability Zone in which the NatGW will be placed, when skipped AzureRM will pick a zone.<br>- `idle\_timeout` : connection IDLE timeout in minutes, for newly created resources<br>- `vnet\_name` : a name (key value) of a VNET defined in `var.vnets` that hosts a subnet this NatGW will be assigned to.<br>- `subnet\_names` : a list of subnets (key values) the NatGW will be assigned to, defined in `var.vnets` for a VNET described by `vnet\_name`.<br>- `create\_pip` : (default: `true`) create a Public IP that will be attached to a NatGW<br>- `existing\_pip\_name` : when `create\_pip` is set to `false`, source and attach and existing Public IP to the NatGW<br>- `existing\_pip\_resource\_group\_name` : when `create\_pip` is set to `false`, name of the Resource Group hosting the existing Public IP<br>- `create\_pip\_prefix` : (default: `false`) create a Public IP Prefix that will be attached to the NatGW.<br>- `pip\_prefix\_length` : length of the newly created Public IP Prefix, can bet between 0 and 31 but this actually supported value depends on the Subscription.<br>- `existing\_pip\_prefix\_name` : when `create\_pip\_prefix` is set to `false`, source and attach and existing Public IP Prefix to the NatGW<br>- `existing\_pip\_prefix\_resource\_group\_name` : when `create\_pip\_prefix` is set to `false`, name of the Resource Group hosting the existing Public IP Prefix.<br><br>Example:<br>`<pre>natgws = {<br>  "natgw" = {<br>    name         = "public-natgw"<br>    vnet_name    = "transit-vnet"<br>    subnet_names = ["public"]<br>    zone         = 1<br>  }<br>}</pre> | `any` | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the created resources. | `map(string)` | `{}` | no |
| <a name="input_vmseries_password"></a> [vmseries\_password](#input\_vmseries\_password) | Initial administrative password to use for all systems. Set to null for an auto-generated password. | `string` | `null` | no |
| <a name="input_vmseries_sku"></a> [vmseries\_sku](#input\_vmseries\_sku) | VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"byol"` | no |
| <a name="input_vmseries_username"></a> [vmseries\_username](#input\_vmseries\_username) | Initial administrative username to use for all systems. | `string` | `"panadmin"` | no |
| <a name="input_vmseries_version"></a> [vmseries\_version](#input\_vmseries\_version) | VM-Series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | n/a | yes |
| <a name="input_vmseries_vm_size"></a> [vmseries\_vm\_size](#input\_vmseries\_vm\_size) | Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported. | `string` | n/a | yes |
| <a name="input_vmss"></a> [vmss](#input\_vmss) | n/a | `any` | `{}` | no |
| <a name="input_vnets"></a> [vnets](#input\_vnets) | A map defining VNETs.<br><br>For detailed documentation on each property refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/blob/v0.5.4/modules/vnet/README.md)<br><br>- `name` :  A name of a VNET.<br>- `create_virtual_network` : (default: `true`) when set to `true` will create a VNET, `false` will source an existing VNET, in both cases the name of the VNET is specified with `virtual_network_name`<br>- `address_space` : a list of CIDRs for VNET<br>- `resource_group_name` :  (default: current RG) a name of a Resource Group in which the VNET will reside<br><br>- `create_subnets` : (default: `true`) if true, create the Subnets inside the Virtual Network, otherwise use pre-existing subnets<br>- `subnets` : map of Subnets to create<br><br>- `network_security_groups` : map of Network Security Groups to create<br>- `route_tables` : map of Route Tables to create. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_frontend_ips"></a> [frontend\_ips](#output\_frontend\_ips) | IP Addresses of the load balancers. |
| <a name="output_metrics_instrumentation_keys"></a> [metrics\_instrumentation\_keys](#output\_metrics\_instrumentation\_keys) | The Instrumentation Key of the created instance(s) of Azure Application Insights. |
| <a name="output_password"></a> [password](#output\_password) | Initial administrative password to use for VM-Series. |
| <a name="output_username"></a> [username](#output\_username) | Initial administrative username to use for VM-Series. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

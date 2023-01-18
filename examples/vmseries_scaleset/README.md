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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.29, < 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_inbound_bootstrap"></a> [inbound\_bootstrap](#module\_inbound\_bootstrap) | ../../modules/bootstrap | n/a |
| <a name="module_inbound_lb"></a> [inbound\_lb](#module\_inbound\_lb) | ../../modules/loadbalancer | n/a |
| <a name="module_inbound_scale_set"></a> [inbound\_scale\_set](#module\_inbound\_scale\_set) | ../../modules/vmss | n/a |
| <a name="module_outbound_bootstrap"></a> [outbound\_bootstrap](#module\_outbound\_bootstrap) | ../../modules/bootstrap | n/a |
| <a name="module_outbound_lb"></a> [outbound\_lb](#module\_outbound\_lb) | ../../modules/loadbalancer | n/a |
| <a name="module_outbound_scale_set"></a> [outbound\_scale\_set](#module\_outbound\_scale\_set) | ../../modules/vmss | n/a |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | ../../modules/vnet | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_nat_gateway.mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway.outbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway_public_ip_association.mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) | resource |
| [azurerm_nat_gateway_public_ip_association.outbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) | resource |
| [azurerm_network_security_rule.mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.outbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.inbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.outbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet_nat_gateway_association.mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_subnet_nat_gateway_association.outbound_private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_subnet_nat_gateway_association.outbound_public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_resource_group.inbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.outbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space used by the Virtual Network. You can supply more than one address space. | `list(string)` | n/a | yes |
| <a name="input_allow_inbound_data_ips"></a> [allow\_inbound\_data\_ips](#input\_allow\_inbound\_data\_ips) | List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access public data interfaces of VM-Series.<br>If the list is empty, the contents of `allow_inbound_mgmt_ips` are substituted instead. | `list(string)` | `[]` | no |
| <a name="input_allow_inbound_mgmt_ips"></a> [allow\_inbound\_mgmt\_ips](#input\_allow\_inbound\_mgmt\_ips) | List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access management interfaces of VM-Series.<br>If you use Panorama, include its address in the list (as well as the secondary Panorama's). | `list(string)` | `[]` | no |
| <a name="input_app_insights_settings"></a> [app\_insights\_settings](#input\_app\_insights\_settings) | A map of the Application Insights related parameters. Full description available under [vmseries/README.md](../../modules/vmseries/README.md#input\_app\_insights\_settings) | `map(any)` | `null` | no |
| <a name="input_autoscale_metrics"></a> [autoscale\_metrics](#input\_autoscale\_metrics) | Map of objects, where each key is the metric name to be used for autoscaling.<br>Each value of the map has the attributes `scaleout_threshold` and `scalein_threshold`, which cause the instance count to grow by 1 when metrics are greater or equal, or decrease by 1 when lower or equal, respectively.<br>The thresholds are applied to results of metrics' aggregation over a time window.<br>Example:<pre>{<br>  "DataPlaneCPUUtilizationPct" = {<br>    scaleout_threshold = 80<br>    scalein_threshold  = 20<br>  }<br>  "panSessionUtilization" = {<br>    scaleout_threshold = 80<br>    scalein_threshold  = 20<br>  }<br>}</pre>Other possible metrics include `panSessionActive`, `panSessionThroughputKbps`, `panSessionThroughputPps`, `DataPlanePacketBufferUtilization`. | `map` | `{}` | no |
| <a name="input_autoscale_notification_emails"></a> [autoscale\_notification\_emails](#input\_autoscale\_notification\_emails) | List of email addresses to notify about autoscaling events. | `list(string)` | `[]` | no |
| <a name="input_avzones"></a> [avzones](#input\_avzones) | After provider version 3.x you need to specify in which availability zone(s) you want to place IP.<br>ie: for zone-redundant with 3 availability zone in current region value will be:<pre>["1","2","3"]</pre>Use command<pre>az vm list-skus --location REGION_NAME --zone --query '[0].locationInfo[0].zones'</pre>to see how many AZ is<br>in current region. | `list(string)` | `[]` | no |
| <a name="input_common_vmseries_sku"></a> [common\_vmseries\_sku](#input\_common\_vmseries\_sku) | VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"bundle2"` | no |
| <a name="input_create_inbound_resource_group"></a> [create\_inbound\_resource\_group](#input\_create\_inbound\_resource\_group) | If true, create a new Resource Group for inbound VM-Series. Otherwise use a pre-existing group. | `bool` | `true` | no |
| <a name="input_create_outbound_resource_group"></a> [create\_outbound\_resource\_group](#input\_create\_outbound\_resource\_group) | If true, create a new Resource Group for outbound VM-Series. Otherwise use a pre-existing group. | `bool` | `true` | no |
| <a name="input_create_virtual_network"></a> [create\_virtual\_network](#input\_create\_virtual\_network) | If true, create the Virtual Network, otherwise just use a pre-existing network. | `bool` | `true` | no |
| <a name="input_disable_password_authentication"></a> [disable\_password\_authentication](#input\_disable\_password\_authentication) | If true, disables password-based authentication on VM-Series instances. | `bool` | `true` | no |
| <a name="input_enable_zones"></a> [enable\_zones](#input\_enable\_zones) | If true, Public IP addresses will have `Zone-Redundant` setting, otherwise `No-Zone`. The latter is intended for the regions that do not yet support Availability Zones. | `bool` | `true` | no |
| <a name="input_inbound_count_maximum"></a> [inbound\_count\_maximum](#input\_inbound\_count\_maximum) | Maximal number of inbound VM-Series to scale out to. | `number` | `2` | no |
| <a name="input_inbound_count_minimum"></a> [inbound\_count\_minimum](#input\_inbound\_count\_minimum) | Minimal number of inbound VM-Series to deploy. | `number` | `1` | no |
| <a name="input_inbound_files"></a> [inbound\_files](#input\_inbound\_files) | Map of all files to copy to `inbound_storage_share_name`. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\`. For example `{"dir/my.txt" = "config/init-cfg.txt"}` | `map(string)` | `{}` | no |
| <a name="input_inbound_lb_name"></a> [inbound\_lb\_name](#input\_inbound\_lb\_name) | Name of the public-facing load balancer. | `string` | `"lb_public"` | no |
| <a name="input_inbound_name_prefix"></a> [inbound\_name\_prefix](#input\_inbound\_name\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_inbound_resource_group_name"></a> [inbound\_resource\_group\_name](#input\_inbound\_resource\_group\_name) | Name of the Resource Group to create if `create_inbound_resource_group` is true. Name of the pre-existing Resource Group to use otherwise. | `string` | n/a | yes |
| <a name="input_inbound_storage_share_name"></a> [inbound\_storage\_share\_name](#input\_inbound\_storage\_share\_name) | Name of storage share to be created that holds `files` for bootstrapping inbound VM-Series. | `string` | n/a | yes |
| <a name="input_inbound_vmseries_tags"></a> [inbound\_vmseries\_tags](#input\_inbound\_vmseries\_tags) | Map of tags to be associated with the inbound virtual machines, their interfaces and public IP addresses. | `map(string)` | `{}` | no |
| <a name="input_inbound_vmseries_version"></a> [inbound\_vmseries\_version](#input\_inbound\_vmseries\_version) | Inbound VM-series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"10.1.0"` | no |
| <a name="input_inbound_vmseries_vm_size"></a> [inbound\_vmseries\_vm\_size](#input\_inbound\_vmseries\_vm\_size) | Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported. | `string` | `"Standard_D3_v2"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to use. | `string` | `"Australia Central"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix for all the names of the created Azure objects. It can end with a dash `-` character, if your naming convention prefers such separator. | `string` | `"pantf"` | no |
| <a name="input_name_scale_set"></a> [name\_scale\_set](#input\_name\_scale\_set) | Name of the virtual machine scale set. | `string` | `"VMSS"` | no |
| <a name="input_network_security_groups"></a> [network\_security\_groups](#input\_network\_security\_groups) | Map of Network Security Groups to create. Refer to the `vnet` module documentation for more information. | `any` | n/a | yes |
| <a name="input_olb_private_ip"></a> [olb\_private\_ip](#input\_olb\_private\_ip) | The private IP address to assign to the outbound load balancer. This IP **must** fall in the `outbound_private` subnet CIDR. | `string` | n/a | yes |
| <a name="input_outbound_count_maximum"></a> [outbound\_count\_maximum](#input\_outbound\_count\_maximum) | Maximal number of outbound VM-Series to scale out to. | `number` | `2` | no |
| <a name="input_outbound_count_minimum"></a> [outbound\_count\_minimum](#input\_outbound\_count\_minimum) | Minimal number of outbound VM-Series to deploy. | `number` | `1` | no |
| <a name="input_outbound_files"></a> [outbound\_files](#input\_outbound\_files) | Map of all files to copy to `outbound_storage_share_name`. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\`. For example `{"dir/my.txt" = "config/init-cfg.txt"}` | `map(string)` | `{}` | no |
| <a name="input_outbound_lb_name"></a> [outbound\_lb\_name](#input\_outbound\_lb\_name) | Name of the private load balancer. | `string` | `"lb_private"` | no |
| <a name="input_outbound_name_prefix"></a> [outbound\_name\_prefix](#input\_outbound\_name\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_outbound_resource_group_name"></a> [outbound\_resource\_group\_name](#input\_outbound\_resource\_group\_name) | Name of the Resource Group to create if `create_outbound_resource_group` is true. Name of the pre-existing Resource Group to use otherwise. | `string` | n/a | yes |
| <a name="input_outbound_storage_share_name"></a> [outbound\_storage\_share\_name](#input\_outbound\_storage\_share\_name) | Name of storage share to be created that holds `files` for bootstrapping outbound VM-Series. | `string` | n/a | yes |
| <a name="input_outbound_vmseries_tags"></a> [outbound\_vmseries\_tags](#input\_outbound\_vmseries\_tags) | Map of tags to be associated with the outbound virtual machines, their interfaces and public IP addresses. | `map(string)` | `{}` | no |
| <a name="input_outbound_vmseries_version"></a> [outbound\_vmseries\_version](#input\_outbound\_vmseries\_version) | Outbound VM-series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"10.1.0"` | no |
| <a name="input_outbound_vmseries_vm_size"></a> [outbound\_vmseries\_vm\_size](#input\_outbound\_vmseries\_vm\_size) | Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported. | `string` | `"Standard_D3_v2"` | no |
| <a name="input_panorama_tags"></a> [panorama\_tags](#input\_panorama\_tags) | Predefined tags neccessary for the Panorama `azure` plugin v2 to automatically de-license the VM-Series. Can be set to empty `{}` when version v2 de-licensing is not used. | `map(string)` | <pre>{<br>  "PanoramaManaged": "yes"<br>}</pre> | no |
| <a name="input_password"></a> [password](#input\_password) | Initial administrative password to use for all systems. Set to null for an auto-generated password. | `string` | `null` | no |
| <a name="input_public_frontend_ips"></a> [public\_frontend\_ips](#input\_public\_frontend\_ips) | Map of objects describing frontend IP configurations and rules for the inbound load balancer. Refer to the `loadbalancer` module documentation for more information. | `any` | n/a | yes |
| <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables) | Map of Route Tables to create. Refer to the `vnet` module documentation for more information. | `any` | n/a | yes |
| <a name="input_scalein_cooldown_minutes"></a> [scalein\_cooldown\_minutes](#input\_scalein\_cooldown\_minutes) | Azure only considers deleting a VM after this number of minutes has passed since the last VM scaling action. Should be higher or equal to `scalein_window_minutes`. Must be between 1 and 10080 minutes. | `number` | `2880` | no |
| <a name="input_scalein_statistic"></a> [scalein\_statistic](#input\_scalein\_statistic) | Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines. Possible values are Average, Min and Max. | `string` | `"Max"` | no |
| <a name="input_scalein_time_aggregation"></a> [scalein\_time\_aggregation](#input\_scalein\_time\_aggregation) | Specifies how the metric should be combined over the time `scalein_window_minutes`. Possible values are Average, Count, Maximum, Minimum, Last and Total. | `string` | `"Maximum"` | no |
| <a name="input_scalein_window_minutes"></a> [scalein\_window\_minutes](#input\_scalein\_window\_minutes) | This is amount of time in minutes that autoscale engine will look back for metrics. For example, 10 minutes means that every time autoscale runs,<br>it will query metrics for the past 10 minutes. This allows metrics to stabilize and avoids reacting to transient spikes.<br>Must be between 5 and 720 minutes. | `number` | `15` | no |
| <a name="input_scaleout_cooldown_minutes"></a> [scaleout\_cooldown\_minutes](#input\_scaleout\_cooldown\_minutes) | Before each VM number increase, wait `scaleout_window_minutes` plus `scaleout_cooldown_minutes` counting from the last VM number increase. | `number` | `15` | no |
| <a name="input_scaleout_statistic"></a> [scaleout\_statistic](#input\_scaleout\_statistic) | Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines. Possible values are Average, Min and Max. | `string` | `"Max"` | no |
| <a name="input_scaleout_time_aggregation"></a> [scaleout\_time\_aggregation](#input\_scaleout\_time\_aggregation) | Specifies how the metric should be combined over the time `scaleout_window_minutes`. Possible values are Average, Count, Maximum, Minimum, Last and Total. | `string` | `"Maximum"` | no |
| <a name="input_scaleout_window_minutes"></a> [scaleout\_window\_minutes](#input\_scaleout\_window\_minutes) | This is amount of time in minutes that autoscale engine will look back for metrics. For example, 10 minutes means that every time autoscale runs,<br>it will query metrics for the past 10 minutes. This allows metrics to stabilize and avoids reacting to transient spikes.<br>Must be between 5 and 720 minutes. | `number` | `10` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | Administrator user SSH key | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Default name of the storage account to create.<br>The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters. | `string` | `"pantfstorage"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of Subnets to create. Refer to the `vnet` module documentation for more information. | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Azure tags to apply to the created cloud resources. A map, for example `{ team = "NetAdmin", costcenter = "CIO42" }` | `map(string)` | `{}` | no |
| <a name="input_username"></a> [username](#input\_username) | Initial administrative username to use for all systems. | `string` | `"panadmin"` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the Virtual Network. | `string` | n/a | yes |
| <a name="input_vnet_tags"></a> [vnet\_tags](#input\_vnet\_tags) | Map of extra tags to assign specifically to the created virtual network, security groups, and route tables. The entries from `tags` are applied as well unless overriden. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_inbound_frontend_ips"></a> [inbound\_frontend\_ips](#output\_inbound\_frontend\_ips) | n/a |
| <a name="output_metrics_instrumentation_key_inbound"></a> [metrics\_instrumentation\_key\_inbound](#output\_metrics\_instrumentation\_key\_inbound) | The Instrumentation Key of the created instance of Azure Application Insights for Inbound firewalls. The instance is unused by default, but is ready to receive custom PAN-OS metrics from the firewalls. To use it, paste this Instrumentation Key into PAN-OS -> Device -> VM-Series -> Azure. |
| <a name="output_metrics_instrumentation_key_outbound"></a> [metrics\_instrumentation\_key\_outbound](#output\_metrics\_instrumentation\_key\_outbound) | The Instrumentation Key of the created instance of Azure Application Insights for Outbound firewalls. The instance is unused by default, but is ready to receive custom PAN-OS metrics from the firewalls. To use it, paste this Instrumentation Key into PAN-OS -> Device -> VM-Series -> Azure. |
| <a name="output_password"></a> [password](#output\_password) | Initial administrative password to use for VM-Series. |
| <a name="output_username"></a> [username](#output\_username) | Initial administrative username to use for VM-Series. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

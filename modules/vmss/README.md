# Palo Alto Networks VMSS Module for Azure

A terraform module for VMSS VM-Series firewalls in Azure.

**NOTE** \
Due to [lack of proper method of running health probes](./main.tf#L21-54) against Pan-OS based VMs running in a Scale Set, the `upgrade_mode` property is hardcoded to `Manual`. For this mode to actually work the `roll_instances_when_required` provider feature has to be also configured and set to `false`. Unfortunately this cannot be set in the `vmss` module, it has to be specified in the **root** module.

Therefore, when using this module please add the following `provider` block to your code:

```hcl
provider "azurerm" {
  features {
    virtual_machine_scale_set {
      roll_instances_when_required = false
    }
  }
}
```

## Usage

```hcl
module "vmss" {
  source = "PaloAltoNetworks/vmseries-modules/azurerm//modules/vmss"

  location                  = "Australia Central"
  name_prefix               = "pan"
  password                  = "your-password"
  subnet_mgmt               = azurerm_subnet.subnet_mgmt
  subnet_private            = azurerm_subnet.subnet_private
  subnet_public             = module.networks.subnet_public
  bootstrap_storage_account = module.panorama.bootstrap_storage_account
  bootstrap_share_name      = "inboundsharename"
  vhd_container             = "vhd-storage-container-id"
  lb_backend_pool_id        = "private-backend-pool-id"
}
```

## Reference
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2, < 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.25 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.25 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine_scale_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_monitor_autoscale_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the Azure Virtual Machine Scale Set. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the Resource Group to use. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The name of the Azure region to deploy the resources in. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The map of tags to assign to all created resources. | `map(string)` | `{}` | no |
| <a name="input_authentication"></a> [authentication](#input\_authentication) | A map defining authentication settings (including username and password).<br><br>Following properties are available:<br><br>- `username`                        - (`string`, optional, defaults to `panadmin`) the initial administrative VMseries username<br>- `password`                        - (`string`, optional, defaults to `null`) the initial administrative VMSeries password<br>- `disable_password_authentication` - (`bool`, optional, defaults to `true`) disables password-based authentication<br>- `ssh_keys`                        - (`list`, optional, defaults to `[]`) a list of initial administrative SSH public keys<br><br>> [!Important]<br>> The `password` property is required when `ssh_keys` is not specified.<br><br>> [!Important]<br>> `ssh_keys` property is a list of strings, so each item should be the actual public key value.<br>> If you would like to load them from files use the `file` function.<br>> For example: `[ file("/path/to/public/keys/key_1.pub") ]`. | <pre>object({<br>    username                        = optional(string, "panadmin")<br>    password                        = optional(string)<br>    disable_password_authentication = optional(bool, true)<br>    ssh_keys                        = optional(list(string), [])<br>  })</pre> | n/a | yes |
| <a name="input_vm_image_configuration"></a> [vm\_image\_configuration](#input\_vm\_image\_configuration) | Basic Azure VM configuration.<br><br>Following properties are available:<br><br>- `img_version`             - (`string`, optional, defaults to `null`) VMSeries PAN-OS version; list available with <br>                              `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all`<br>- `img_publisher`           - (`string`, optional, defaults to `paloaltonetworks`) the Azure Publisher identifier for a image<br>                              which should be deployed<br>- `img_offer`               - (`string`, optional, defaults to `vmseries-flex`) the Azure Offer identifier corresponding to a<br>                              published image<br>- `img_sku`                 - (`string`, optional, defaults to `byol`) VMSeries SKU; list available with<br>                              `az vm image list -o table --all --publisher paloaltonetworks`<br>- `enable_marketplace_plan` - (`bool`, optional, defaults to `true`) when set to `true` accepts the license for a offer/plan<br>                              on Azure Market Place<br>- `custom_image_id`         - (`string`, optional, defaults to `null`) absolute ID of your own custom PanOS image to be used for<br>                              creating new Virtual Machines<br><br>> [!Important]<br>> `custom_image_id` and `img_version` properties are mutually exclusive. | <pre>object({<br>    img_version             = optional(string)<br>    img_publisher           = optional(string, "paloaltonetworks")<br>    img_offer               = optional(string, "vmseries-flex")<br>    img_sku                 = optional(string, "byol")<br>    enable_marketplace_plan = optional(bool, true)<br>    custom_image_id         = optional(string)<br>  })</pre> | n/a | yes |
| <a name="input_scale_set_configuration"></a> [scale\_set\_configuration](#input\_scale\_set\_configuration) | Scale set parameters configuration.<br><br>This map contains basic, as well as some optional Virtual Machine Scale Set parameters. Both types contain sane defaults.<br>Nevertheless they should be at least reviewed to meet deployment requirements.<br><br>List of either required or important properties: <br><br>- `vm_size`               - (`string`, optional, defaults to `Standard_D3_v2`) Azure VM size (type). Consult the *VM-Series<br>                            Deployment Guide* as only a few selected sizes are supported<br>- `zones`                 - (`list`, optional, defaults to `["1", "2", "3"]`) a list of Availability Zones in which VMs from<br>                            this Scale Set will be created<br>- `storage_account_type`  - (`string`, optional, defaults to `StandardSSD_LRS`) type of Managed Disk which should be created,<br>                            possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS` (works only for selected<br>                            `vm_size` values)<br><br>List of other, optional properties: <br><br>- `accelerated_networking`        - (`bool`, optional, defaults to `true`) when set to `true`  enables Azure accelerated<br>                                    networking (SR-IOV) for all dataplane network interfaces, this does not affect the<br>                                    management interface (always disabled)<br>- `disk_encryption_set_id`        - (`string`, optional, defaults to `null`) the ID of the Disk Encryption Set which should be<br>                                    used to encrypt this VM's disk<br>- `zone_balance`                  - (`bool`, optional, defaults to `true`) when set to `true` VMs in this Scale Set will be<br>                                    evenly distributed across configured Availability Zones<br>- `encryption_at_host_enabled`    - (`bool`, optional, defaults to Azure defaults) should all of disks be encrypted<br>                                    by enabling Encryption at Host<br>- `overprovision`                 - (`bool`, optional, defaults to `true`) See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)<br>- `platform_fault_domain_count`   - (`number`, optional, defaults to Azure defaults) specifies the number of fault domains that<br>                                    are used by this Virtual Machine Scale Set<br>- `proximity_placement_group_id`  - (`string`, optional, defaults to Azure defaults) the ID of the Proximity Placement Group<br>                                    in which the Virtual Machine Scale Set should be assigned to<br>- `single_placement_group`        - (`bool`, defaults to Azure defaults) when `true` this Virtual Machine Scale Set will be<br>                                    limited to a Single Placement Group, which means the number of instances will be capped<br>                                    at 100 Virtual Machines | <pre>object({<br>    vm_size                      = optional(string, "Standard_D3_v2")<br>    zones                        = optional(list(string), ["1", "2", "3"])<br>    zone_balance                 = optional(bool, true)<br>    storage_account_type         = optional(string, "StandardSSD_LRS")<br>    accelerated_networking       = optional(bool, true)<br>    encryption_at_host_enabled   = optional(bool)<br>    overprovision                = optional(bool, true)<br>    platform_fault_domain_count  = optional(number)<br>    proximity_placement_group_id = optional(string)<br>    disk_encryption_set_id       = optional(string)<br>  })</pre> | n/a | yes |
| <a name="input_interfaces"></a> [interfaces](#input\_interfaces) | List of the network interfaces specifications.<br><br>NOTICE. The ORDER in which you specify the interfaces DOES MATTER.<br>Interfaces will be attached to VM in the order you define here, therefore:<br>* The first should be the management interface, which does not participate in data filtering.<br>* The remaining ones are the dataplane interfaces.<br><br>Options for an interface object:<br>- `name`                     - (required\|string) Interface name.<br>- `subnet_id`                - (required\|string) Identifier of an existing subnet to create interface in.<br>- `create_pip`               - (optional\|bool) If true, create a public IP for the interface<br>- `lb_backend_pool_ids`      - (optional\|list(string)) A list of identifiers of an existing Load Balancer backend pools to associate interface with.<br>- `appgw_backend_pool_ids`   - (optional\|list(String)) A list of identifier of the Application Gateway backend pools to associate interface with.<br>- `pip_domain_name_label`    - (optional\|string) The Prefix which should be used for the Domain Name Label for each Virtual Machine Instance.<br><br>Example:<pre>[<br>  {<br>    name       = "management"<br>    subnet_id  = azurerm_subnet.my_mgmt_subnet.id<br>    create_pip = true<br>  },<br>  {<br>    name      = "private"<br>    subnet_id = azurerm_subnet.my_priv_subnet.id<br>  },<br>  {<br>    name                = "public"<br>    subnet_id           = azurerm_subnet.my_pub_subnet.id<br>    lb_backend_pool_ids = [azurerm_lb_backend_address_pool.lb_backend.id]<br>  }<br>]</pre> | `any` | n/a | yes |
| <a name="input_scale_in_policy"></a> [scale\_in\_policy](#input\_scale\_in\_policy) | Which virtual machines are chosen for removal when a Virtual Machine Scale Set is scaled in. Either:<br><br>- `Default`, which, baring the availability zone usage and fault domain usage, deletes VM with the highest-numbered instance id,<br>- `NewestVM`, which, baring the availability zone usage, deletes VM with the newest creation time,<br>- `OldestVM`, which, baring the availability zone usage, deletes VM with the oldest creation time. | `string` | `null` | no |
| <a name="input_scale_in_force_deletion"></a> [scale\_in\_force\_deletion](#input\_scale\_in\_force\_deletion) | When set to `true` will force delete machines selected for removal by the `scale_in_policy`. | `bool` | `false` | no |
| <a name="input_application_insights_id"></a> [application\_insights\_id](#input\_application\_insights\_id) | An ID of Application Insights instance that should be used to provide metrics for autoscaling.<br><br>**Note**, to avoid false positives this should be an instance dedicated to this VMSS.<pre></pre> | `string` | `null` | no |
| <a name="input_autoscale_count_default"></a> [autoscale\_count\_default](#input\_autoscale\_count\_default) | The minimum number of instances that should be present in the scale set when the autoscaling engine cannot read the metrics or is otherwise unable to compare the metrics to the thresholds. | `number` | `2` | no |
| <a name="input_autoscale_count_minimum"></a> [autoscale\_count\_minimum](#input\_autoscale\_count\_minimum) | The minimum number of instances that should be present in the scale set. | `number` | `2` | no |
| <a name="input_autoscale_count_maximum"></a> [autoscale\_count\_maximum](#input\_autoscale\_count\_maximum) | The maximum number of instances that should be present in the scale set. | `number` | `5` | no |
| <a name="input_autoscale_notification_emails"></a> [autoscale\_notification\_emails](#input\_autoscale\_notification\_emails) | List of email addresses to notify about autoscaling events. | `list(string)` | `[]` | no |
| <a name="input_autoscale_webhooks_uris"></a> [autoscale\_webhooks\_uris](#input\_autoscale\_webhooks\_uris) | Map where each key is an arbitrary identifier and each value is a webhook URI. The URIs receive autoscaling events. | `map(string)` | `{}` | no |
| <a name="input_autoscale_metrics"></a> [autoscale\_metrics](#input\_autoscale\_metrics) | Map of objects, where each key is the metric name to be used for autoscaling.<br>Each value of the map has the attributes `scaleout_threshold` and `scalein_threshold`, which cause the instance count to grow by 1 when metrics are greater or equal, or decrease by 1 when lower or equal, respectively.<br>The thresholds are applied to results of metrics' aggregation over a time window.<br>Example:<pre>{<br>  "DataPlaneCPUUtilizationPct" = {<br>    scaleout_threshold = 80<br>    scalein_threshold  = 20<br>  }<br>  "panSessionUtilization" = {<br>    scaleout_threshold = 80<br>    scalein_threshold  = 20<br>  }<br>}</pre>Other possible metrics include panSessionActive, panSessionThroughputKbps, panSessionThroughputPps, DataPlanePacketBufferUtilization. | `map(any)` | `{}` | no |
| <a name="input_scaleout_statistic"></a> [scaleout\_statistic](#input\_scaleout\_statistic) | Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines. Possible values are Average, Min and Max. | `string` | `"Max"` | no |
| <a name="input_scaleout_time_aggregation"></a> [scaleout\_time\_aggregation](#input\_scaleout\_time\_aggregation) | Specifies how the metric should be combined over the time `scaleout_window_minutes`. Possible values are Average, Count, Maximum, Minimum, Last and Total. | `string` | `"Maximum"` | no |
| <a name="input_scaleout_window_minutes"></a> [scaleout\_window\_minutes](#input\_scaleout\_window\_minutes) | This is amount of time in minutes that autoscale engine will look back for metrics. For example, 10 minutes means that every time autoscale runs,<br>it will query metrics for the past 10 minutes. This allows metrics to stabilize and avoids reacting to transient spikes.<br>Must be between 5 and 720 minutes. | `number` | `10` | no |
| <a name="input_scaleout_cooldown_minutes"></a> [scaleout\_cooldown\_minutes](#input\_scaleout\_cooldown\_minutes) | Azure only considers adding a VM after this number of minutes has passed since the last VM scaling action. It should be much higher than `scaleout_window_minutes`, to account both for the VM-Series spin-up time and for the subsequent metrics stabilization time. Must be between 1 and 10080 minutes. | `number` | `25` | no |
| <a name="input_scalein_statistic"></a> [scalein\_statistic](#input\_scalein\_statistic) | Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines. Possible values are Average, Min and Max. | `string` | `"Max"` | no |
| <a name="input_scalein_time_aggregation"></a> [scalein\_time\_aggregation](#input\_scalein\_time\_aggregation) | Specifies how the metric should be combined over the time `scalein_window_minutes`. Possible values are Average, Count, Maximum, Minimum, Last and Total. | `string` | `"Maximum"` | no |
| <a name="input_scalein_window_minutes"></a> [scalein\_window\_minutes](#input\_scalein\_window\_minutes) | This is amount of time in minutes that autoscale engine will look back for metrics. For example, 10 minutes means that every time autoscale runs,<br>it will query metrics for the past 10 minutes. This allows metrics to stabilize and avoids reacting to transient spikes.<br>Must be between 5 and 720 minutes. | `number` | `15` | no |
| <a name="input_scalein_cooldown_minutes"></a> [scalein\_cooldown\_minutes](#input\_scalein\_cooldown\_minutes) | Azure only considers deleting a VM after this number of minutes has passed since the last VM scaling action. Should be higher or equal to `scalein_window_minutes`. Must be between 1 and 10080 minutes. | `number` | `2880` | no |
| <a name="input_bootstrap_options"></a> [bootstrap\_options](#input\_bootstrap\_options) | Bootstrap options to pass to VM-Series instance.<br><br>Proper syntax is a string of semicolon separated properties.<br>Example:<br>  bootstrap\_options = "type=dhcp-client;panorama-server=1.2.3.4"<br><br>For more details on bootstrapping see documentation: https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/init-cfgtxt-file-components | `string` | `""` | no |
| <a name="input_diagnostics_storage_uri"></a> [diagnostics\_storage\_uri](#input\_diagnostics\_storage\_uri) | The storage account's blob endpoint to hold diagnostic files. | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_scale_set_name"></a> [scale\_set\_name](#output\_scale\_set\_name) | Name of the created scale set. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Custom Metrics

Firewalls can publish custom metrics (for example `panSessionUtilization`) to Azure Application Insights to improve the autoscaling.
This however requires a manual initialization: copy the outputs `metrics_instrumentation_key` and paste it into your
PAN-OS webUI -> Device -> VM-Series -> Azure. This module automatically
completes solely the Step 1 of the [official procedure](https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/set-up-the-vm-series-firewall-on-azure/enable-azure-application-insights-on-the-vm-series-firewall.html).

If you manage the configuration from Panorama, this can be done in the same place, however the PAN-OS `VM-Series plugin` needs to be installed **on both** Panorama and VM-Series.

The metrics gathered within a single Azure Application Insights instance provided by the module, cannot be split to obtain
back a result for solely a single firewall. Thus for example if three firewalls use the same Instrumentation Key and report
their respective session utilizations as 90%, 20%, 10%, it is possible to see in Azure the average of 40%, the sum of 120%, the max of 90%, but it is *not possible* to know which of the firewalls reported the 90% utilization.

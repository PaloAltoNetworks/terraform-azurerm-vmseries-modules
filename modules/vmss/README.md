# Palo Alto Networks VMSS Module for Azure

A terraform module for VMSS VM-Series firewalls in Azure.

## Usage

```hcl
module "vmss" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/vmss"

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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.29, < 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 2.26 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_linux_virtual_machine_scale_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_monitor_autoscale_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerated_networking"></a> [accelerated\_networking](#input\_accelerated\_networking) | If true, enable Azure accelerated networking (SR-IOV) for all dataplane network interfaces. [Requires](https://docs.paloaltonetworks.com/pan-os/9-0/pan-os-new-features/virtualization-features/support-for-azure-accelerated-networking-sriov) PAN-OS 9.0 or higher. The PAN-OS management interface (nic0) is never accelerated, whether this variable is true or false. | `bool` | `true` | no |
| <a name="input_autoscale_count_default"></a> [autoscale\_count\_default](#input\_autoscale\_count\_default) | The minimum number of instances that should be present in the scale set when the autoscaling engine cannot read the metrics or is otherwise unable to compare the metrics to the thresholds. | `number` | `2` | no |
| <a name="input_autoscale_count_maximum"></a> [autoscale\_count\_maximum](#input\_autoscale\_count\_maximum) | The maximum number of instances that should be present in the scale set. | `number` | `5` | no |
| <a name="input_autoscale_count_minimum"></a> [autoscale\_count\_minimum](#input\_autoscale\_count\_minimum) | The minimum number of instances that should be present in the scale set. | `number` | `2` | no |
| <a name="input_autoscale_metrics"></a> [autoscale\_metrics](#input\_autoscale\_metrics) | Map of objects, where each key is the metric name to be used for autoscaling.<br>Each value of the map has the attributes `scaleout_threshold` and `scalein_threshold`, which cause the instance count to grow by 1 when metrics are greater or equal, or decrease by 1 when lower or equal, respectively.<br>The thresholds are applied to results of metrics' aggregation over a time window.<br>Example:<pre>{<br>  "DataPlaneCPUUtilizationPct" = {<br>    scaleout_threshold = 80<br>    scalein_threshold  = 20<br>  }<br>  "panSessionUtilization" = {<br>    scaleout_threshold = 80<br>    scalein_threshold  = 20<br>  }<br>}</pre>Other possible metrics include panSessionActive, panSessionThroughputKbps, panSessionThroughputPps, DataPlanePacketBufferUtilization. | `map` | <pre>{<br>  "DataPlaneCPUUtilizationPct": {<br>    "scalein_threshold": 20,<br>    "scaleout_threshold": 80<br>  },<br>  "panSessionUtilization": {<br>    "scalein_threshold": 20,<br>    "scaleout_threshold": 80<br>  }<br>}</pre> | no |
| <a name="input_autoscale_notification_emails"></a> [autoscale\_notification\_emails](#input\_autoscale\_notification\_emails) | List of email addresses to notify about autoscaling events. | `list(string)` | `[]` | no |
| <a name="input_autoscale_webhooks_uris"></a> [autoscale\_webhooks\_uris](#input\_autoscale\_webhooks\_uris) | Map where each key is an arbitrary identifier and each value is a webhook URI. The URIs receive autoscaling events. | `map(string)` | `{}` | no |
| <a name="input_boot_diagnostics_storage_account_uri"></a> [boot\_diagnostics\_storage\_account\_uri](#input\_boot\_diagnostics\_storage\_account\_uri) | n/a | `string` | `null` | no |
| <a name="input_bootstrap_share_name"></a> [bootstrap\_share\_name](#input\_bootstrap\_share\_name) | File share for bootstrap config | `string` | n/a | yes |
| <a name="input_bootstrap_storage_account"></a> [bootstrap\_storage\_account](#input\_bootstrap\_storage\_account) | Storage account setup for bootstrapping | <pre>object({<br>    name               = string<br>    primary_access_key = string<br>  })</pre> | n/a | yes |
| <a name="input_create_mgmt_pip"></a> [create\_mgmt\_pip](#input\_create\_mgmt\_pip) | n/a | `bool` | `true` | no |
| <a name="input_create_public_interface"></a> [create\_public\_interface](#input\_create\_public\_interface) | If true, create the third network interface for virtual machines. | `bool` | `true` | no |
| <a name="input_create_public_pip"></a> [create\_public\_pip](#input\_create\_public\_pip) | n/a | `bool` | `true` | no |
| <a name="input_custom_image_id"></a> [custom\_image\_id](#input\_custom\_image\_id) | Absolute ID of your own Custom Image to be used for creating new VM-Series. The Custom Image is expected to contain PAN-OS software. | `string` | `null` | no |
| <a name="input_disable_password_authentication"></a> [disable\_password\_authentication](#input\_disable\_password\_authentication) | If true, disables password-based authentication on VM-Series instances. | `bool` | `false` | no |
| <a name="input_disk_encryption_set_id"></a> [disk\_encryption\_set\_id](#input\_disk\_encryption\_set\_id) | n/a | `string` | `null` | no |
| <a name="input_enable_plan"></a> [enable\_plan](#input\_enable\_plan) | Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku "byol", which means "bring your own license", still requires accepting on the Marketplace (as of 2021). Can be set to `false` when using a custom image. | `bool` | `true` | no |
| <a name="input_encryption_at_host_enabled"></a> [encryption\_at\_host\_enabled](#input\_encryption\_at\_host\_enabled) | See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#encryption_at_host_enabled). | `bool` | `null` | no |
| <a name="input_img_offer"></a> [img\_offer](#input\_img\_offer) | The Azure Offer identifier corresponding to a published image. For `img_version` 9.1.1 or above, use "vmseries-flex"; for 9.1.0 or below use "vmseries1". | `string` | `"vmseries-flex"` | no |
| <a name="input_img_publisher"></a> [img\_publisher](#input\_img\_publisher) | The Azure Publisher identifier for a image which should be deployed. | `string` | `"paloaltonetworks"` | no |
| <a name="input_img_sku"></a> [img\_sku](#input\_img\_sku) | VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"bundle2"` | no |
| <a name="input_img_version"></a> [img\_version](#input\_img\_version) | VM-Series PAN-OS version - list available for a default `img_offer` with `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all` | `string` | `"9.1.3"` | no |
| <a name="input_location"></a> [location](#input\_location) | Region to install VM-Series and dependencies. | `string` | n/a | yes |
| <a name="input_metrics_retention_in_days"></a> [metrics\_retention\_in\_days](#input\_metrics\_retention\_in\_days) | Specifies the metrics retention period in days. Possible values are 0, 30, 60, 90, 120, 180, 270, 365, 550 or 730. Defaults to 90. A special value 0 disables creation of Application Insights altogether, which is incompatible with `create_autoscaling`. | `number` | `null` | no |
| <a name="input_mgmt_pip_domain_name_label"></a> [mgmt\_pip\_domain\_name\_label](#input\_mgmt\_pip\_domain\_name\_label) | n/a | `string` | `null` | no |
| <a name="input_name_application_insights"></a> [name\_application\_insights](#input\_name\_application\_insights) | Name of the Applications Insights instance to be created. Can be null, in which case a default name is auto-generated. | `string` | `null` | no |
| <a name="input_name_autoscale"></a> [name\_autoscale](#input\_name\_autoscale) | Name of the Autoscale Settings to be created. Can be null, in which case a default name is auto-generated. | `string` | `null` | no |
| <a name="input_name_fw_mgmt_pip"></a> [name\_fw\_mgmt\_pip](#input\_name\_fw\_mgmt\_pip) | n/a | `string` | `"fw-mgmt-pip"` | no |
| <a name="input_name_fw_public_pip"></a> [name\_fw\_public\_pip](#input\_name\_fw\_public\_pip) | n/a | `string` | `"fw-mgmt-pip"` | no |
| <a name="input_name_mgmt_nic_ip"></a> [name\_mgmt\_nic\_ip](#input\_name\_mgmt\_nic\_ip) | n/a | `string` | `"nic-fw-mgmt"` | no |
| <a name="input_name_mgmt_nic_profile"></a> [name\_mgmt\_nic\_profile](#input\_name\_mgmt\_nic\_profile) | n/a | `string` | `"nic-fw-mgmt-profile"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix for all the names of the created Azure objects. It can end with a dash `-` character, if your naming convention prefers such separator. | `string` | n/a | yes |
| <a name="input_name_private_nic_ip"></a> [name\_private\_nic\_ip](#input\_name\_private\_nic\_ip) | n/a | `string` | `"nic-fw-private"` | no |
| <a name="input_name_private_nic_profile"></a> [name\_private\_nic\_profile](#input\_name\_private\_nic\_profile) | n/a | `string` | `"nic-fw-private-profile"` | no |
| <a name="input_name_public_nic_ip"></a> [name\_public\_nic\_ip](#input\_name\_public\_nic\_ip) | n/a | `string` | `"nic-fw-public"` | no |
| <a name="input_name_public_nic_profile"></a> [name\_public\_nic\_profile](#input\_name\_public\_nic\_profile) | n/a | `string` | `"nic-fw-public-profile"` | no |
| <a name="input_name_scale_set"></a> [name\_scale\_set](#input\_name\_scale\_set) | n/a | `string` | `"scaleset"` | no |
| <a name="input_overprovision"></a> [overprovision](#input\_overprovision) | See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set). | `bool` | `false` | no |
| <a name="input_password"></a> [password](#input\_password) | Initial administrative password to use for VM-Series. | `string` | n/a | yes |
| <a name="input_platform_fault_domain_count"></a> [platform\_fault\_domain\_count](#input\_platform\_fault\_domain\_count) | See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set). | `number` | `null` | no |
| <a name="input_private_backend_pool_id"></a> [private\_backend\_pool\_id](#input\_private\_backend\_pool\_id) | Identifier of the load balancer backend pool to associate with the private interface of each VM-Series firewall. | `string` | `null` | no |
| <a name="input_proximity_placement_group_id"></a> [proximity\_placement\_group\_id](#input\_proximity\_placement\_group\_id) | See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set). | `string` | `null` | no |
| <a name="input_public_backend_pool_id"></a> [public\_backend\_pool\_id](#input\_public\_backend\_pool\_id) | Identifier of the load balancer backend pool to associate with the public interface of each VM-Series firewall. | `string` | `null` | no |
| <a name="input_public_pip_domain_name_label"></a> [public\_pip\_domain\_name\_label](#input\_public\_pip\_domain\_name\_label) | n/a | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the existing resource group where to place the resources created. | `string` | n/a | yes |
| <a name="input_scale_in_policy"></a> [scale\_in\_policy](#input\_scale\_in\_policy) | Which virtual machines are chosen for removal when a Virtual Machine Scale Set is scaled in. Either:<br><br>- `Default`, which, baring the availability zone usage and fault domain usage, deletes VM with the highest-numbered instance id,<br>- `NewestVM`, which, baring the availability zone usage, deletes VM with the newest creation time,<br>- `OldestVM`, which, baring the availability zone usage, deletes VM with the oldest creation time. | `string` | `null` | no |
| <a name="input_scalein_cooldown_minutes"></a> [scalein\_cooldown\_minutes](#input\_scalein\_cooldown\_minutes) | Azure only considers deleting a VM after this number of minutes has passed since the last VM scaling action. Should be higher or equal to `scalein_window_minutes`. Must be between 1 and 10080 minutes. | `number` | `2880` | no |
| <a name="input_scalein_statistic"></a> [scalein\_statistic](#input\_scalein\_statistic) | Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines. Possible values are Average, Min and Max. | `string` | `"Max"` | no |
| <a name="input_scalein_time_aggregation"></a> [scalein\_time\_aggregation](#input\_scalein\_time\_aggregation) | Specifies how the metric should be combined over the time `scalein_window_minutes`. Possible values are Average, Count, Maximum, Minimum, Last and Total. | `string` | `"Maximum"` | no |
| <a name="input_scalein_window_minutes"></a> [scalein\_window\_minutes](#input\_scalein\_window\_minutes) | This is amount of time in minutes that autoscale engine will look back for metrics. For example, 10 minutes means that every time autoscale runs,<br>it will query metrics for the past 10 minutes. This allows metrics to stabilize and avoids reacting to transient spikes.<br>Must be between 5 and 720 minutes. | `number` | `15` | no |
| <a name="input_scaleout_cooldown_minutes"></a> [scaleout\_cooldown\_minutes](#input\_scaleout\_cooldown\_minutes) | Azure only considers adding a VM after this number of minutes has passed since the last VM scaling action. It should be much higher than `scaleout_window_minutes`, to account both for the VM-Series spin-up time and for the subsequent metrics stabilization time. Must be between 1 and 10080 minutes. | `number` | `25` | no |
| <a name="input_scaleout_statistic"></a> [scaleout\_statistic](#input\_scaleout\_statistic) | Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines. Possible values are Average, Min and Max. | `string` | `"Max"` | no |
| <a name="input_scaleout_time_aggregation"></a> [scaleout\_time\_aggregation](#input\_scaleout\_time\_aggregation) | Specifies how the metric should be combined over the time `scaleout_window_minutes`. Possible values are Average, Count, Maximum, Minimum, Last and Total. | `string` | `"Maximum"` | no |
| <a name="input_scaleout_window_minutes"></a> [scaleout\_window\_minutes](#input\_scaleout\_window\_minutes) | This is amount of time in minutes that autoscale engine will look back for metrics. For example, 10 minutes means that every time autoscale runs,<br>it will query metrics for the past 10 minutes. This allows metrics to stabilize and avoids reacting to transient spikes.<br>Must be between 5 and 720 minutes. | `number` | `10` | no |
| <a name="input_single_placement_group"></a> [single\_placement\_group](#input\_single\_placement\_group) | See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set). | `bool` | `null` | no |
| <a name="input_storage_account_type"></a> [storage\_account\_type](#input\_storage\_account\_type) | Type of Managed Disk which should be created. Possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`. The `Premium_LRS` works only for selected `vm_size` values, details in Azure docs. | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_subnet_mgmt"></a> [subnet\_mgmt](#input\_subnet\_mgmt) | Management subnet. | `object({ id = string })` | n/a | yes |
| <a name="input_subnet_private"></a> [subnet\_private](#input\_subnet\_private) | Private subnet (trusted). | `object({ id = string })` | n/a | yes |
| <a name="input_subnet_public"></a> [subnet\_public](#input\_subnet\_public) | Public subnet (untrusted). | `object({ id = string })` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to use for all the created resources. | `map(string)` | `{}` | no |
| <a name="input_use_custom_image"></a> [use\_custom\_image](#input\_use\_custom\_image) | If true, use `custom_image_id` and ignore the inputs `username`, `password`, `img_version`, `img_publisher`, `img_offer`, `img_sku` (all these are used only for published images, not custom ones). | `bool` | `false` | no |
| <a name="input_username"></a> [username](#input\_username) | Initial administrative username to use for VM-Series. | `string` | `"panadmin"` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported. | `string` | `"Standard_D3_v2"` | no |
| <a name="input_zone_balance"></a> [zone\_balance](#input\_zone\_balance) | See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set). | `bool` | `true` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | The availability zones to use, for example `["1", "2", "3"]`. If an empty list, no Availability Zones are used: `[]`. | `list(string)` | <pre>[<br>  "1",<br>  "2",<br>  "3"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_metrics_instrumentation_key"></a> [metrics\_instrumentation\_key](#output\_metrics\_instrumentation\_key) | The Instrumentation Key of the created instance of Azure Application Insights. The instance is unused by default, but is ready to receive custom PAN-OS metrics from the firewalls. To use it, paste this Instrumentation Key into PAN-OS -> Device -> VM-Series -> Azure. |
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

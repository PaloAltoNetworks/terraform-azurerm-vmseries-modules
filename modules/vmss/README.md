<!-- BEGIN_TF_DOCS -->


## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`name`](#name) | `string` | Name of the created scale set.
[`location`](#location) | `string` | Region to install VM-Series and dependencies.
[`resource_group_name`](#resource_group_name) | `string` | Name of the existing resource group where to place the resources created.
[`interfaces`](#interfaces) | `list(any)` | List of the network interface specifications.
[`password`](#password) | `string` | Initial administrative password to use for VM-Series.
[`img_version`](#img_version) | `string` | VM-Series PAN-OS version - list available for a default `img_offer` with `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all`.

## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`vm_size`](#vm_size) | `string` | Azure VM size (type) to be created.
[`username`](#username) | `string` | Initial administrative username to use for VM-Series.
[`ssh_keys`](#ssh_keys) | `list(string)` | A list of initial administrative SSH public keys that allow key-pair authentication.
[`disable_password_authentication`](#disable_password_authentication) | `bool` | If true, disables password-based authentication on VM-Series instances.
[`encryption_at_host_enabled`](#encryption_at_host_enabled) | `bool` | See the [provider documentation](https://registry.
[`overprovision`](#overprovision) | `bool` | See the [provider documentation](https://registry.
[`platform_fault_domain_count`](#platform_fault_domain_count) | `number` | See the [provider documentation](https://registry.
[`proximity_placement_group_id`](#proximity_placement_group_id) | `string` | See the [provider documentation](https://registry.
[`scale_in_policy`](#scale_in_policy) | `string` | Which virtual machines are chosen for removal when a Virtual Machine Scale Set is scaled in.
[`scale_in_force_deletion`](#scale_in_force_deletion) | `bool` | When set to `true` will force delete machines selected for removal by the `scale_in_policy`.
[`single_placement_group`](#single_placement_group) | `bool` | See the [provider documentation](https://registry.
[`zone_balance`](#zone_balance) | `bool` | See the [provider documentation](https://registry.
[`zones`](#zones) | `list(string)` | The availability zones to use, for example `["1", "2", "3"]`.
[`storage_account_type`](#storage_account_type) | `string` | Type of Managed Disk which should be created.
[`disk_encryption_set_id`](#disk_encryption_set_id) | `string` | The ID of the Disk Encryption Set which should be used to encrypt this Data Disk.
[`use_custom_image`](#use_custom_image) | `bool` | If true, use `custom_image_id` and ignore the inputs `username`, `password`, `img_version`, `img_publisher`, `img_offer`, `img_sku` (all these are used only for published images, not custom ones).
[`custom_image_id`](#custom_image_id) | `string` | Absolute ID of your own Custom Image to be used for creating new VM-Series.
[`enable_plan`](#enable_plan) | `bool` | Enable usage of the Offer/Plan on Azure Marketplace.
[`img_publisher`](#img_publisher) | `string` | The Azure Publisher identifier for a image which should be deployed.
[`img_offer`](#img_offer) | `string` | The Azure Offer identifier corresponding to a published image.
[`img_sku`](#img_sku) | `string` | VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`.
[`accelerated_networking`](#accelerated_networking) | `bool` | If true, enable Azure accelerated networking (SR-IOV) for all dataplane network interfaces.
[`application_insights_id`](#application_insights_id) | `string` | An ID of Application Insights instance that should be used to provide metrics for autoscaling.
[`autoscale_count_default`](#autoscale_count_default) | `number` | The minimum number of instances that should be present in the scale set when the autoscaling engine cannot read the metrics or is otherwise unable to compare the metrics to the thresholds.
[`autoscale_count_minimum`](#autoscale_count_minimum) | `number` | The minimum number of instances that should be present in the scale set.
[`autoscale_count_maximum`](#autoscale_count_maximum) | `number` | The maximum number of instances that should be present in the scale set.
[`autoscale_notification_emails`](#autoscale_notification_emails) | `list(string)` | List of email addresses to notify about autoscaling events.
[`autoscale_webhooks_uris`](#autoscale_webhooks_uris) | `map(string)` | Map where each key is an arbitrary identifier and each value is a webhook URI.
[`autoscale_metrics`](#autoscale_metrics) | `map(any)` | Map of objects, where each key is the metric name to be used for autoscaling.
[`scaleout_statistic`](#scaleout_statistic) | `string` | Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines.
[`scaleout_time_aggregation`](#scaleout_time_aggregation) | `string` | Specifies how the metric should be combined over the time `scaleout_window_minutes`.
[`scaleout_window_minutes`](#scaleout_window_minutes) | `number` | This is amount of time in minutes that autoscale engine will look back for metrics.
[`scaleout_cooldown_minutes`](#scaleout_cooldown_minutes) | `number` | Azure only considers adding a VM after this number of minutes has passed since the last VM scaling action.
[`scalein_statistic`](#scalein_statistic) | `string` | Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines.
[`scalein_time_aggregation`](#scalein_time_aggregation) | `string` | Specifies how the metric should be combined over the time `scalein_window_minutes`.
[`scalein_window_minutes`](#scalein_window_minutes) | `number` | This is amount of time in minutes that autoscale engine will look back for metrics.
[`scalein_cooldown_minutes`](#scalein_cooldown_minutes) | `number` | Azure only considers deleting a VM after this number of minutes has passed since the last VM scaling action.
[`tags`](#tags) | `map(string)` | Map of tags to use for all the created resources.
[`bootstrap_options`](#bootstrap_options) | `string` | Bootstrap options to pass to VM-Series instance.
[`diagnostics_storage_uri`](#diagnostics_storage_uri) | `string` | The storage account's blob endpoint to hold diagnostic files.

## Module's Outputs

Name |  Description
--- | ---
[`scale_set_name`](#scale_set_name) | Name of the created scale set

## Module's Nameplate

Requirements needed by this module:

- `terraform`, version: >= 1.2, < 2.0
- `azurerm`, version: ~> 3.25

Providers used in this module:

- `azurerm`, version: ~> 3.25

Modules used in this module:
Name | Version | Source | Description
--- | --- | --- | ---

Resources used in this module:

- `linux_virtual_machine_scale_set` (managed)
- `monitor_autoscale_setting` (managed)

## Inputs/Outpus details

### Required Inputs


#### name

Name of the created scale set.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>

#### location

Region to install VM-Series and dependencies.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>

#### resource_group_name

Name of the existing resource group where to place the resources created.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>


#### interfaces

List of the network interface specifications.

NOTICE. The ORDER in which you specify the interfaces DOES MATTER.
Interfaces will be attached to VM in the order you define here, therefore:
* The first should be the management interface, which does not participate in data filtering.
* The remaining ones are the dataplane interfaces.
  
Options for an interface object:
- `name`                     - (required|string) Interface name.
- `subnet_id`                - (required|string) Identifier of an existing subnet to create interface in.
- `create_pip`               - (optional|bool) If true, create a public IP for the interface
- `lb_backend_pool_ids`      - (optional|list(string)) A list of identifiers of an existing Load Balancer backend pools to associate interface with.
- `appgw_backend_pool_ids`   - (optional|list(String)) A list of identifier of the Application Gateway backend pools to associate interface with.
- `pip_domain_name_label`    - (optional|string) The Prefix which should be used for the Domain Name Label for each Virtual Machine Instance.

Example:

```
[
  {
    name       = "management"
    subnet_id  = azurerm_subnet.my_mgmt_subnet.id
    create_pip = true
  },
  {
    name      = "private"
    subnet_id = azurerm_subnet.my_priv_subnet.id
  },
  {
    name                = "public"
    subnet_id           = azurerm_subnet.my_pub_subnet.id
    lb_backend_pool_ids = [azurerm_lb_backend_address_pool.lb_backend.id]
  }
]
```


Type: `list(any)`

<sup>[back to list](#modules-required-inputs)</sup>


#### password

Initial administrative password to use for VM-Series.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>




















#### img_version

VM-Series PAN-OS version - list available for a default `img_offer` with `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all`

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>





















### Optional Inputs





#### vm_size

Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported.

Type: `string`

Default value: `Standard_D3_v2`

<sup>[back to list](#modules-optional-inputs)</sup>


#### username

Initial administrative username to use for VM-Series.

Type: `string`

Default value: `panadmin`

<sup>[back to list](#modules-optional-inputs)</sup>


#### ssh_keys

A list of initial administrative SSH public keys that allow key-pair authentication. If not defined the `password` variable must be specified.
  
This is a list of strings, so each item should be the actual public key value. If you would like to load them from files instead, following method is available:

```
[
  file("/path/to/public/keys/key_1.pub"),
  file("/path/to/public/keys/key_2.pub")
]
```


Type: `list(string)`

Default value: `[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### disable_password_authentication

If true, disables password-based authentication on VM-Series instances.

Type: `bool`

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>

#### encryption_at_host_enabled

See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#encryption_at_host_enabled).

Type: `bool`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### overprovision

See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set).

Type: `bool`

Default value: `false`

<sup>[back to list](#modules-optional-inputs)</sup>

#### platform_fault_domain_count

See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set).

Type: `number`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### proximity_placement_group_id

See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set).

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scale_in_policy

Which virtual machines are chosen for removal when a Virtual Machine Scale Set is scaled in. Either:

- `Default`, which, baring the availability zone usage and fault domain usage, deletes VM with the highest-numbered instance id,
- `NewestVM`, which, baring the availability zone usage, deletes VM with the newest creation time,
- `OldestVM`, which, baring the availability zone usage, deletes VM with the oldest creation time.


Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scale_in_force_deletion

When set to `true` will force delete machines selected for removal by the `scale_in_policy`.

Type: `bool`

Default value: `false`

<sup>[back to list](#modules-optional-inputs)</sup>

#### single_placement_group

See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set).

Type: `bool`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### zone_balance

See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set).

Type: `bool`

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>

#### zones

The availability zones to use, for example `["1", "2", "3"]`. If an empty list, no Availability Zones are used: `[]`.

Type: `list(string)`

Default value: `[1 2 3]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### storage_account_type

Type of Managed Disk which should be created. Possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`. The `Premium_LRS` works only for selected `vm_size` values, details in Azure docs.

Type: `string`

Default value: `StandardSSD_LRS`

<sup>[back to list](#modules-optional-inputs)</sup>

#### disk_encryption_set_id

The ID of the Disk Encryption Set which should be used to encrypt this Data Disk.

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### use_custom_image

If true, use `custom_image_id` and ignore the inputs `username`, `password`, `img_version`, `img_publisher`, `img_offer`, `img_sku` (all these are used only for published images, not custom ones).

Type: `bool`

Default value: `false`

<sup>[back to list](#modules-optional-inputs)</sup>

#### custom_image_id

Absolute ID of your own Custom Image to be used for creating new VM-Series. The Custom Image is expected to contain PAN-OS software.

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### enable_plan

Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku "byol", which means "bring your own license", still requires accepting on the Marketplace (as of 2021). Can be set to `false` when using a custom image.

Type: `bool`

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>

#### img_publisher

The Azure Publisher identifier for a image which should be deployed.

Type: `string`

Default value: `paloaltonetworks`

<sup>[back to list](#modules-optional-inputs)</sup>

#### img_offer

The Azure Offer identifier corresponding to a published image. For `img_version` 9.1.1 or above, use "vmseries-flex"; for 9.1.0 or below use "vmseries1".

Type: `string`

Default value: `vmseries-flex`

<sup>[back to list](#modules-optional-inputs)</sup>

#### img_sku

VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`

Type: `string`

Default value: `byol`

<sup>[back to list](#modules-optional-inputs)</sup>


#### accelerated_networking

If true, enable Azure accelerated networking (SR-IOV) for all dataplane network interfaces. [Requires](https://docs.paloaltonetworks.com/pan-os/9-0/pan-os-new-features/virtualization-features/support-for-azure-accelerated-networking-sriov) PAN-OS 9.0 or higher. The PAN-OS management interface (nic0) is never accelerated, whether this variable is true or false.

Type: `bool`

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>

#### application_insights_id

An ID of Application Insights instance that should be used to provide metrics for autoscaling.

**Note**, to avoid false positives this should be an instance dedicated to this VMSS.
```


Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### autoscale_count_default

The minimum number of instances that should be present in the scale set when the autoscaling engine cannot read the metrics or is otherwise unable to compare the metrics to the thresholds.

Type: `number`

Default value: `2`

<sup>[back to list](#modules-optional-inputs)</sup>

#### autoscale_count_minimum

The minimum number of instances that should be present in the scale set.

Type: `number`

Default value: `2`

<sup>[back to list](#modules-optional-inputs)</sup>

#### autoscale_count_maximum

The maximum number of instances that should be present in the scale set.

Type: `number`

Default value: `5`

<sup>[back to list](#modules-optional-inputs)</sup>

#### autoscale_notification_emails

List of email addresses to notify about autoscaling events.

Type: `list(string)`

Default value: `[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### autoscale_webhooks_uris

Map where each key is an arbitrary identifier and each value is a webhook URI. The URIs receive autoscaling events.

Type: `map(string)`

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### autoscale_metrics

Map of objects, where each key is the metric name to be used for autoscaling.
Each value of the map has the attributes `scaleout_threshold` and `scalein_threshold`, which cause the instance count to grow by 1 when metrics are greater or equal, or decrease by 1 when lower or equal, respectively.
The thresholds are applied to results of metrics' aggregation over a time window.
Example:
```
{
  "DataPlaneCPUUtilizationPct" = {
    scaleout_threshold = 80
    scalein_threshold  = 20
  }
  "panSessionUtilization" = {
    scaleout_threshold = 80
    scalein_threshold  = 20
  }
}
```

Other possible metrics include panSessionActive, panSessionThroughputKbps, panSessionThroughputPps, DataPlanePacketBufferUtilization.


Type: `map(any)`

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scaleout_statistic

Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines. Possible values are Average, Min and Max.

Type: `string`

Default value: `Max`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scaleout_time_aggregation

Specifies how the metric should be combined over the time `scaleout_window_minutes`. Possible values are Average, Count, Maximum, Minimum, Last and Total.

Type: `string`

Default value: `Maximum`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scaleout_window_minutes

This is amount of time in minutes that autoscale engine will look back for metrics. For example, 10 minutes means that every time autoscale runs,
it will query metrics for the past 10 minutes. This allows metrics to stabilize and avoids reacting to transient spikes.
Must be between 5 and 720 minutes.


Type: `number`

Default value: `10`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scaleout_cooldown_minutes

Azure only considers adding a VM after this number of minutes has passed since the last VM scaling action. It should be much higher than `scaleout_window_minutes`, to account both for the VM-Series spin-up time and for the subsequent metrics stabilization time. Must be between 1 and 10080 minutes.

Type: `number`

Default value: `25`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scalein_statistic

Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines. Possible values are Average, Min and Max.

Type: `string`

Default value: `Max`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scalein_time_aggregation

Specifies how the metric should be combined over the time `scalein_window_minutes`. Possible values are Average, Count, Maximum, Minimum, Last and Total.

Type: `string`

Default value: `Maximum`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scalein_window_minutes

This is amount of time in minutes that autoscale engine will look back for metrics. For example, 10 minutes means that every time autoscale runs,
it will query metrics for the past 10 minutes. This allows metrics to stabilize and avoids reacting to transient spikes.
Must be between 5 and 720 minutes.


Type: `number`

Default value: `15`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scalein_cooldown_minutes

Azure only considers deleting a VM after this number of minutes has passed since the last VM scaling action. Should be higher or equal to `scalein_window_minutes`. Must be between 1 and 10080 minutes.

Type: `number`

Default value: `2880`

<sup>[back to list](#modules-optional-inputs)</sup>

#### tags

Map of tags to use for all the created resources.

Type: `map(string)`

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### bootstrap_options

Bootstrap options to pass to VM-Series instance.

Proper syntax is a string of semicolon separated properties.
Example:
  bootstrap_options = "type=dhcp-client;panorama-server=1.2.3.4"

For more details on bootstrapping see documentation: https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/init-cfgtxt-file-components


Type: `string`

Default value: ``

<sup>[back to list](#modules-optional-inputs)</sup>

#### diagnostics_storage_uri

The storage account's blob endpoint to hold diagnostic files.

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>


### Outputs


#### `scale_set_name`

Name of the created scale set.

<sup>[back to list](#modules-outputs)</sup>
<!-- END_TF_DOCS -->
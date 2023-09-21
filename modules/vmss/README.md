<!-- BEGIN_TF_DOCS -->


## Module's Required Inputs


- [`name`](#name)
- [`location`](#location)
- [`resource_group_name`](#resource_group_name)
- [`interfaces`](#interfaces)
- [`password`](#password)
- [`img_version`](#img_version)


### name

Name of the created scale set.

Type: `string`

### location

Region to install VM-Series and dependencies.

Type: `string`

### resource_group_name

Name of the existing resource group where to place the resources created.

Type: `string`


### interfaces

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


### password

Initial administrative password to use for VM-Series.

Type: `string`




















### img_version

VM-Series PAN-OS version - list available for a default `img_offer` with `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all`

Type: `string`





















## Module's Optional Inputs


- [`vm_size`](#vm_size)
- [`username`](#username)
- [`ssh_keys`](#ssh_keys)
- [`disable_password_authentication`](#disable_password_authentication)
- [`encryption_at_host_enabled`](#encryption_at_host_enabled)
- [`overprovision`](#overprovision)
- [`platform_fault_domain_count`](#platform_fault_domain_count)
- [`proximity_placement_group_id`](#proximity_placement_group_id)
- [`scale_in_policy`](#scale_in_policy)
- [`scale_in_force_deletion`](#scale_in_force_deletion)
- [`single_placement_group`](#single_placement_group)
- [`zone_balance`](#zone_balance)
- [`zones`](#zones)
- [`storage_account_type`](#storage_account_type)
- [`disk_encryption_set_id`](#disk_encryption_set_id)
- [`use_custom_image`](#use_custom_image)
- [`custom_image_id`](#custom_image_id)
- [`enable_plan`](#enable_plan)
- [`img_publisher`](#img_publisher)
- [`img_offer`](#img_offer)
- [`img_sku`](#img_sku)
- [`accelerated_networking`](#accelerated_networking)
- [`application_insights_id`](#application_insights_id)
- [`autoscale_count_default`](#autoscale_count_default)
- [`autoscale_count_minimum`](#autoscale_count_minimum)
- [`autoscale_count_maximum`](#autoscale_count_maximum)
- [`autoscale_notification_emails`](#autoscale_notification_emails)
- [`autoscale_webhooks_uris`](#autoscale_webhooks_uris)
- [`autoscale_metrics`](#autoscale_metrics)
- [`scaleout_statistic`](#scaleout_statistic)
- [`scaleout_time_aggregation`](#scaleout_time_aggregation)
- [`scaleout_window_minutes`](#scaleout_window_minutes)
- [`scaleout_cooldown_minutes`](#scaleout_cooldown_minutes)
- [`scalein_statistic`](#scalein_statistic)
- [`scalein_time_aggregation`](#scalein_time_aggregation)
- [`scalein_window_minutes`](#scalein_window_minutes)
- [`scalein_cooldown_minutes`](#scalein_cooldown_minutes)
- [`tags`](#tags)
- [`bootstrap_options`](#bootstrap_options)
- [`diagnostics_storage_uri`](#diagnostics_storage_uri)





### vm_size

Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported.

Type: `string`

Default value: `Standard_D3_v2`


### username

Initial administrative username to use for VM-Series.

Type: `string`

Default value: `panadmin`


### ssh_keys

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

### disable_password_authentication

If true, disables password-based authentication on VM-Series instances.

Type: `bool`

Default value: `true`

### encryption_at_host_enabled

See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#encryption_at_host_enabled).

Type: `bool`

Default value: `&{}`

### overprovision

See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set).

Type: `bool`

Default value: `false`

### platform_fault_domain_count

See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set).

Type: `number`

Default value: `&{}`

### proximity_placement_group_id

See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set).

Type: `string`

Default value: `&{}`

### scale_in_policy

Which virtual machines are chosen for removal when a Virtual Machine Scale Set is scaled in. Either:

- `Default`, which, baring the availability zone usage and fault domain usage, deletes VM with the highest-numbered instance id,
- `NewestVM`, which, baring the availability zone usage, deletes VM with the newest creation time,
- `OldestVM`, which, baring the availability zone usage, deletes VM with the oldest creation time.


Type: `string`

Default value: `&{}`

### scale_in_force_deletion

When set to `true` will force delete machines selected for removal by the `scale_in_policy`.

Type: `bool`

Default value: `false`

### single_placement_group

See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set).

Type: `bool`

Default value: `&{}`

### zone_balance

See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set).

Type: `bool`

Default value: `true`

### zones

The availability zones to use, for example `["1", "2", "3"]`. If an empty list, no Availability Zones are used: `[]`.

Type: `list(string)`

Default value: `[1 2 3]`

### storage_account_type

Type of Managed Disk which should be created. Possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`. The `Premium_LRS` works only for selected `vm_size` values, details in Azure docs.

Type: `string`

Default value: `StandardSSD_LRS`

### disk_encryption_set_id

The ID of the Disk Encryption Set which should be used to encrypt this Data Disk.

Type: `string`

Default value: `&{}`

### use_custom_image

If true, use `custom_image_id` and ignore the inputs `username`, `password`, `img_version`, `img_publisher`, `img_offer`, `img_sku` (all these are used only for published images, not custom ones).

Type: `bool`

Default value: `false`

### custom_image_id

Absolute ID of your own Custom Image to be used for creating new VM-Series. The Custom Image is expected to contain PAN-OS software.

Type: `string`

Default value: `&{}`

### enable_plan

Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku "byol", which means "bring your own license", still requires accepting on the Marketplace (as of 2021). Can be set to `false` when using a custom image.

Type: `bool`

Default value: `true`

### img_publisher

The Azure Publisher identifier for a image which should be deployed.

Type: `string`

Default value: `paloaltonetworks`

### img_offer

The Azure Offer identifier corresponding to a published image. For `img_version` 9.1.1 or above, use "vmseries-flex"; for 9.1.0 or below use "vmseries1".

Type: `string`

Default value: `vmseries-flex`

### img_sku

VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`

Type: `string`

Default value: `byol`


### accelerated_networking

If true, enable Azure accelerated networking (SR-IOV) for all dataplane network interfaces. [Requires](https://docs.paloaltonetworks.com/pan-os/9-0/pan-os-new-features/virtualization-features/support-for-azure-accelerated-networking-sriov) PAN-OS 9.0 or higher. The PAN-OS management interface (nic0) is never accelerated, whether this variable is true or false.

Type: `bool`

Default value: `true`

### application_insights_id

An ID of Application Insights instance that should be used to provide metrics for autoscaling.

**Note**, to avoid false positives this should be an instance dedicated to this VMSS.
```


Type: `string`

Default value: `&{}`

### autoscale_count_default

The minimum number of instances that should be present in the scale set when the autoscaling engine cannot read the metrics or is otherwise unable to compare the metrics to the thresholds.

Type: `number`

Default value: `2`

### autoscale_count_minimum

The minimum number of instances that should be present in the scale set.

Type: `number`

Default value: `2`

### autoscale_count_maximum

The maximum number of instances that should be present in the scale set.

Type: `number`

Default value: `5`

### autoscale_notification_emails

List of email addresses to notify about autoscaling events.

Type: `list(string)`

Default value: `[]`

### autoscale_webhooks_uris

Map where each key is an arbitrary identifier and each value is a webhook URI. The URIs receive autoscaling events.

Type: `map(string)`

Default value: `map[]`

### autoscale_metrics

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

### scaleout_statistic

Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines. Possible values are Average, Min and Max.

Type: `string`

Default value: `Max`

### scaleout_time_aggregation

Specifies how the metric should be combined over the time `scaleout_window_minutes`. Possible values are Average, Count, Maximum, Minimum, Last and Total.

Type: `string`

Default value: `Maximum`

### scaleout_window_minutes

This is amount of time in minutes that autoscale engine will look back for metrics. For example, 10 minutes means that every time autoscale runs,
it will query metrics for the past 10 minutes. This allows metrics to stabilize and avoids reacting to transient spikes.
Must be between 5 and 720 minutes.


Type: `number`

Default value: `10`

### scaleout_cooldown_minutes

Azure only considers adding a VM after this number of minutes has passed since the last VM scaling action. It should be much higher than `scaleout_window_minutes`, to account both for the VM-Series spin-up time and for the subsequent metrics stabilization time. Must be between 1 and 10080 minutes.

Type: `number`

Default value: `25`

### scalein_statistic

Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines. Possible values are Average, Min and Max.

Type: `string`

Default value: `Max`

### scalein_time_aggregation

Specifies how the metric should be combined over the time `scalein_window_minutes`. Possible values are Average, Count, Maximum, Minimum, Last and Total.

Type: `string`

Default value: `Maximum`

### scalein_window_minutes

This is amount of time in minutes that autoscale engine will look back for metrics. For example, 10 minutes means that every time autoscale runs,
it will query metrics for the past 10 minutes. This allows metrics to stabilize and avoids reacting to transient spikes.
Must be between 5 and 720 minutes.


Type: `number`

Default value: `15`

### scalein_cooldown_minutes

Azure only considers deleting a VM after this number of minutes has passed since the last VM scaling action. Should be higher or equal to `scalein_window_minutes`. Must be between 1 and 10080 minutes.

Type: `number`

Default value: `2880`

### tags

Map of tags to use for all the created resources.

Type: `map(string)`

Default value: `map[]`

### bootstrap_options

Bootstrap options to pass to VM-Series instance.

Proper syntax is a string of semicolon separated properties.
Example:
  bootstrap_options = "type=dhcp-client;panorama-server=1.2.3.4"

For more details on bootstrapping see documentation: https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/init-cfgtxt-file-components


Type: `string`

Default value: ``

### diagnostics_storage_uri

The storage account's blob endpoint to hold diagnostic files.

Type: `string`

Default value: `&{}`


## Module's Outputs


- [`scale_set_name`](#scale_set_name)


* `scale_set_name`: Name of the created scale set.

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
<!-- END_TF_DOCS -->
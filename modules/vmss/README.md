<!-- BEGIN_TF_DOCS -->
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

## SOme info about rolling upgrades

Allowing upgrade\_mode = "Rolling" would be actually a big architectural change. First of all
Error: `health_probe_id` must be set or a health extension must be specified when `upgrade_mode` is set to "Rolling"
VM-Series do not have a health extension
Having health\_probe\_id, as visible in the next error message below, Azure requires the first NIC to be
the load-balanced one. Azure complains about "inbound-nic-fw-mgmt", which in that case was the primary IP config
of the first NIC

```
Error: Error creating Linux Virtual Machine Scale Set "inbound-VMSS" (Resource Group "example-vmss-inbound")
compute.VirtualMachineScaleSetsClient#CreateOrUpdate: Failure sending request: StatusCode=0 -- Original Error

Code="CannotUseHealthProbeWithoutLoadBalancing"

Message="VM scale set /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/EXAMPLE-VMSS-INBOUND/providers/Microsoft.Compute/virtualMachineScaleSets/inbound-VMSS cannot use probe /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/example-vmss-inbound/providers/Microsoft.Network/loadBalancers/inbound-public-elb/probes/inbound-public-elb as a HealthProbe because primary IP configuration inbound-nic-fw-mgmt of the scale set does not use load balancing. LoadBalancerBackendAddressPools property of the IP configuration must reference backend address pool of the load balancer that contains the probe."
Details=[]
│
│   with module.inbound_scale_set.azurerm_linux_virtual_machine_scale_set.this
│   on ../../modules/vmss/main.tf line 1, in resource "azurerm_linux_virtual_machine_scale_set" "this"
│    1: resource "azurerm_linux_virtual_machine_scale_set" "this" {

```

Hence mgmt-interface-swap seems to be required on VM-Series, which would need a major overhaul of the
subnet-related inputs. Without the mgmt-interface-swap, it seems impossible to have upgrade\_mode = "Rolling"
The phony LB on a management network does not seem a viable solution. For now Azure does not support two internal
load balancers per VM. Also, health checking HTTP/SSH on management port would wrongly consider that unconfigured
VM-Series is good to use. Unconfigured VM-Series still shows HTTP/SSH on the management interface. This does not
happen when checking a dataplane interface, because the data only shows HTTP/SSH after the initial commit applies
a specific management profile
Also the inbound vmss would have the ethernet1/1 public and ethernet1/2 private, but outbound vmss would have
the ethernet1/1 private and ethernet1/2 public. That ensures the respective LB health probe works on ethernet1/1
which is the first NIC
The automatic\_instance\_repair also suffers from exactly the same problem
"Automatic repairs not supported for this Virtual Machine Scale Set because a health probe or health extension was not provided."

## Custom Metrics

Firewalls can publish custom metrics (for example `panSessionUtilization`) to Azure Application Insights to improve the autoscaling.
This however requires a manual initialization: copy the outputs `metrics_instrumentation_key` and paste it into your
PAN-OS webUI -> Device -> VM-Series -> Azure. This module automatically
completes solely the Step 1 of the [official procedure](https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/set-up-the-vm-series-firewall-on-azure/enable-azure-application-insights-on-the-vm-series-firewall.html).

If you manage the configuration from Panorama, this can be done in the same place, however the PAN-OS `VM-Series plugin` needs to be installed **on both** Panorama and VM-Series.

The metrics gathered within a single Azure Application Insights instance provided by the module, cannot be split to obtain
back a result for solely a single firewall. Thus for example if three firewalls use the same Instrumentation Key and report
their respective session utilizations as 90%, 20%, 10%, it is possible to see in Azure the average of 40%, the sum of 120%, the max of 90%, but it is *not possible* to know which of the firewalls reported the 90% utilization.

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`name`](#name) | `string` | The name of the Azure Virtual Machine Scale Set.
[`resource_group_name`](#resource_group_name) | `string` | The name of the Resource Group to use.
[`location`](#location) | `string` | The name of the Azure region to deploy the resources in.
[`authentication`](#authentication) | `object` | A map defining authentication settings (including username and password).
[`vm_image_configuration`](#vm_image_configuration) | `object` | Basic Azure VM configuration.
[`scale_set_configuration`](#scale_set_configuration) | `object` | Scale set parameters configuration.
[`interfaces`](#interfaces) | `list` | List of the network interfaces specifications.
[`autoscaling_configuration`](#autoscaling_configuration) | `any` | Autoscaling configuration common to all policies

Following properties are available:
- `application_insights_id`

- 
.


## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`tags`](#tags) | `map` | The map of tags to assign to all created resources.
[`bootstrap_options`](#bootstrap_options) | `string` | Bootstrap options to pass to VM-Series instance.
[`diagnostics_storage_uri`](#diagnostics_storage_uri) | `string` | The storage account's blob endpoint to hold diagnostic files.
[`scale_in_policy`](#scale_in_policy) | `string` | Which virtual machines are chosen for removal when a Virtual Machine Scale Set is scaled in.
[`scale_in_force_deletion`](#scale_in_force_deletion) | `bool` | When set to `true` will force delete machines selected for removal by the `scale_in_policy`.
[`application_insights_id`](#application_insights_id) | `string` | An ID of Application Insights instance that should be used to provide metrics for autoscaling.
[`autoscale_count_default`](#autoscale_count_default) | `number` | The minimum number of instances that should be present in the scale set when the autoscaling engine cannot read the metrics or is otherwise unable to compare the metrics to the thresholds.
[`autoscale_notification_emails`](#autoscale_notification_emails) | `list` | List of email addresses to notify about autoscaling events.
[`autoscale_webhooks_uris`](#autoscale_webhooks_uris) | `map` | Map where each key is an arbitrary identifier and each value is a webhook URI.
[`autoscale_count_minimum`](#autoscale_count_minimum) | `number` | The minimum number of instances that should be present in the scale set.
[`autoscale_count_maximum`](#autoscale_count_maximum) | `number` | The maximum number of instances that should be present in the scale set.
[`autoscale_metrics`](#autoscale_metrics) | `map` | Map of objects, where each key is the metric name to be used for autoscaling.
[`scaleout_statistic`](#scaleout_statistic) | `string` | Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines.
[`scaleout_time_aggregation`](#scaleout_time_aggregation) | `string` | Specifies how the metric should be combined over the time `scaleout_window_minutes`.
[`scaleout_window_minutes`](#scaleout_window_minutes) | `number` | This is amount of time in minutes that autoscale engine will look back for metrics.
[`scaleout_cooldown_minutes`](#scaleout_cooldown_minutes) | `number` | Azure only considers adding a VM after this number of minutes has passed since the last VM scaling action.
[`scalein_statistic`](#scalein_statistic) | `string` | Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines.
[`scalein_time_aggregation`](#scalein_time_aggregation) | `string` | Specifies how the metric should be combined over the time `scalein_window_minutes`.
[`scalein_window_minutes`](#scalein_window_minutes) | `number` | This is amount of time in minutes that autoscale engine will look back for metrics.
[`scalein_cooldown_minutes`](#scalein_cooldown_minutes) | `number` | Azure only considers deleting a VM after this number of minutes has passed since the last VM scaling action.



## Module's Outputs

Name |  Description
--- | ---
`scale_set_name` | Name of the created scale set.

## Module's Nameplate


Requirements needed by this module:

- `terraform`, version: >= 1.2, < 2.0
- `azurerm`, version: ~> 3.25


Providers used in this module:

- `azurerm`, version: ~> 3.25




Resources used in this module:

- `linux_virtual_machine_scale_set` (managed)
- `monitor_autoscale_setting` (managed)

## Inputs/Outpus details

### Required Inputs


#### name

The name of the Azure Virtual Machine Scale Set.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>

#### resource_group_name

The name of the Resource Group to use.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>

#### location

The name of the Azure region to deploy the resources in.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>


#### authentication

A map defining authentication settings (including username and password).

Following properties are available:

- `username`                        - (`string`, optional, defaults to `panadmin`) the initial administrative VMseries username
- `password`                        - (`string`, optional, defaults to `null`) the initial administrative VMSeries password
- `disable_password_authentication` - (`bool`, optional, defaults to `true`) disables password-based authentication
- `ssh_keys`                        - (`list`, optional, defaults to `[]`) a list of initial administrative SSH public keys

> [!Important]
> The `password` property is required when `ssh_keys` is not specified.

> [!Important]
> `ssh_keys` property is a list of strings, so each item should be the actual public key value.
> If you would like to load them from files use the `file` function.
> For example: `[ file("/path/to/public/keys/key_1.pub") ]`.



Type: 

```hcl
object({
    username                        = optional(string, "panadmin")
    password                        = optional(string)
    disable_password_authentication = optional(bool, true)
    ssh_keys                        = optional(list(string), [])
  })
```


<sup>[back to list](#modules-required-inputs)</sup>

#### vm_image_configuration

Basic Azure VM configuration.

Following properties are available:

- `img_version`             - (`string`, optional, defaults to `null`) VMSeries PAN-OS version; list available with 
                              `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all`
- `img_publisher`           - (`string`, optional, defaults to `paloaltonetworks`) the Azure Publisher identifier for a image
                              which should be deployed
- `img_offer`               - (`string`, optional, defaults to `vmseries-flex`) the Azure Offer identifier corresponding to a
                              published image
- `img_sku`                 - (`string`, optional, defaults to `byol`) VMSeries SKU; list available with
                              `az vm image list -o table --all --publisher paloaltonetworks`
- `enable_marketplace_plan` - (`bool`, optional, defaults to `true`) when set to `true` accepts the license for a offer/plan
                              on Azure Market Place
- `custom_image_id`         - (`string`, optional, defaults to `null`) absolute ID of your own custom PanOS image to be used for
                              creating new Virtual Machines

> [!Important]
> `custom_image_id` and `img_version` properties are mutually exclusive.


Type: 

```hcl
object({
    img_version             = optional(string)
    img_publisher           = optional(string, "paloaltonetworks")
    img_offer               = optional(string, "vmseries-flex")
    img_sku                 = optional(string, "byol")
    enable_marketplace_plan = optional(bool, true)
    custom_image_id         = optional(string)
  })
```


<sup>[back to list](#modules-required-inputs)</sup>

#### scale_set_configuration

Scale set parameters configuration.

This map contains basic, as well as some optional Virtual Machine Scale Set parameters. Both types contain sane defaults.
Nevertheless they should be at least reviewed to meet deployment requirements.

List of either required or important properties: 

- `vm_size`               - (`string`, optional, defaults to `Standard_D3_v2`) Azure VM size (type). Consult the *VM-Series
                            Deployment Guide* as only a few selected sizes are supported
- `zones`                 - (`list`, optional, defaults to `["1", "2", "3"]`) a list of Availability Zones in which VMs from
                            this Scale Set will be created
- `storage_account_type`  - (`string`, optional, defaults to `StandardSSD_LRS`) type of Managed Disk which should be created,
                            possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS` (works only for selected
                            `vm_size` values)

List of other, optional properties: 

- `accelerated_networking`        - (`bool`, optional, defaults to `true`) when set to `true`  enables Azure accelerated
                                    networking (SR-IOV) for all dataplane network interfaces, this does not affect the
                                    management interface (always disabled)
- `disk_encryption_set_id`        - (`string`, optional, defaults to `null`) the ID of the Disk Encryption Set which should be
                                    used to encrypt this VM's disk
- `zone_balance`                  - (`bool`, optional, defaults to `true`) when set to `true` VMs in this Scale Set will be
                                    evenly distributed across configured Availability Zones
- `encryption_at_host_enabled`    - (`bool`, optional, defaults to Azure defaults) should all of disks be encrypted
                                    by enabling Encryption at Host
- `overprovision`                 - (`bool`, optional, defaults to `true`) See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)
- `platform_fault_domain_count`   - (`number`, optional, defaults to Azure defaults) specifies the number of fault domains that
                                    are used by this Virtual Machine Scale Set
- `proximity_placement_group_id`  - (`string`, optional, defaults to Azure defaults) the ID of the Proximity Placement Group
                                    in which the Virtual Machine Scale Set should be assigned to
- `single_placement_group`        - (`bool`, defaults to Azure defaults) when `true` this Virtual Machine Scale Set will be
                                    limited to a Single Placement Group, which means the number of instances will be capped
                                    at 100 Virtual Machines



Type: 

```hcl
object({
    vm_size                      = optional(string, "Standard_D3_v2")
    zones                        = optional(list(string), ["1", "2", "3"])
    zone_balance                 = optional(bool, true)
    storage_account_type         = optional(string, "StandardSSD_LRS")
    accelerated_networking       = optional(bool, true)
    encryption_at_host_enabled   = optional(bool)
    overprovision                = optional(bool, true)
    platform_fault_domain_count  = optional(number)
    proximity_placement_group_id = optional(string)
    disk_encryption_set_id       = optional(string)
  })
```


<sup>[back to list](#modules-required-inputs)</sup>



#### interfaces

List of the network interfaces specifications.

> [!Notice]
> The ORDER in which you specify the interfaces DOES MATTER.

Interfaces will be attached to VM in the order you define here, therefore:

- the first should be the management interface, which does not participate in data filtering
- the remaining ones are the dataplane interfaces.
  
Following configuration options are available:

- `name`                      - (`string`, required) the interface name
- `subnet_id`                 - (`string`, required) ID of an existing subnet to create the interface in
- `create_public_ip`          - (`bool`, optional, defaults to `false`) if `true`, create a public IP for the interface
- `lb_backend_pool_ids`       - (`list`, optional, defaults to `[]`) a list of identifiers of existing Load Balancer backend
                                pools to associate the interface with
- `appgw_backend_pool_ids`    - (`list`, optional, defaults to `[]`) a list of identifier of Application Gateway's backend
                                pools to associate the interface with
- `pip_domain_name_label`     - (`string`, optional, defaults to `null`) the Prefix which should be used for the Domain Name
                                Label for each Virtual Machine Instance.

Example:

```hcl
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


Type: 

```hcl
list(object({
    name                   = string
    subnet_id              = string
    create_public_ip       = optional(bool, false)
    lb_backend_pool_ids    = optional(list(string), [])
    appgw_backend_pool_ids = optional(list(string), [])
    pip_domain_name_label  = optional(string)
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>

#### autoscaling_configuration

Autoscaling configuration common to all policies

Following properties are available:
- `application_insights_id`

- 


Type: any

<sup>[back to list](#modules-required-inputs)</sup>




















### Optional Inputs





#### tags

The map of tags to assign to all created resources.

Type: map(string)

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>




#### bootstrap_options

Bootstrap options to pass to VM-Series instance.

Proper syntax is a string of semicolon separated properties, for example:
`bootstrap_options = "type=dhcp-client;panorama-server=1.2.3.4"`

For more details on bootstrapping [see documentation](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/init-cfgtxt-file-components).


Type: string

Default value: ``

<sup>[back to list](#modules-optional-inputs)</sup>

#### diagnostics_storage_uri

The storage account's blob endpoint to hold diagnostic files.

Type: string

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>



#### scale_in_policy

Which virtual machines are chosen for removal when a Virtual Machine Scale Set is scaled in. Either:

- `Default`, which, baring the availability zone usage and fault domain usage, deletes VM with the highest-numbered instance id,
- `NewestVM`, which, baring the availability zone usage, deletes VM with the newest creation time,
- `OldestVM`, which, baring the availability zone usage, deletes VM with the oldest creation time.


Type: string

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scale_in_force_deletion

When set to `true` will force delete machines selected for removal by the `scale_in_policy`.

Type: bool

Default value: `false`

<sup>[back to list](#modules-optional-inputs)</sup>

#### application_insights_id

An ID of Application Insights instance that should be used to provide metrics for autoscaling.

**Note**, to avoid false positives this should be an instance dedicated to this VMSS.
```


Type: string

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### autoscale_count_default

The minimum number of instances that should be present in the scale set when the autoscaling engine cannot read the metrics or is otherwise unable to compare the metrics to the thresholds.

Type: number

Default value: `2`

<sup>[back to list](#modules-optional-inputs)</sup>

#### autoscale_notification_emails

List of email addresses to notify about autoscaling events.

Type: list(string)

Default value: `[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### autoscale_webhooks_uris

Map where each key is an arbitrary identifier and each value is a webhook URI. The URIs receive autoscaling events.

Type: map(string)

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### autoscale_count_minimum

The minimum number of instances that should be present in the scale set.

Type: number

Default value: `2`

<sup>[back to list](#modules-optional-inputs)</sup>

#### autoscale_count_maximum

The maximum number of instances that should be present in the scale set.

Type: number

Default value: `5`

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


Type: map(any)

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scaleout_statistic

Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines. Possible values are Average, Min and Max.

Type: string

Default value: `Max`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scaleout_time_aggregation

Specifies how the metric should be combined over the time `scaleout_window_minutes`. Possible values are Average, Count, Maximum, Minimum, Last and Total.

Type: string

Default value: `Maximum`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scaleout_window_minutes

This is amount of time in minutes that autoscale engine will look back for metrics. For example, 10 minutes means that every time autoscale runs,
it will query metrics for the past 10 minutes. This allows metrics to stabilize and avoids reacting to transient spikes.
Must be between 5 and 720 minutes.


Type: number

Default value: `10`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scaleout_cooldown_minutes

Azure only considers adding a VM after this number of minutes has passed since the last VM scaling action. It should be much higher than `scaleout_window_minutes`, to account both for the VM-Series spin-up time and for the subsequent metrics stabilization time. Must be between 1 and 10080 minutes.

Type: number

Default value: `25`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scalein_statistic

Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines. Possible values are Average, Min and Max.

Type: string

Default value: `Max`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scalein_time_aggregation

Specifies how the metric should be combined over the time `scalein_window_minutes`. Possible values are Average, Count, Maximum, Minimum, Last and Total.

Type: string

Default value: `Maximum`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scalein_window_minutes

This is amount of time in minutes that autoscale engine will look back for metrics. For example, 10 minutes means that every time autoscale runs,
it will query metrics for the past 10 minutes. This allows metrics to stabilize and avoids reacting to transient spikes.
Must be between 5 and 720 minutes.


Type: number

Default value: `15`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scalein_cooldown_minutes

Azure only considers deleting a VM after this number of minutes has passed since the last VM scaling action. Should be higher or equal to `scalein_window_minutes`. Must be between 1 and 10080 minutes.

Type: number

Default value: `2880`

<sup>[back to list](#modules-optional-inputs)</sup>


<!-- END_TF_DOCS -->
<!-- BEGIN_TF_DOCS -->
---
short\_title: Dedicated Firewall Option with Autoscaling
type: refarch
show\_in\_hub: true
---
# Reference Architecture with Terraform: VM-Series in Azure, Centralized Architecture, Dedicated Inbound NGFW Option with Autoscaling

Palo Alto Networks produces several
[validated reference architecture design and deployment documentation guides](https://www.paloaltonetworks.com/resources/reference-architectures),
which describe well-architected and tested deployments. When deploying VM-Series in a public cloud, the reference architectures
guide users toward the best security outcomes, whilst reducing rollout time and avoiding common integration efforts.

The Terraform code presented here will deploy Palo Alto Networks VM-Series firewalls in Azure based on a centralized design with
dedicated-inbound VM-Series with autoscaling(Virtual Machine Scale Sets); for a discussion of other options, please see the design
guide from [the reference architecture guides](https://www.paloaltonetworks.com/resources/reference-architectures).

Virtual Machine Scale Sets (VMSS) are used for autoscaling to run the Next Generation Firewalls, with custom data plane oriented
metrics published by PanOS it is possible to adjust the number of firewall appliances to the current workload (data plane
utilization). Since firewalls are added or removed automatically, they cannot be managed in a classic way. Therefore they are not
assigned with public IP addresses. To ease licensing, management and updates a Panorama appliance is suggested. Deployment of a
Panorama instance is not covered in this example, but a [dedicated one exists](../standalone\_panorama/README.md).

## Reference Architecture Design

![simple](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/assets/6574404/a7c2452d-f926-49da-bf21-9d840282a0a2)

This code implements:

- a *centralized design*, a hub-and-spoke topology with a Transit VNet containing VM-Series to inspect all inbound, outbound,
  east-west, and enterprise traffic
- the *dedicated inbound option*, which separates inbound traffic flows onto a separate set of VM-Series
- *auto scaling* for the VM-Series, where Virtual Machine Scale Sets (VMSS) are used to provision VM-Series that will scale in and
  out dynamically, as workload demands fluctuate

## Detailed Architecture and Design

### Centralized Design

This design uses a Transit VNet. Application functions and resources are deployed across multiple VNets that are connected in a
hub-and-spoke topology. The hub of the topology, or transit VNet, is the central point of connectivity for all inbound, outbound,
east-west, and enterprise traffic. You deploy all VM-Series firewalls within the transit VNet.

### Dedicated Inbound Option

The dedicated inbound option separates traffic flows across two separate sets of VM-Series firewalls. One set of VM-Series
firewalls is dedicated to inbound traffic flows, allowing for greater flexibility and scaling of inbound traffic loads. The second
set of VM-Series firewalls services all outbound, east-west, and enterprise network traffic flows. This deployment choice offers
increased scale and operational resiliency and reduces the chances of high bandwidth use from the inbound traffic flows affecting
other traffic flows within the deployment.

![Dedicated-VMSeries-with-autoscaling](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/assets/2110772/be84d4cb-c4c0-4e62-8bd7-8f5050215876)

This reference architecture consists of:

- a VNET containing:
  - 4 subnets:
    - 3 of them dedicated to the firewalls: management, private and public
    - one dedicated to an Application Gateway
  - Route Tables and Network Security Groups
- 2 Virtual Machine Scale sets:
  - one for inbound, one for outbound and east-west traffic
  - with 3 network interfaces: management, public, private
  - no public addresses are assigned to firewalls' interfaces
- 2 Load Balancers:
  - public - with a public IP address assigned, in front of the public interfaces of the inbound VMSS, for incoming traffic
  - private - in front of the firewalls private interfaces of the OBEW VMSS, for outgoing and east-west traffic
- a NAT Gateway responsible for handling the outgoing traffic for the management (updates) and public (outbound traffic in OBEW
- firewalls mainly) interfaces
- 2 Application Insights, one per each scale set, used to store the custom PanOS metrics
- an Application Gateway, serving as a reverse proxy for incoming traffic, with a sample rule setting the XFF header properly

A note on resiliency - this is an example of a none zonal deployment. Resiliency is maintained by using fault domains (Scale Set's
default mechanism).

### Auto Scaling VM-Series

Auto scaling: Public-cloud environments focus on scaling out a deployment instead of scaling up. This architectural difference
stems primarily from the capability of public-cloud environments to dynamically increase or decrease the number of resources
allocated to your environment. Using native Azure services like Virtual Machine Scale Sets (VMSS), Application Insights and
VM-Series automation features, the guide implements VM-Series that will scale in and out dynamically, as your protected workload
demands fluctuate. The VM-Series firewalls are deployed in separate Virtual Machine Scale Sets for inbound and outbound/east-west
firewalls, and are automatically registered to Azure Load Balancers.

## Prerequisites

A list of requirements might vary depending on the platform used to deploy the infrastructure but a minimum one includes:

- (in case of non cloud shell deployment) credentials and (optionally) tools required to authenticate against Azure Cloud, see
  [AzureRM provider documentation for details](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure)
- [supported](#requirements) version of [`Terraform`](<https://developer.hashicorp.com/terraform/downloads>)
- if you have not run Palo Alto NGFW images in a subscription it might be necessary to accept the license first
  ([see this note](../../modules/vmseries/README.md#accept-azure-marketplace-terms))

A non-platform requirement would be a running Panorama instance. For full automation you might want to consider the following
requirements:

- a template and a template stack with `DAY0` configuration
- a device group with security configuration (`DAY1` [iron skillet](https://github.com/PaloAltoNetworks/iron-skillet) for example)
  and any security and NAT rules of your choice
- a [Panorama Software Firewall License](https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/license-the-vm-series-firewall/use-panorama-based-software-firewall-license-management) plugin to automatically manage licenses on newly created devices
- a [VM-Series](https://docs.paloaltonetworks.com/panorama/9-1/panorama-admin/panorama-plugins/plugins-types/install-the-vm-series-plugin-on-panorama)
  plugin to enable additional template options (custom metrics)

**Note!**

- after the deployment the firewalls remain not configured and not licensed.
- this example contains some **files** that **can contain sensitive data**. Keep in mind that **this code** is
  **only an example**. It's main purpose is to introduce the Terraform modules.

## Usage

### Deployment Steps

- checkout the code locally (if you haven't done so yet)
- copy the [`example.tfvars`](./example.tfvars) file, rename it to `terraform.tfvars` and adjust it to your needs (take a closer
  look at the `TODO` markers). If you already have a configured Panorama (with at least minimum configuration described above) you
  might want to also adjust the `bootstrap_options` for each scale set ([inbound](./example.tfvars#L205) and
  [obew](./example.tfvars#L249) separately).
- (optional) authenticate to AzureRM, switch to the Subscription of your choice if necessary
- initialize the Terraform module:

  ```bash
  terraform init
  ```

- (optional) plan you infrastructure to see what will be actually deployed:

  ```bash
  terraform plan
  ```

- deploy the infrastructure (you will have to confirm it with typing in `yes`):

  ```bash
  terraform apply
  ```

  The deployment takes couple of minutes. Observe the output. At the end you should see a summary similar to this:

  ```console
  Apply complete! Resources: 52 added, 0 changed, 0 destroyed.

  Outputs:

  lb_frontend_ips = {
    "private" = {
      "ha-ports" = "1.2.3.4"
    }
    "public" = {
      "palo-lb-app1-pip" = "1.2.3.4"
    }
  }
  metrics_instrumentation_keys = <sensitive>
  password = <sensitive>
  username = "panadmin"
  ```

- at this stage you have to wait couple of minutes for the firewalls to bootstrap.

### Post deploy

The most important post-deployment action is (for deployments with auto scaling and Panorama) to retrieve the Application Insights
instrumentation keys. This can be done by looking up the AI resources in the Azure portal, or directly from Terraform outputs:

```bash
terraform output metrics_instrumentation_keys
```

The retrieved keys should be put into appropriate templates in Panorama and pushed to the devices. From this moment on, custom
metrics are being sent to Application Insights and retrieved by Virtual Machine Scale Sets to trigger scale-in and scale-out
operations.

Although firewalls in a Scale Set are not meant to be managed directly, they are still configured with password authentication.
To retrieve the initial credentials run:

- for username:

  ```bash
  terraform output username
  ```

- for password:

  ```bash
  terraform output password
  ```

### Cleanup

To remove the deployed infrastructure run:

```bash
terraform destroy
```

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`location`](#location) | `string` | The Azure region to use.
[`resource_group_name`](#resource_group_name) | `string` | Name of the Resource Group.
[`vnets`](#vnets) | `map` | A map defining VNETs.


## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`tags`](#tags) | `map` | Map of tags to assign to the created resources.
[`name_prefix`](#name_prefix) | `string` | A prefix that will be added to all created resources.
[`create_resource_group`](#create_resource_group) | `bool` | When set to `true` it will cause a Resource Group creation.
[`natgws`](#natgws) | `map` | A map defining NAT Gateways.
[`load_balancers`](#load_balancers) | `map` | A map containing configuration for all (private and public) Load Balancers.
[`ngfw_metrics`](#ngfw_metrics) | `object` | A map controlling metrics-relates resources.
[`scale_sets`](#scale_sets) | `map` | A map defining Azure Virtual Machine Scale Sets based on Palo Alto Networks Next Generation Firewall image.
[`appgws`](#appgws) | `map` | A map defining all Application Gateways in the current deployment.



## Module's Outputs

Name |  Description
--- | ---
`usernames` | Initial firewall administrative usernames for all deployed Scale Sets.
`passwords` | Initial firewall administrative passwords for all deployed Scale Sets.
`metrics_instrumentation_keys` | The Instrumentation Key of the created instance(s) of Azure Application Insights.
`lb_frontend_ips` | IP Addresses of the load balancers.

## Module's Nameplate




Providers used in this module:

- `random`
- `azurerm`


Modules used in this module:
Name | Version | Source | Description
--- | --- | --- | ---
`vnet` | - | ../../modules/vnet | Manage the network required for the topology.
`natgw` | - | ../../modules/natgw | 
`load_balancer` | - | ../../modules/loadbalancer | create load balancers, both internal and external
`ngfw_metrics` | - | ../../modules/ngfw_metrics | 
`appgw` | - | ../../modules/appgw | 
`vmss` | - | ../../modules/vmss | 


Resources used in this module:

- `resource_group` (managed)
- `password` (managed)
- `resource_group` (data)

## Inputs/Outpus details

### Required Inputs



#### location

The Azure region to use.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>



#### resource_group_name

Name of the Resource Group.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>

#### vnets

A map defining VNETs.
  
For detailed documentation on each property refer to [module documentation](../../modules/vnet/README.md)

- `create_virtual_network`  - (`bool`, optional, defaults to `true`) when set to `true` will create a VNET, 
                              `false` will source an existing VNET.
- `name`                    - (`string`, required) a name of a VNET. In case `create_virtual_network = false` this should be
                              a full resource name, including prefixes.
- `address_space`           - (`list(string)`, required when `create_virtual_network = false`) a list of CIDRs for a newly
                              created VNET
- `resource_group_name`     - (`string`, optional, defaults to current RG) a name of an existing Resource Group in which
                              the VNET will reside or is sourced from
- `create_subnets`          - (`bool`, optional, defaults to `true`) if `true`, create Subnets inside the Virtual Network,
                              otherwise use source existing subnets
- `subnets`                 - (`map`, optional) map of Subnets to create or source, for details see
                              [VNET module documentation](../../modules/vnet/README.md#subnets)
- `network_security_groups` - (`map`, optional) map of Network Security Groups to create, for details see
                              [VNET module documentation](../../modules/vnet/README.md#network_security_groups)
- `route_tables`            - (`map`, optional) map of Route Tables to create, for details see
                              [VNET module documentation](../../modules/vnet/README.md#route_tables)


Type: 

```hcl
map(object({
    name                   = string
    resource_group_name    = optional(string)
    create_virtual_network = optional(bool, true)
    address_space          = optional(list(string))
    network_security_groups = optional(map(object({
      name = string
      rules = optional(map(object({
        name                         = string
        priority                     = number
        direction                    = string
        access                       = string
        protocol                     = string
        source_port_range            = optional(string)
        source_port_ranges           = optional(list(string))
        destination_port_range       = optional(string)
        destination_port_ranges      = optional(list(string))
        source_address_prefix        = optional(string)
        source_address_prefixes      = optional(list(string))
        destination_address_prefix   = optional(string)
        destination_address_prefixes = optional(list(string))
      })), {})
    })), {})
    route_tables = optional(map(object({
      name                          = string
      disable_bgp_route_propagation = optional(bool)
      routes = map(object({
        name                = string
        address_prefix      = string
        next_hop_type       = string
        next_hop_ip_address = optional(string)
      }))
    })), {})
    create_subnets = optional(bool, true)
    subnets = optional(map(object({
      name                            = string
      address_prefixes                = optional(list(string), [])
      network_security_group_key      = optional(string)
      route_table_key                 = optional(string)
      enable_storage_service_endpoint = optional(bool, false)
    })), {})
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>








### Optional Inputs


#### tags

Map of tags to assign to the created resources.

Type: map(string)

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>


#### name_prefix

A prefix that will be added to all created resources.
There is no default delimiter applied between the prefix and the resource name.
Please include the delimiter in the actual prefix.

Example:
```
name_prefix = "test-"
```
  
**Note!** \
This prefix is not applied to existing resources. If you plan to reuse i.e. a VNET please specify it's full name,
even if it is also prefixed with the same value as the one in this property.


Type: string

Default value: ``

<sup>[back to list](#modules-optional-inputs)</sup>

#### create_resource_group

When set to `true` it will cause a Resource Group creation.
Name of the newly specified RG is controlled by `resource_group_name`.
  
When set to `false` the `resource_group_name` parameter is used to specify a name of an existing Resource Group.


Type: bool

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>



#### natgws

A map defining NAT Gateways. 

Please note that a NAT Gateway is a zonal resource, this means it's always placed in a zone (even when you do not specify one
explicitly). Please refer to Microsoft documentation for notes on NAT Gateway's zonal resiliency.
For detailed documentation on each property refer to [module documentation](../../modules/natgw/README.md).
  
Following properties are supported:
- `create_natgw`       - (`bool`, optional, defaults to `true`) create (`true`) or source an existing NAT Gateway (`false`),
                         created or sourced: the NAT Gateway will be assigned to a subnet created by the `vnet` module.
- `name`               - (`string`, required) a name of a NAT Gateway. In case `create_natgw = false` this should be a full
                         resource name, including prefixes.
- `resource_group_name - (`string`, optional) name of a Resource Group hosting the NAT Gateway (newly created or the existing
                         one).
- `zone`               - (`string`, optional) an Availability Zone in which the NAT Gateway will be placed, when skipped
                         AzureRM will pick a zone.
- `idle_timeout`       - (`number`, optional, defults to 4) connection IDLE timeout in minutes, for newly created resources.
- `vnet_key`           - (`string`, required) a name (key value) of a VNET defined in `var.vnets` that hosts a subnet this
                         NAT Gateway will be assigned to.
- `subnet_keys`        - (`list(string)`, required) a list of subnets (key values) the NAT Gateway will be assigned to, defined
                         in `var.vnets` for a VNET described by `vnet_name`.
- `public_ip`          - (`object`, optional) an object defining a public IP resource attached to the NAT Gateway.
- `public_ip_prefix`   - (`object`, optional) an object defining a public IP prefix resource attached to the NAT Gatway.

Example:
```
natgws = {
  "natgw" = {
    name        = "natgw"
    vnet_key    = "transit-vnet"
    subnet_keys = ["management"]
    public_ip = {
      create = true
      name   = "natgw-pip"
    }
  }
}
```


Type: 

```hcl
map(object({
    create_natgw        = optional(bool, true)
    name                = string
    resource_group_name = optional(string)
    zone                = optional(string)
    idle_timeout        = optional(number, 4)
    vnet_key            = string
    subnet_keys         = list(string)
    public_ip = optional(object({
      create              = bool
      name                = string
      resource_group_name = optional(string)
    }))
    public_ip_prefix = optional(object({
      create              = bool
      name                = string
      resource_group_name = optional(string)
      length              = optional(number)
    }))
  }))
```


Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### load_balancers

A map containing configuration for all (private and public) Load Balancers.

This is a brief description of available properties. For a detailed one please refer to
[module documentation](../../modules/loadbalancer/README.md).

Following properties are available:

- `name`                    - (`string`, required) a name of the Load Balancer
- `zones`                   - (`list`, optional, defaults to `["1", "2", "3"]`) list of zones the resource will be
                              available in, please check the
                              [module documentation](../../modules/loadbalancer/README.md#zones) for more details
- `health_probes`           - (`map`, optional, defaults to `null`) a map defining health probes that will be used by
                              load balancing rules;
                              please check [module documentation](../../modules/loadbalancer/README.md#health_probes)
                              for more specific use cases and available properties
- `nsg_auto_rules_settings` - (`map`, optional, defaults to `null`) a map defining a location of an existing NSG rule
                              that will be populated with `Allow` rules for each load balancing rule (`in_rules`); please check 
                              [module documentation](../../modules/loadbalancer/README.md#nsg_auto_rules_settings)
                              for available properties; please note that in this example two additional properties are
                              available:
  - `nsg_key`         - (`string`, optional, mutually exclusive with `nsg_name`) a key pointing to an NSG definition
                        in the `var.vnets` map
  - `nsg_vnet_key`    - (`string`, optional, mutually exclusive with `nsg_name`) a key pointing to a VNET definition
                        in the `var.vnets` map that stores the NSG described by `nsg_key`
- `frontend_ips`            - (`map`, optional, defaults to `{}`) a map containing frontend IP configuration with respective
                              `in_rules` and `out_rules`

  Please refer to [module documentation](../../modules/loadbalancer/README.md#frontend_ips) for available properties.

  > [!NOTE] 
  > In this example the `subnet_id` is not available directly, three other properties were introduced instead.

  - `subnet_key`  - (`string`, optional, defaults to `null`) a key pointing to a Subnet definition in the `var.vnets` map
  - `vnet_key`    - (`string`, optional, defaults to `null`) a key pointing to a VNET definition in the `var.vnets` map
                    that stores the Subnet described by `subnet_key`


Type: 

```hcl
map(object({
    name  = string
    zones = optional(list(string), ["1", "2", "3"])
    health_probes = optional(map(object({
      name                = string
      protocol            = string
      port                = optional(number)
      probe_threshold     = optional(number)
      interval_in_seconds = optional(number)
      request_path        = optional(string)
    })))
    nsg_auto_rules_settings = optional(object({
      nsg_name                = optional(string)
      nsg_vnet_key            = optional(string)
      nsg_key                 = optional(string)
      nsg_resource_group_name = optional(string)
      source_ips              = list(string)
      base_priority           = optional(number)
    }))
    frontend_ips = optional(map(object({
      name                          = string
      public_ip_name                = optional(string)
      create_public_ip              = optional(bool, false)
      public_ip_resource_group_name = optional(string)
      vnet_key                      = optional(string)
      subnet_key                    = optional(string)
      private_ip_address            = optional(string)
      gwlb_key                      = optional(string)
      in_rules = optional(map(object({
        name                = string
        protocol            = string
        port                = number
        backend_port        = optional(number)
        health_probe_key    = optional(string)
        floating_ip         = optional(bool)
        session_persistence = optional(string)
        nsg_priority        = optional(number)
      })), {})
      out_rules = optional(map(object({
        name                     = string
        protocol                 = string
        allocated_outbound_ports = optional(number)
        enable_tcp_reset         = optional(bool)
        idle_timeout_in_minutes  = optional(number)
      })), {})
    })), {})
  }))
```


Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### ngfw_metrics

A map controlling metrics-relates resources.

When set to explicit `null` (default) it will disable any metrics resources in this deployment.

When defined it will either create or source a Log Analytics Workspace and create Application Insights instances (one per each
Scale Set). All instances will be automatically connected to the workspace.
The name of the Application Insights instance will be derived from the Scale Set name and suffixed with `-ai`.

All the settings available below are common to the Log Analytics Workspace and Application Insight instances.

Following properties are available:

- `name`                      - (`string`, required) name of the (common) Log Analytics Workspace
- `create_workspace`          - (`bool`, optional, defaults to `true`) controls whether we create or source an existing Log
                                Analytics Workspace
- `resource_group_name`       - (`string`, optional, defaults to `var.resource_group_name`) name of the Resource Group hosting
                                the Log Analytics Workspace
- `sku`                       - (`string`, optional, defaults to module defaults) the SKU of the Log Analytics Workspace.
- `metrics_retention_in_days` - (`number`, optional, defaults to module defaults) workspace and insights data retention in
                                days, possible values are between 30 and 730. For sourced Workspaces this applies only to 
                                the Application Insights instances.


Type: 

```hcl
object({
    name                      = string
    create_workspace          = optional(bool, true)
    resource_group_name       = optional(string)
    sku                       = optional(string)
    metrics_retention_in_days = optional(number)
  })
```


Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### scale_sets

A map defining Azure Virtual Machine Scale Sets based on Palo Alto Networks Next Generation Firewall image.

For details and defaults for available options please refer to the [`vmss`](../../modules/vmss/README.md) module.

The basic Scale Set configuration properties are as follows:

- `name`                      - (`string`, required) name of the scale set, will be prefixed with the value of `var.name_prefix`
- `authentication`            - (`map`, required) authentication setting for VMs deployed in this scale set.

    This map holds the firewall admin password. When this property is not set, the password will be autogenerated for you and
    available in the Terraform outputs.

    **Note!** \
    The `disable_password_authentication` property is by default true. When using this value you have to specify at least one
    SSH key. You can however set this property to `true`. Then you have 2 options, either:

    - do not specify anything else - a random password will be generated for you
    - specify at least one of `password` or `ssh_keys` properties.

    For all properties and their default values see [module's documentation](../../modules/vmss/README.md#authentication).

- `image`                     - (`map`, required) properties defining a base image used to spawn VMs in this Scale Set.

    The `image` property is required but there are only 2 properties (mutually exclusive) that have to be set up, either:

    - `version`   - (`string`) describes the PAN-OS image version from Azure's Marketplace
    - `custom_id` - (`string`) absolute ID of your own custom PAN-OS image

    For details on the other properties refer to [module's documentation](../../modules/vmss/README.md#image).

- `virtual_machine_scale_set` - (`map`, optional, defaults to module defaults) a map that groups most common Scale Set
                                configuration options.

    Below we present only the most important ones, for the rest please refer to
    [module's documentation](../../modules/vmss/README.md#virtual_machine_scale_set):

    - `vnet_key`              - (`string`, required) a key of a VNET defined in `var.vnets`. This is the VNET that hosts subnets
                                used to deploy network interfaces for VMs in this Scale Set
    - `size`                  - (`string`, optional, defaults to module defaults) Azure VM size (type). Consult the *VM-Series
                                Deployment Guide* as only a few selected sizes are supported
    - `zones`                 - (`list`, optional, defaults to module defaults) a list of Availability Zones in which VMs from
                                this Scale Set will be created
    - `disk_type`             - (`string`, optional, defaults to module defaults) type of Managed Disk which should be created,
                                possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS` (works only for selected
                                `vm_size` values)
    - `bootstrap_options`     - (`string`, optional, defaults to module defaults) bootstrap options to pass to VM-Series
                                instance

- `autoscaling_configuration` - (`map`, optional, defaults to `{}`) a map that groups common autoscaling configuration, but not
                                the scaling profiles (metrics thresholds, etc)

    Below we present only the most important properties, for the rest please refer to
    [module's documentation](../../modules/vmss/README.md#autoscaling_configuration).

    - `default_count`   - (`number`, optional, defaults module defaults) minimum number of instances that should be present in
                          the scale set when the autoscaling engine cannot read the metrics or is otherwise unable to compare
                          the metrics to the thresholds

- `interfaces`              - (`list`, required) configuration of all network interfaces, order does matter - the 1<sup>st</sup>
                              interface should be the management one. Following properties are available:
  - `name`                    - (`string`, required) name of the network interface (will be prefixed with `var.name_prefix`)
  - `subnet_key`              - (`string`, required) a key of a subnet to which the interface will be assigned as defined in
                                `var.vnets`
  - `create_public_ip`        - (`bool`, optional, defaults to module defaults) create Public IP for an interface
  - `load_balancer_key`       - (`string`, optional, defaults to `null`) key of a Load Balancer defined in the
                                `var.loadbalancers` variable, network interface that has this property defined will be
                                added to the Load Balancer's backend pool
  - `application_gateway_key` - (`string`, optional, defaults to `null`) key of an Application Gateway defined in the
                                `var.appgws`, network interface that has this property defined will be added to the Application
                                Gateways's backend pool
  - `pip_domain_name_label`   - (`string`, optional, defaults to `null`) prefix which should be used for the Domain Name Label
                                for each VM instance

- `autoscaling_profiles`    - (`list`, optional, defaults to `[]`) a list of autoscaling profiles, for details on available
                              configuration please refer to
                              [module's documentation](../../modules/vmss/README.md#autoscaling_profiles)



Type: 

```hcl
map(object({
    name = string
    authentication = object({
      username                        = optional(string)
      password                        = optional(string)
      disable_password_authentication = optional(bool, true)
      ssh_keys                        = optional(list(string), [])
    })
    image = object({
      version                 = optional(string)
      publisher               = optional(string)
      offer                   = optional(string)
      sku                     = optional(string)
      enable_marketplace_plan = optional(bool)
      custom_id               = optional(string)
    })
    virtual_machine_scale_set = optional(object({
      vnet_key                     = string
      size                         = optional(string)
      bootstrap_options            = optional(string)
      zones                        = optional(list(string))
      disk_type                    = optional(string)
      accelerated_networking       = optional(bool)
      encryption_at_host_enabled   = optional(bool)
      overprovision                = optional(bool)
      platform_fault_domain_count  = optional(number)
      disk_encryption_set_id       = optional(string)
      enable_boot_diagnostics      = optional(bool, true)
      boot_diagnostics_storage_uri = optional(string)
      identity_type                = optional(string)
      identity_ids                 = optional(list(string), [])
      allow_extension_operations   = optional(bool)
    }))
    autoscaling_configuration = optional(object({
      default_count           = optional(number)
      scale_in_policy         = optional(string)
      scale_in_force_deletion = optional(bool)
      notification_emails     = optional(list(string), [])
      webhooks_uris           = optional(map(string), {})
    }), {})
    interfaces = list(object({
      name                    = string
      subnet_key              = string
      create_public_ip        = optional(bool)
      load_balancer_key       = optional(string)
      application_gateway_key = optional(string)
      pip_domain_name_label   = optional(string)
    }))
    autoscaling_profiles = optional(list(object({
      name          = string
      minimum_count = optional(number)
      default_count = number
      maximum_count = optional(number)
      recurrence = optional(object({
        timezone   = optional(string)
        days       = list(string)
        start_time = string
        end_time   = string
      }))
      scale_rules = optional(list(object({
        name = string
        scale_out_config = object({
          threshold                  = number
          operator                   = optional(string)
          grain_window_minutes       = number
          grain_aggregation_type     = optional(string)
          aggregation_window_minutes = number
          aggregation_window_type    = optional(string)
          cooldown_window_minutes    = number
          change_count_by            = optional(number)
        })
        scale_in_config = object({
          threshold                  = number
          operator                   = optional(string)
          grain_window_minutes       = optional(number)
          grain_aggregation_type     = optional(string)
          aggregation_window_minutes = optional(number)
          aggregation_window_type    = optional(string)
          cooldown_window_minutes    = number
          change_count_by            = optional(number)
        })
      })), [])
    })), [])
  }))
```


Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### appgws

A map defining all Application Gateways in the current deployment.

For detailed documentation on how to configure this resource, for available properties, especially for the defaults,
refer to [module documentation](../../modules/appgw/README.md).

**Note!** \
The `rules` property is meant to bind together `backend`, `redirect` or `url_path_map` (all 3 are mutually exclusive). It
represents the Rules section of an Application Gateway in Azure Portal.

Below you can find a brief list of available properties:

- `name` - (`string`, required) the name of the Application Gateway, will be prefixed with `var.name_prefix`
- `application_gateway` - (`map`, required) defines the basic Application Gateway settings, for details see
                          [module's documentation](../../modules/appgw/README.md#application_gateway). The most important
                          properties are:
  - `subnet_key`    - (`string`, required) a key pointing to a Subnet definition in the `var.vnets` map, this has to be an
                      Application Gateway V2 dedicated subnet.
  - `vnet_key`      - (`string`, required) a key pointing to a VNET definition in the `var.vnets` map that stores the Subnet
                      described by `subnet_key`.
  - `public_ip`     - (`map`, required) defines a Public IP resource used by the Application Gateway instance, a newly created
                      Public IP will have it's name prefixes with `var.name_prefix`
  - `zones`         - (`list`, optional, defaults to module defaults) parameter controlling if this is a zonal, or a non-zonal
                      deployment
  - `backend_pool`  - (`map`, optional, defaults to module defaults) backend pool definition, when skipped, an empty backend
                      will be created
- `listeners`       - (`map`, required) defines Application Gateway's Listeners, see
                      [module's documentation](../../modules/appgw/README.md#listeners) for details
- `backends`        - (`map`, optional, mutually exclusive with `redirects` and `url_path_maps`) defines HTTP backend settings,
                      see [module's documentation](../../modules/appgw/README.md#backends) for details
- `probes`          - (`map`, optional, defaults to module defaults) defines backend probes used check health of backends,
                      see [module's documentation](../../modules/appgw/README.md#probes) for details
- `rewrites`        - (`map`, optional, defaults to module defaults) defines rewrite rules,
                      see [module's documentation](../../modules/appgw/README.md#rewrites) for details
- `redirects        - (`map`, optional, mutually exclusive with `backends` and `url_path_maps`) static redirects definition,
                      see [module's documentation](../../modules/appgw/README.md#redirects) for details
- `url_path_maps    - (`map`, optional, mutually exclusive with `backends` and `redirects`) URL path maps definition, 
                      see [module's documentation](../../modules/appgw/README.md#url_path_maps) for details
- `rules            - (`map`, required) Application Gateway Rules definition, bind together a `listener` with either `backend`,
                      `redirect` or `url_path_map`, see [module's documentation](../../modules/appgw/README.md#rules)
                      for details


Type: 

```hcl
map(object({
    name = string
    application_gateway = object({
      vnet_key   = string
      subnet_key = string
      public_ip = object({
        name                = string
        resource_group_name = optional(string)
        create              = optional(bool, true)
      })
      capacity = optional(object({
        static = optional(number)
        autoscale = optional(object({
          min = number
          max = number
        }))
      }))
      zones             = optional(list(string))
      domain_name_label = optional(string)
      enable_http2      = optional(bool)
      waf = optional(object({
        prevention_mode  = bool
        rule_set_type    = optional(string)
        rule_set_version = optional(string)
      }))
      managed_identities = optional(list(string))
      global_ssl_policy = optional(object({
        type                 = optional(string)
        name                 = optional(string)
        min_protocol_version = optional(string)
        cipher_suites        = optional(list(string))
      }))
      frontend_ip_configuration_name = optional(string)
      backend_pool = optional(object({
        name         = optional(string)
        vmseries_ips = optional(list(string))
      }))
    })
    listeners = map(object({
      name                     = string
      port                     = number
      protocol                 = optional(string)
      host_names               = optional(list(string))
      ssl_profile_name         = optional(string)
      ssl_certificate_path     = optional(string)
      ssl_certificate_pass     = optional(string)
      ssl_certificate_vault_id = optional(string)
      custom_error_pages       = optional(map(string))
    }))
    backends = optional(map(object({
      name                      = string
      port                      = number
      protocol                  = string
      path                      = optional(string)
      hostname_from_backend     = optional(string)
      hostname                  = optional(string)
      timeout                   = optional(number)
      use_cookie_based_affinity = optional(bool)
      affinity_cookie_name      = optional(string)
      probe                     = optional(string)
      root_certs = optional(map(object({
        name = string
        path = string
      })))
    })))
    probes = optional(map(object({
      name       = string
      path       = string
      host       = optional(string)
      port       = optional(number)
      protocol   = optional(string)
      interval   = optional(number)
      timeout    = optional(number)
      threshold  = optional(number)
      match_code = optional(list(number))
      match_body = optional(string)
    })))
    rewrites = optional(map(object({
      name = optional(string)
      rules = optional(map(object({
        name     = string
        sequence = number
        conditions = optional(map(object({
          pattern     = string
          ignore_case = optional(bool)
          negate      = optional(bool)
        })))
        request_headers  = optional(map(string))
        response_headers = optional(map(string))
      })))
    })))
    rules = map(object({
      name             = string
      priority         = number
      backend_key      = optional(string)
      listener_key     = string
      rewrite_key      = optional(string)
      url_path_map_key = optional(string)
      redirect_key     = optional(string)
    }))
    redirects = optional(map(object({
      name                 = string
      type                 = string
      target_listener_key  = optional(string)
      target_url           = optional(string)
      include_path         = optional(bool)
      include_query_string = optional(bool)
    })))
    url_path_maps = optional(map(object({
      name        = string
      backend_key = string
      path_rules = optional(map(object({
        paths        = list(string)
        backend_key  = optional(string)
        redirect_key = optional(string)
      })))
    })))
    ssl_profiles = optional(map(object({
      name                            = string
      ssl_policy_name                 = optional(string)
      ssl_policy_min_protocol_version = optional(string)
      ssl_policy_cipher_suites        = optional(list(string))
    })))
  }))
```


Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>


<!-- END_TF_DOCS -->
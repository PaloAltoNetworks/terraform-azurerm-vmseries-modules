<!-- BEGIN_TF_DOCS -->
# VM-Series Azure Gateway Load Balancer example

The exmaple allows to deploy VM-Series firewalls for inbound and outbound traffic inspection utilizing Azure Gateway Load Balancer in service chain model as described in the following [document](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/set-up-the-vm-series-firewall-on-azure/deploy-the-vm-series-firewall-with-the-azure-gwlb).

## Usage

### Deployment Steps

* Checkout the code locally.
* Copy `example.tfvars` to `terraform.tfvars` and adjust it to your needs.
* Copy `files/init-cfg.txt.sample` to `files/init-cfg.txt` and fill it in with required bootstrap parameters (see this [documentation](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/init-cfgtxt-file-components) for details).
* (optional) Authenticate to AzureRM, switch to the Subscription of your choice if necessary.
* Initialize the Terraform module:

      terraform init

* (optional) Plan you infrastructure to see what will be actually deployed:

      terraform plan

* Deploy the infrastructure:

      terraform apply

* At this stage you have to wait a few minutes for the firewalls to bootstrap.

### Post deploy

Firewalls in this example are configured with password authentication. To retrieve the initial credentials run:

* for username:

      terraform output username

* for password:

      terraform output password

The management public IP addresses are available in the `vmseries_mgmt_ips` output:

```sh
terraform output vmseries_mgmt_ips
```

You can now login to the devices using either:

* CLI - ssh client is required
* Web UI (https) - any modern web browser, note that initially the traffic is encrypted with a self-signed certificate.

With default example configuration, the devices already contain `DAY0` configuration, so all network interfaces should be configured and Azure Gateway Load Balancer should already report that the devices are healthy.

You can now proceed with licensing the devices and configuring your first rules.

Please also refer to [this repository](https://github.com/PaloAltoNetworks/iron-skillet) for `DAY1` configuration (security hardening).

### Cleanup

To remove the deployed infrastructure run:

```sh
terraform destroy
```

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`location`](#location) | `string` | Location where the resources will be deployed.
[`resource_group_name`](#resource_group_name) | `string` | Name of the Resource Group to create or use.
[`vnets`](#vnets) | `map` | A map defining VNETs.
[`vmseries_common`](#vmseries_common) | `any` | Configuration common for all firewall instances.
[`vmseries`](#vmseries) | `map` | Map with VM-Series instance specific configuration.
[`appvms_common`](#appvms_common) | `any` | Common settings for sample applications:
- `username` - (required|string)
- `password` - (optional|string)
- `ssh_keys` - (optional|list(string)
- `vm_size` - (optional|string)
- `disk_type` - (optional|string)
- `accelerated_networking` - (optional|bool)

At least one of `password` or `ssh_keys` has to be provided.


## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`name_prefix`](#name_prefix) | `string` | Prefix for resource names.
[`create_resource_group`](#create_resource_group) | `bool` | When set to `true` it will cause a Resource Group creation.
[`enable_zones`](#enable_zones) | `bool` | If `true`, enable zone support for resources.
[`tags`](#tags) | `map` | Map of tags to assign to all of the created resources.
[`gateway_load_balancers`](#gateway_load_balancers) | `any` | Map with Gateway Load Balancer definitions.
[`application_insights`](#application_insights) | `map` | A map defining Azure Application Insights.
[`bootstrap_storages`](#bootstrap_storages) | `any` | A map defining Azure Storage Accounts used to host file shares for bootstrapping NGFWs.
[`availability_sets`](#availability_sets) | `any` | A map defining availability sets.
[`load_balancers`](#load_balancers) | `map` | A map containing configuration for all (private and public) Load Balancers.
[`appvms`](#appvms) | `any` | Configuration for sample application VMs.



## Module's Outputs

Name |  Description
--- | ---
`username` | Initial administrative username to use for VM-Series.
`password` | Initial administrative password to use for VM-Series.
`vmseries_mgmt_ips` | IP addresses for VM-Series management.
`gwlb_frontend_ip_configuration_ids` | Configuration IDs of Gateway Load Balancers' frontends.
`appvms_username` | Initial administrative username to use for application VMs.
`appvms_password` | Initial administrative password to use for application VMs.
`lb_frontend_ips` | IP addresses of the Load Balancers serving applications.

## Module's Nameplate


Requirements needed by this module:

- `terraform`, version: >= 1.3, < 2.0


Providers used in this module:

- `http`
- `azurerm`
- `local`
- `random`


Modules used in this module:
Name | Version | Source | Description
--- | --- | --- | ---
`vnet` | - | ../../modules/vnet | VNets
`gwlb` | - | ../../modules/gwlb | Gateway Load Balancers
`ai` | - | ../../modules/application_insights | VM-Series
`bootstrap` | - | ../../modules/bootstrap | 
`bootstrap_share` | - | ../../modules/bootstrap | 
`vmseries` | - | ../../modules/vmseries | 
`load_balancer` | - | ../../modules/loadbalancer | Sample application VMs and Load Balancers
`appvm` | - | ../../modules/virtual_machine | 


Resources used in this module:

- `availability_set` (managed)
- `resource_group` (managed)
- `file` (managed)
- `password` (managed)
- `password` (managed)
- `resource_group` (data)
- `http` (data)

## Inputs/Outpus details

### Required Inputs



#### location

Location where the resources will be deployed.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>


#### resource_group_name

Name of the Resource Group to create or use.

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
      name                          = string
      disable_bgp_route_propagation = optional(bool)
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
      name = string
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




#### vmseries_common

Configuration common for all firewall instances. Following settings can be specified:
- `username`           - (required|string)
- `password`           - (optional|string)
- `ssh_keys`           - (optional|string)
- `img_version`        - (optional|string)
- `img_sku`            - (optional|string)
- `vm_size`            - (optional|string)
- `bootstrap_options`  - (optional|string)
- `vnet_key`           - (optional|string)
- `interfaces`         - (optional|list(object))
- `ai_update_interval` - (optional|number)

All are used directly as inputs for `vmseries` module (please see [documentation](../../modules/vmseries/README.md) for details), except for the last three:
- `vnet_key`           - (required|string) Used to identify VNet in which subnets for interfaces exist.
- `ai_update_interval` - (optional|number) If Application Insights are used this property can override the default metrics update interval (in minutes).


Type: any

<sup>[back to list](#modules-required-inputs)</sup>

#### vmseries

Map with VM-Series instance specific configuration. Following properties are supported:
- `name`                 - (required|string) Instance name.
- `avzone`               - (optional|string) AZ to deploy instance in, defaults to "1".
- `availability_set_key` - (optional|string) Key from `var.availability_sets`, used to determine Availabbility Set ID.
- `bootstrap_storage`    - (optional|map) Map that contains bootstrap package contents definition, when present triggers creation of a File Share in an existing Storage Account. Following properties supported:
  - `key`                    - (required|string) Identifies Storage Account to use from `var.bootstrap_storages`.
  - `static_files`           - (optional|map) Map where keys are local file paths, values determine destination in the bootstrap package (file share) where the file will be copied.
  - `template_bootstrap_xml` - (optional|string) Path to the `bootstrap.xml` template. When defined it will trigger creation of the `bootstrap.xml` file and it's upload to the boostrap package. This is a simple `day 0` configuration file that should set up only basic networking. Specifying this property forces additional properties that are required to properly template the file. They can be defined per each VM or globally for all VMs (in `var.vmseries_common`). The properties are listed below.
- `interfaces`         - List of objects with interface definitions. Utilizes all properties of `interfaces` input (see [documantation](../../modules/vmseries/README.md#inputs)), expect for `subnet_id` and `lb_backend_pool_id`, which are determined based on the following new items:
  - `subnet_key`       - (optional|string) Key of a subnet from `var.vnets[vnet_key]` to associate interface with.
  - `gwlb_key`         - (optional|string) Key from `var.gwlbs` that identifies GWLB that will be associated with the interface, required when `enable_backend_pool` is `true`.
  - `gwlb_backend_key` - (optional|string) Key that identifies a backend from the GWLB selected by `gwlb_key` to associate th interface with, required when `enable_backend_pool` is `true`.

Additionally, it's possible to override following settings from `var.vmseries_common`:
- `bootstrap_options` - When defined, it not only takes precedence over `var.vmseries_common.bootstrap_options`, but also over `bootstrap_storage` described below.
- `img_version`
- `img_sku`
- `vm_size`
- `ai_update_interval`


Type: map(any)

<sup>[back to list](#modules-required-inputs)</sup>



#### appvms_common

Common settings for sample applications:
- `username` - (required|string)
- `password` - (optional|string)
- `ssh_keys` - (optional|list(string)
- `vm_size` - (optional|string)
- `disk_type` - (optional|string)
- `accelerated_networking` - (optional|bool)

At least one of `password` or `ssh_keys` has to be provided.


Type: any

<sup>[back to list](#modules-required-inputs)</sup>




### Optional Inputs


#### name_prefix

Prefix for resource names.

Type: string

Default value: ``

<sup>[back to list](#modules-optional-inputs)</sup>


#### create_resource_group

When set to `true` it will cause a Resource Group creation. Name of the newly specified RG is controlled by `resource_group_name`.
When set to `false` the `resource_group_name` parameter is used to specify a name of an existing Resource Group.


Type: bool

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>


#### enable_zones

If `true`, enable zone support for resources.

Type: bool

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>

#### tags

Map of tags to assign to all of the created resources.

Type: map(string)

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>


#### gateway_load_balancers

Map with Gateway Load Balancer definitions. Following settings are supported:
- `name`                - (required|string) Gateway Load Balancer name.
- `vnet_key`            - (required|string) Key of a VNet from `var.vnets` that contains target Subnet for LB's frontned. Used to get Subnet ID in combination with `subnet_key` below.
- `subnet_key`          - (required|string) Key of a Subnet from `var.vnets[vnet_key]`.
- `frontend_ip`         - (optional|map) Remaining Frontned IP configuration.
- `resource_group_name` - (optional|string) LB's Resource Group, by default the one specified by `var.resource_group_name`.
- `backends`            - (optional|map) LB's backend configurations.
- `health_probes`       - (optional|map) Health probes configuration.

Please consult [module documentation](../../modules/gwlb/README.md) for details.


Type: any

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### application_insights

A map defining Azure Application Insights. There are three ways to use this variable:

* when the value is set to `null` (default) no AI is created
* when the value is a map containing `name` key (other keys are optional) a single AI instance will be created under the name that is the value of the `name` key
* when the value is an empty map or a map w/o the `name` key, an AI instance per each VMSeries VM will be created. All instances will share the same configuration. All instances will have names corresponding to their VM name.

Names for all AI instances are prefixed with `var.name_prefix`.

Properties supported (for details on each property see [module documentation](../modules/application_insights/README.md)):

- `name`                      - (optional|string) Name of a single AI instance
- `workspace_mode`            - (optional|bool) Use AI Workspace mode instead of the Classical (deprecated), defaults to `true`.
- `workspace_name`            - (optional|string) Name of the Log Analytics Workspace created when AI is deployed in Workspace mode, defaults to AI name suffixed with `-wrkspc`.
- `workspace_sku`             - (optional|string) SKU used by WAL, see module documentation for details, defaults to PerGB2018.
- `metrics_retention_in_days` - (optional|number) Defaults to current Azure default value, see module documentation for details.

Example of an AIs created per VM, in Workspace mode, with metrics retention set to 1 year:
```
vmseries = {
  'vm-1' = {
    ....
  }
  'vm-2' = {
    ....
  }
}

application_insights = {
  metrics_retention_in_days = 365
}
```


Type: map(string)

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### bootstrap_storages

A map defining Azure Storage Accounts used to host file shares for bootstrapping NGFWs. This variable defines only Storage Accounts, file shares are defined per each VM. See `vmseries` variable, `bootstrap_storage` property.
Following properties are supported:
- `name`                             - (required|string) Name of the Storage Account. Please keep in mind that storage account name has to be globally unique. This name will not be prefixed with the value of `var.name_prefix`.
- `create_storage_account`           - (optional|bool) Whether to create or source an existing Storage Account, defaults to `true`.
- `resource_group_name`              - (optional|string) Name of the Resource Group hosting the Storage Account, defaults to `var.resource_group_name`.
- `storage_acl`                      - (optional|bool) Allows to enable network ACLs on the Storage Account. If set to `true`,  `storage_allow_vnet_subnets` and `storage_allow_inbound_public_ips` options become available. Defaults to `false`.
- `storage_allow_vnet_subnets`       - (optional|map) Map with objects that contains `vnet_key`/`subnet_key` used to identify subnets allowed to access the Storage Account. Note that `enable_storage_service_endpoint` has to be set to `true` in the corresponding subnet configuration.
- `storage_allow_inbound_public_ips` - (optional|list) Whitelist that contains public IPs/ranges allowed to access the Storage Account. Note that the code automatically to queries https://ifcondif.me to obtain the public IP address of the machine executing the code to enable bootstrap files upload.


Type: any

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>



#### availability_sets

A map defining availability sets. Can be used to provide infrastructure high availability when zones cannot be used.

Following properties are supported:
- `name`                - (required|string) Name of the Application Insights.
- `update_domain_count` - (optional|int) Specifies the number of update domains that are used, defaults to 5 (Azure defaults).
- `fault_domain_count`  - (optional|int) Specifies the number of fault domains that are used, defaults to 3 (Azure defaults).

Please keep in mind that Azure defaults are not working for each region (especially the small ones, w/o any Availability Zones). Please verify how many update and fault domain are supported in a region before deploying this resource.


Type: any

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

  > [!NOTE]
  > The `gwlb_fip_id` property is not available directly as well, it was replaced by `gwlb_key`.

  - `gwlb_key`    - (`string`, optional, defaults to `null`) a key pointing to a GWLB definition in the
                    `var.gateway_load_balancers`map.


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
      name                     = string
      public_ip_name           = optional(string)
      create_public_ip         = optional(bool, false)
      public_ip_resource_group = optional(string)
      vnet_key                 = optional(string)
      subnet_key               = optional(string)
      private_ip_address       = optional(string)
      gwlb_key                 = optional(string)
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


#### appvms

Configuration for sample application VMs. Available settings:
- `name`              - (required|string) Instance name.
- `avzone`            - (optional|string) AZ to deploy instance in, defaults to "1".
- `vnet_key`          - (required|string) Used to identify VNet in which subnets for interfaces exist.
- `subnet_key`        - (required|string) Key of a subnet from `var.vnets[vnet_key]` to associate interface with.
- `load_balancer_key` - (optional|string) Key from `var.gwlbs` that identifies GWLB that will be associated with the interface, required when `enable_backend_pool` is `true`.


Type: any

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>


<!-- END_TF_DOCS -->
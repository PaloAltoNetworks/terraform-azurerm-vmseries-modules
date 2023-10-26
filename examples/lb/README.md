<!-- BEGIN_TF_DOCS -->
# LB

Sample LB documentation.

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
[`load_balancers`](#load_balancers) | `map` | A map containing configuration for all (private and public) Load Balancers.




## Module's Nameplate


Requirements needed by this module:

- `terraform`, version: >= 1.3, < 2.0


Providers used in this module:

- `azurerm`


Modules used in this module:
Name | Version | Source | Description
--- | --- | --- | ---
`vnet` | - | ../../modules/vnet | Manage the network required for the topology.
`load_balancer` | - | ../../modules/loadbalancer | 


Resources used in this module:

- `resource_group` (managed)
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

- `create_virtual_network`  - (`bool`, optional, defaults to `false`) when set to `true` will create a VNET, `false` will source an existing VNET.
- `name`                    - (`string`, required) a name of a VNET. In case `create_virtual_network = false` this should be a full resource name, including prefixes.
- `address_space`           - (`list(string)`, required when `create_virtual_network = false`) a list of CIDRs for a newly created VNET
- `resource_group_name`     - (`string`, optional, defaults to current RG) a name of an existing Resource Group in which the VNET will reside or is sourced from

- `create_subnets`          - (`bool`, optinoal, defaults to `true`) if `true`, create Subnets inside the Virtual Network, otherwise use source existing subnets
- `subnets`                 - (`map`, optional) map of Subnets to create or source, for details see [VNET module documentation](../../modules/vnet/README.md#subnets)

- `network_security_groups` - (`map`, optional) map of Network Security Groups to create, for details see [VNET module documentation](../../modules/vnet/README.md#network_security_groups)
- `route_tables`            - (`map`, optional) map of Route Tables to create, for details see [VNET module documentation](../../modules/vnet/README.md#route_tables)


Type: 

```hcl
map(object({
    name                   = string
    create_virtual_network = optional(bool, true)
    address_space          = optional(list(string), [])
    resource_group_name    = optional(string)
    network_security_groups = optional(map(object({
      name     = string
      location = optional(string)
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
      name     = string
      location = optional(string)
      routes = map(object({
        name                   = string
        address_prefix         = string
        next_hop_type          = string
        next_hop_in_ip_address = optional(string)
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
```hcl
name_prefix = "test-"
```
  
NOTICE. This prefix is not applied to existing resources. If you plan to reuse i.e. a VNET please specify it's full name, even if it is also prefixed with the same value as the one in this property.


Type: string

Default value: ``

<sup>[back to list](#modules-optional-inputs)</sup>

#### create_resource_group

When set to `true` it will cause a Resource Group creation. Name of the newly specified RG is controlled by `resource_group_name`.
When set to `false` the `resource_group_name` parameter is used to specify a name of an existing Resource Group.


Type: bool

Default value: `true`

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
                              `in_rules` and `out_rules`; please refer to
                              [module documentation](../../modules/loadbalancer/README.md#frontend_ips) for available
                              properties; please note that in this example the `subnet_id` is not available directly, two other
                              properties were introduced instead:
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
      name                     = string
      public_ip_name           = optional(string)
      create_public_ip         = optional(bool, false)
      public_ip_resource_group = optional(string)
      vnet_key                 = optional(string)
      subnet_key               = optional(string)
      private_ip_address       = optional(string)
      gwlb_key                 = optional(string)
    })), {})
    inbound_rules = optional(map(object({
      name                = string
      frontend_ip_key     = string
      protocol            = string
      port                = number
      backend_port        = optional(number)
      health_probe_key    = optional(string)
      floating_ip         = optional(bool)
      session_persistence = optional(string)
      nsg_priority        = optional(number)
    })), {})
    outbound_rules = optional(map(object({
      name                     = string
      frontend_ip_key          = string
      protocol                 = string
      allocated_outbound_ports = optional(number)
      enable_tcp_reset         = optional(bool)
      idle_timeout_in_minutes  = optional(number)
    })), {})
  }))
```


Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>


<!-- END_TF_DOCS -->
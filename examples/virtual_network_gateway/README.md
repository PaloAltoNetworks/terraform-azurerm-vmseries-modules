<!-- BEGIN_TF_DOCS -->
# VNET module sample

A sample of using a VNET module with the new variables layout and usage of `optional` keyword.

The `README` is also in new, document-style format.

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`location`](#location) | `string` | The Azure region to use.
[`resource_group_name`](#resource_group_name) | `string` | Name of the Resource Group.
[`vnets`](#vnets) | `map` | A map defining VNETs.
[`virtual_network_gateways`](#virtual_network_gateways) | `map` | Map of virtual_network_gateways to create.


## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`tags`](#tags) | `map` | Map of tags to assign to the created resources.
[`name_prefix`](#name_prefix) | `string` | A prefix that will be added to all created resources.
[`create_resource_group`](#create_resource_group) | `bool` | When set to `true` it will cause a Resource Group creation.



## Module's Outputs

Name |  Description
--- | ---
`vng_public_ips` | IP Addresses of the VNGs.
`vng_ipsec_policy` | IPsec policy used for Virtual Network Gateway connection

## Module's Nameplate


Requirements needed by this module:

- `terraform`, version: >= 1.2, < 2.0


Providers used in this module:

- `azurerm`


Modules used in this module:
Name | Version | Source | Description
--- | --- | --- | ---
`vnet` | - | ../../modules/vnet | Manage the network required for the topology.
`vng` | - | ../../modules/virtual_network_gateway | Create virtual network gateway


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

#### virtual_network_gateways

Map of virtual_network_gateways to create

Type: 

```hcl
map(object({
    name     = string
    avzones  = optional(list(string))
    type     = optional(string)
    vpn_type = optional(string)
    sku      = optional(string)

    active_active                    = optional(bool)
    default_local_network_gateway_id = optional(string)
    edge_zone                        = optional(string)
    enable_bgp                       = optional(bool)
    generation                       = optional(string)
    private_ip_address_enabled       = optional(bool)

    ip_configuration = list(object({
      name                          = optional(string)
      create_public_ip              = bool
      public_ip_name                = optional(string)
      private_ip_address_allocation = optional(string)
      public_ip_standard_sku        = optional(bool)
      vnet_key                      = string
      subnet_name                   = string
    }))

    vpn_client_configuration = optional(list(object({
      address_space = string
      aad_tenant    = optional(string)
      aad_audience  = optional(string)
      aad_issuer    = optional(string)
      root_certificate = optional(object({
        name             = string
        public_cert_data = string
      }))
      revoked_certificate = optional(object({
        name       = string
        thumbprint = string
      }))
      radius_server_address = optional(string)
      radius_server_secret  = optional(string)
      vpn_client_protocols  = optional(list(string))
      vpn_auth_types        = optional(list(string))
    })), [])
    azure_bgp_peers_addresses = map(string)
    local_bgp_settings = object({
      asn = optional(string)
      peering_addresses = optional(map(object({
        apipa_addresses   = list(string)
        default_addresses = optional(list(string))
      })))
      peer_weight = optional(number)
    })
    custom_route = optional(list(object({
      address_prefixes = optional(list(string))
    })), [])
    ipsec_shared_key = optional(string)
    local_network_gateways = map(object({
      local_ng_name   = string
      connection_name = string
      remote_bgp_settings = optional(list(object({
        asn                 = string
        bgp_peering_address = string
        peer_weight         = optional(number)
      })))
      gateway_address = optional(string)
      address_space   = optional(list(string))
      custom_bgp_addresses = optional(list(object({
        primary   = string
        secondary = optional(string)
      })))
    }))
    connection_mode = optional(string)
    ipsec_policy = list(object({
      dh_group         = string
      ike_encryption   = string
      ike_integrity    = string
      ipsec_encryption = string
      ipsec_integrity  = string
      pfs_group        = string
      sa_datasize      = optional(string)
      sa_lifetime      = optional(string)
    }))
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
There is no default delimiter applied between the prefix and the resource name. Please include the delimiter in the actual prefix.

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





<!-- END_TF_DOCS -->
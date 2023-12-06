<!-- BEGIN_TF_DOCS -->
# APP GW module sample

A sample of using a APP GW module with the new variables layout and usage of `optional` keyword.

The `README` is also in new, document-style format.

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`location`](#location) | `string` | The Azure region to use.
[`resource_group_name`](#resource_group_name) | `string` | Name of the Resource Group.
[`vnets`](#vnets) | `map` | A map defining VNETs.
[`appgws`](#appgws) | `map` | A map defining all Application Gateways in the current deployment.


## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`tags`](#tags) | `map` | Map of tags to assign to the created resources.
[`name_prefix`](#name_prefix) | `string` | A prefix that will be added to all created resources.
[`create_resource_group`](#create_resource_group) | `bool` | When set to `true` it will cause a Resource Group creation.




## Module's Nameplate


Requirements needed by this module:

- `terraform`, version: >= 1.2, < 2.0


Providers used in this module:

- `azurerm`


Modules used in this module:
Name | Version | Source | Description
--- | --- | --- | ---
`vnet` | - | ../../modules/vnet | Manage the network required for the topology.
`appgw` | - | ../../modules/appgw | Create Application Gateay


Resources used in this module:

- `public_ip` (managed)
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

- `create_virtual_network`  - (`bool`, optional, defaults to `false`) when set to `true` will create a VNET,
                              `false` will source an existing VNET.
- `name`                    - (`string`, required) a name of a VNET. In case `create_virtual_network = false`
                              this should be a full resource name, including prefixes.
- `address_space`           - (`list(string)`, required when `create_virtual_network = false`) a list of CIDRs
                              for a newly created VNET
- `resource_group_name`     - (`string`, optional, defaults to current RG) a name of an existing Resource Group
                              in which the VNET will reside or is sourced from
- `create_subnets`          - (`bool`, optinoal, defaults to `true`) if `true`,
                              create Subnets inside the Virtual Network, otherwise use source existing subnets
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

#### appgws

A map defining all Application Gateways in the current deployment.

For detailed documentation on how to configure this resource, for available properties, especially for the defaults,
refer to [module documentation](../../modules/appgw/README.md).

Following properties are supported:
- `name`                              - (`string`, required) name of the Application Gateway.
- `public_ip`                         - (`string`, required) public IP address.
- `vnet_key`                          - (`string`, required) a key of a VNET defined in the `var.vnets` map.
- `subnet_key`                        - (`string`, required) a key of a subnet as defined in `var.vnets`.
                                        This has to be a subnet dedicated to Application Gateways v2.
- `managed_identities`                - (`list`, optional) a list of existing User-Assigned Managed Identities,
                                        which Application Gateway uses to retrieve certificates from Key Vault.
- `capacity`                          - (`number`, object) capacity configuration for Application Gateway (refer to
                                        [module documentation](../../modules/appgw/README.md) for details)
- `waf`                               - (`object`, required) WAF basic configuration, defining WAF rules is not supported
- `enable_http2`                      - (`bool`, optional) enable HTTP2 support on the Application Gateway
- `zones`                             - (`list`, required) for zonal deployment this is a list of all zones in a region -
                                        this property is used by both: the Application Gateway and the Public IP created
                                        in front of the AppGW.
- `frontend_ip_configuration_name`    - (`string`, optional) frontend IP configuration name
- `vmseries_public_nic_name`          - (`string`, optional) VM-Series NIC name, for which IP address
                                        will be used in backend pool
- `listeners`                         - (`map`, required) map of listeners (refer to
                                        [module documentation](../../modules/appgw/README.md) for details)
- `backend_pool`                      - (`object`, optional) backend pool (refer to
                                        [module documentation](../../modules/appgw/README.md) for details)
- `backends`                          - (`map`, optional) map of backends (refer to
                                        [module documentation](../../modules/appgw/README.md) for details)
- `probes`                            - (`map`, optional) map of probes (refer to
                                        [module documentation](../../modules/appgw/README.md) for details)
- `rewrites`                          - (`map`, optional) map of rewrites (refer to
                                        [module documentation](../../modules/appgw/README.md) for details)
- `rules`                             - (`map`, required) map of rules (refer to
                                        [module documentation](../../modules/appgw/README.md) for details)
- `redirects`                         - (`map`, optional) map of redirects (refer to
                                        [module documentation](../../modules/appgw/README.md) for details)
- `url_path_maps`                     - (`map`, optional) map of URL path maps (refer to
                                        [module documentation](../../modules/appgw/README.md) for details)
- `ssl_policy_type`                   - (`string`, optional) type of an SSL policy, defaults to `Predefined`
- `ssl_policy_name`                   - (`string`, optional) name of an SSL policy, for `ssl_policy_type` set to `Predefined`
- `ssl_policy_min_protocol_version`   - (`string`, optional) minimum version of the TLS protocol for SSL Policy,
                                        for `ssl_policy_type` set to `Custom`
- `ssl_policy_cipher_suites`          - (`list`, optional) a list of accepted cipher suites,
                                        for `ssl_policy_type` set to `Custom`
- `ssl_profiles`                      - (`map`, optional) a map of SSL profiles that can be later on referenced in HTTPS
                                        listeners by providing a name of the profile in the `ssl_profile_name` property


Type: 

```hcl
map(object({
    name = string
    public_ip = object({
      name           = string
      resource_group = optional(string)
      create         = optional(bool, true)
    })
    vnet_key           = string
    subnet_key         = string
    managed_identities = optional(list(string))
    capacity = object({
      static = optional(number)
      autoscale = optional(object({
        min = optional(number)
        max = optional(number)
      }))
    })
    waf = optional(object({
      enabled          = bool
      firewall_mode    = optional(string)
      rule_set_type    = optional(string, "OWASP")
      rule_set_version = optional(string)
    }))
    enable_http2                   = optional(bool)
    zones                          = list(string)
    frontend_ip_configuration_name = optional(string, "public_ipconfig")
    vmseries_public_nic_name       = optional(string, "public")
    listeners = map(object({
      name                     = string
      port                     = number
      protocol                 = optional(string, "Http")
      host_names               = optional(list(string))
      ssl_profile_name         = optional(string)
      ssl_certificate_path     = optional(string)
      ssl_certificate_pass     = optional(string)
      ssl_certificate_vault_id = optional(string)
      custom_error_pages       = optional(map(string), {})
    }))
    backend_pool = optional(object({
      name         = string
      vmseries_ips = optional(list(string), [])
    }))
    backends = optional(map(object({
      name                  = string
      path                  = optional(string)
      hostname_from_backend = optional(string)
      hostname              = optional(string)
      port                  = optional(number, 80)
      protocol              = optional(string, "Http")
      timeout               = optional(number, 60)
      cookie_based_affinity = optional(string, "Enabled")
      affinity_cookie_name  = optional(string)
      probe                 = optional(string)
      root_certs = optional(map(object({
        name = string
        path = string
      })), {})
    })))
    probes = optional(map(object({
      name       = string
      path       = string
      host       = optional(string)
      port       = optional(number)
      protocol   = optional(string, "Http")
      interval   = optional(number, 5)
      timeout    = optional(number, 30)
      threshold  = optional(number, 2)
      match_code = optional(list(number))
      match_body = optional(string)
    })), {})
    rewrites = optional(map(object({
      name = optional(string)
      rules = optional(map(object({
        name     = string
        sequence = number
        conditions = optional(map(object({
          pattern     = string
          ignore_case = optional(bool, false)
          negate      = optional(bool, false)
        })), {})
        request_headers  = optional(map(string), {})
        response_headers = optional(map(string), {})
      })))
    })), {})
    rules = map(object({
      name         = string
      priority     = number
      backend      = optional(string)
      listener     = string
      rewrite      = optional(string)
      url_path_map = optional(string)
      redirect     = optional(string)
    }))
    redirects = optional(map(object({
      name                 = string
      type                 = string
      target_listener      = optional(string)
      target_url           = optional(string)
      include_path         = optional(bool, false)
      include_query_string = optional(bool, false)
    })), {})
    url_path_maps = optional(map(object({
      name    = string
      backend = string
      path_rules = optional(map(object({
        paths    = list(string)
        backend  = optional(string)
        redirect = optional(string)
      })))
    })), {})
    ssl_global = optional(object({
      ssl_policy_type                 = string
      ssl_policy_name                 = optional(string)
      ssl_policy_min_protocol_version = optional(string)
      ssl_policy_cipher_suites        = optional(list(string))
    }))
    ssl_profiles = optional(map(object({
      name                            = string
      ssl_policy_name                 = optional(string)
      ssl_policy_min_protocol_version = optional(string)
      ssl_policy_cipher_suites        = optional(list(string))
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

NOTICE. This prefix is not applied to existing resources. If you plan to reuse i.e. a VNET please specify it's full name,
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





<!-- END_TF_DOCS -->
### GENERAL
variable "tags" {
  description = "Map of tags to assign to the created resources."
  default     = {}
  type        = map(string)
}

variable "location" {
  description = "The Azure region to use."
  type        = string
}

variable "name_prefix" {
  description = <<-EOF
  A prefix that will be added to all created resources.
  There is no default delimiter applied between the prefix and the resource name.
  Please include the delimiter in the actual prefix.

  Example:
  ```hcl
  name_prefix = "test-"
  ```

  NOTICE. This prefix is not applied to existing resources. If you plan to reuse i.e. a VNET please specify it's full name,
  even if it is also prefixed with the same value as the one in this property.
  EOF
  default     = ""
  type        = string
}

variable "create_resource_group" {
  description = <<-EOF
  When set to `true` it will cause a Resource Group creation.
  Name of the newly specified RG is controlled by `resource_group_name`.
  When set to `false` the `resource_group_name` parameter is used to specify a name of an existing Resource Group.
  EOF
  default     = true
  type        = bool
}

variable "resource_group_name" {
  description = "Name of the Resource Group."
  type        = string
}


### VNET
variable "vnets" {
  description = <<-EOF
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
  EOF

  type = map(object({
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
}

### Application Gateway
variable "appgws" {
  description = <<-EOF
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
  EOF
  type = map(object({
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
}

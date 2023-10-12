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
  There is no default delimiter applied between the prefix and the resource name. Please include the delimiter in the actual prefix.

  Example:
  ```hcl
  name_prefix = "test-"
  ```
  
  NOTICE. This prefix is not applied to existing resources. If you plan to reuse i.e. a VNET please specify it's full name, even if it is also prefixed with the same value as the one in this property.
  EOF
  default     = ""
  type        = string
}

variable "create_resource_group" {
  description = <<-EOF
  When set to `true` it will cause a Resource Group creation. Name of the newly specified RG is controlled by `resource_group_name`.
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

  - `create_virtual_network`  - (`bool`, optional, defaults to `false`) when set to `true` will create a VNET, `false` will source an existing VNET.
  - `name`                    - (`string`, required) a name of a VNET. In case `create_virtual_network = false` this should be a full resource name, including prefixes.
  - `address_space`           - (`list(string)`, required when `create_virtual_network = false`) a list of CIDRs for a newly created VNET
  - `resource_group_name`     - (`string`, optional, defaults to current RG) a name of an existing Resource Group in which the VNET will reside or is sourced from

  - `create_subnets`          - (`bool`, optinoal, defaults to `true`) if `true`, create Subnets inside the Virtual Network, otherwise use source existing subnets
  - `subnets`                 - (`map`, optional) map of Subnets to create or source, for details see [VNET module documentation](../../modules/vnet/README.md#subnets)

  - `network_security_groups` - (`map`, optional) map of Network Security Groups to create, for details see [VNET module documentation](../../modules/vnet/README.md#network_security_groups)
  - `route_tables`            - (`map`, optional) map of Route Tables to create, for details see [VNET module documentation](../../modules/vnet/README.md#route_tables)
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

### Virtual Network Gateway
variable "virtual_network_gateways" {
  description = "Map of virtual_network_gateways to create"
  type = map(object({
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
}

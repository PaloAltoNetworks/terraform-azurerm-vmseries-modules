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
  ```
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

variable "enable_zones" {
  description = "If `true`, enable zone support for resources."
  default     = true
  type        = bool
}



### VNET
variable "vnets" {
  description = <<-EOF
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
  EOF

  type = map(object({
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
}

variable "natgws" {
  description = <<-EOF
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
  EOF
  default     = {}
  type = map(object({
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
}



### Load Balancing
variable "load_balancers" {
  description = <<-EOF
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
  EOF
  default     = {}
  nullable    = false
  type = map(object({
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
}


variable "availability_sets" {
  description = <<-EOF
  A map defining availability sets. Can be used to provide infrastructure high availability when zones cannot be used.

  Following properties are supported:
  - `name` - name of the Application Insights.
  - `update_domain_count` - specifies the number of update domains that are used, defaults to 5 (Azure defaults).
  - `fault_domain_count` - specifies the number of fault domains that are used, defaults to 3 (Azure defaults).

  Please keep in mind that Azure defaults are not working for each region (especially the small ones, w/o any Availability Zones).
  Please verify how many update and fault domain are supported in a region before deploying this resource.
  EOF
  default     = {}
  type        = any
}


variable "bootstrap_storages" {
  description = <<-EOF
  A map defining Azure Storage Accounts used to host file shares for bootstrapping NGFWs.
  EOF
  default     = {}
  nullable    = false
  # type        = map(object({
  #   name = 
  # }))
}

variable "vmseries" {
  description = <<-EOF
  Map of virtual machines to create to run VM-Series - inbound firewalls.
  
  Following properties are supported:
  EOF
  default     = {}
  nullable    = false
  type = map(object({
    name = string
    authentication = object({
      username                        = optional(string, "panadmin")
      password                        = optional(string)
      disable_password_authentication = optional(bool)
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
    virtual_machine = object({
      vnet_key                     = string
      size                         = optional(string)
      bootstrap_options            = optional(string)
      zone                         = string
      disk_type                    = optional(string)
      disk_name                    = optional(string)
      avset_key                    = optional(string)
      accelerated_networking       = optional(bool)
      encryption_at_host_enabled   = optional(bool)
      proximity_placement_group_id = optional(string)
      disk_encryption_set_id       = optional(string)
      diagnostics_storage_uri      = optional(string)
      identity_type                = optional(string)
      identity_ids                 = optional(list(string))
    })
    interfaces = list(object({
      name                     = string
      subnet_key               = string
      create_public_ip         = optional(bool)
      public_ip_name           = optional(string)
      public_ip_resource_group = optional(string)
      private_ip_address       = optional(string)
      load_balancer_key        = optional(string)
      add_to_appgw_backend     = optional(bool, false)
    }))
  }))
}
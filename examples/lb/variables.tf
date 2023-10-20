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

variable "load_balancers" {
  description = <<-EOF
  A map containing configuration for all (private and public) Load Balancer that will be created in this deployment.

  Following properties are available:

  - `name`: name of the Load Balancer resource.
  - `nsg_vnet_key`: (public LB) defaults to `null`, a key describing a vnet (as defined in `vnet` variable) that hold an NSG we will update with an ingress rule for each listener.
  - `nsg_key`: (public LB) defaults to `null`, a key describing an NSG (as defined in `vnet` variable, under `nsg_vnet_key`) we will update with an ingress rule for each listener.
  - `network_security_group_name`: (public LB) defaults to `null`, in case of a brownfield deployment (no possibility to depend on `vnet` variable), a name of a security group, an ingress rule will be created in that NSG for each listener. **NOTE** this is the FULL NAME of the NSG (including prefixes).
  - `network_security_group_rg_name`: (public LB) defaults to `null`, in case of a brownfield deployment (no possibility to depend on `vnet` variable), a name of a resource group for the security group, to be used when the NSG is hosted in a different RG than the one described in `var.resource_group_name`.
  - `network_security_allow_source_ips`: (public LB) a list of IP addresses that will used in the ingress rules.
  - `avzones`: (both) for regional Load Balancers, a list of supported zones (this has different meaning for public and private LBs - please refer to module's documentation for details).
  - `frontend_ips`: (both) a map configuring both a listener and a load balancing rule, key is the name that will be used as an application name inside LB config as well as to create a rule in NSG (for public LBs), value is an object with the following properties:
    - `create_public_ip`: (public LB) defaults to `false`, when set to `true` a Public IP will be created and associated with a listener
    - `public_ip_name`: (public LB) defaults to `null`, when `create_public_ip` is set to `false` this property is used to reference an existing Public IP object in Azure
    - `public_ip_resource_group`: (public LB) defaults to `null`, when using an existing Public IP created in a different Resource Group than the currently used use this property is to provide the name of that RG
    - `private_ip_address`: (private LB) defaults to `null`, specify a static IP address that will be used by a listener
    - `vnet_key`: (private LB) defaults to `null`, when `private_ip_address` is set specifies a vnet's key (as defined in `vnet` variable). This will be the VNET hosting this Load Balancer
    - `subnet_key`: (private LB) defaults to `null`, when `private_ip_address` is set specifies a subnet's key (as defined in `vnet` variable) to which the LB will be attached, in case of VMSeries this should be a internal/trust subnet
    - `rules` - a map configuring the actual rules load balancing rules, a key is a rule name, a value is an object with the following properties:
      - `protocol`: protocol used by the rule, can be one the following: `TCP`, `UDP` or `All` when creating an HA PORTS rule
      - `port`: port used by the rule, for HA PORTS rule set this to `0`

  Example of a public Load Balancer:

  ```
  "public_lb" = {
    name                              = "https_app_lb"
    network_security_group_name       = "untrust_nsg"
    network_security_allow_source_ips = ["1.2.3.4"]
    avzones                           = ["1", "2", "3"]
    frontend_ips = {
      "https_app_1" = {
        create_public_ip = true
        rules = {
          "balanceHttps" = {
            protocol = "Tcp"
            port     = 443
          }
        }
      }
    }
  }
  ```

  Example of a private Load Balancer with HA PORTS rule:

  ```
  "private_lb" = {
    name = "ha_ports_internal_lb
    frontend_ips = {
      "ha-ports" = {
        vnet_key           = "trust_vnet"
        subnet_key         = "trust_snet"
        private_ip_address = "10.0.0.1"
        rules = {
          HA_PORTS = {
            port     = 0
            protocol = "All"
          }
        }
      }
    }
  }
  ```

  EOF
  default     = {}
  nullable    = false
  type = map(object({
    name       = string
    vnet_key   = optional(string)
    subnet_key = optional(string)
    zones      = optional(list(string), ["1", "2", "3"])
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
      name                                               = string
      public_ip_name                                     = optional(string)
      create_public_ip                                   = optional(bool, false)
      public_ip_resource_group                           = optional(string)
      vnet_key                                           = optional(string)
      subnet_key                                         = optional(string)
      private_ip_address                                 = optional(string)
      gateway_load_balancer_frontend_ip_configuration_id = optional(string)
      in_rules = optional(map(object({
        name                = string
        protocol            = string
        port                = number
        backend_port        = optional(number)
        health_probe_key    = optional(string)
        floating_ip         = optional(bool, true)
        session_persistence = optional(string, "Default")
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
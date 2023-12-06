variable "name" {
  description = "The name of the Azure Virtual Network."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "The name of the Azure region to deploy the resources in."
  type        = string
}

variable "tags" {
  description = "The map of tags to assign to all created resources."
  default     = {}
  type        = map(string)
}

variable "create_virtual_network" {
  description = <<-EOF
  Controls Virtual Network creation.
  
  When set to `true`, creates the Virtual Network, otherwise just use a pre-existing network.
  EOF
  default     = true
  nullable    = false
  type        = bool
}

variable "address_space" {
  description = <<-EOF
  The address space used by the virtual network.
  
  You can supply more than one address space. Required only when you create a VNET.
  EOF
  default     = null
  type        = list(string)
  validation {
    condition = alltrue([
      for v in coalesce(var.address_space, []) :
      can(regex("^(\\d{1,3}\\.){3}\\d{1,3}\\/[12]?[0-9]$", v))
    ])
    error_message = "All items in var.address_space should be in CIDR notation, with the maximum subnet of /29."
  }
}

variable "network_security_groups" {
  description = <<-EOF
  Map of objects describing Network Security Groups.

  List of available properties:

  - `name`   - (`string`, required) name of the Network Security Group.
  - `rules`  - (`map`, optional, defaults to `{}`) A list of objects representing Network Security Rules.

    > [!NOTE]
    > All port values are integers between `0` and `65535`. Port ranges can be specified as `minimum-maximum` port value,
    > example: `21-23`.
    
    Following attributes are available:

    - `name`                          - (`string`, required) name of the rule
    - `priority`                      - (`number`, required) numeric priority of the rule. The value can be between 100 and 4096
                                        and must be unique for each rule in the collection. The lower the priority number,
                                        the higher the priority of the rule.
    - `direction`                     - (`string`, required) the direction specifies if rule will be evaluated on incoming
                                        or outgoing traffic. Possible values are `Inbound` and `Outbound`.
    - `access`                        - (`string`, required) specifies whether network traffic is allowed or denied.
                                        Possible values are `Allow` and `Deny`.
    - `protocol`                      - (`string`, required) a network protocol this rule applies to. Possible values include
                                        `Tcp`, `Udp`, `Icmp`, or `*` (which matches all). For supported values refer to the
                                        [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_securityrule#protocol)
    - `source_port_range`             - (`string`, required, mutually exclusive with `source_port_ranges`) a source port or
                                        a range of ports. This can also be an `*` to match all.
    - `source_port_ranges`            - (`list`, required, mutually exclusive with `source_port_range`) a list of source ports
                                        or ranges of ports.
    - `source_address_prefix`         - (`string`, required, mutually exclusive with `source_address_prefixes`) source CIDR or IP
                                        range or `*` to match any IP. This can also be a tag. To see all available tags for a
                                        region use the following command (example for US West Central):
                                        `az network list-service-tags --location westcentralus`.
    - `source_address_prefixes`       - (`list`, required, mutually exclusive with `source_address_prefix`) a list of source
                                        address prefixes. Tags are not allowed.
    - `destination_port_range`        - (`string`, required, mutually exclusive with `destination_port_ranges`) destination port
                                        or a range of ports. This can also be an `*` to match all.
    - `destination_port_ranges`       - (`list`, required, mutually exclusive with `destination_port_range`) a list of
                                        destination ports or a ranges of ports.
    - `destination_address_prefix`    - (`string`, required, mutually exclusive with `destination_address_prefixes`) destination
                                        CIDR or IP range or `*` to match any IP. Tags are allowed, see `source_address_prefix`
                                        for details.
    - `destination_address_prefixes`  - (`list`, required,  mutually exclusive with `destination_address_prefixes`) a list of 
                                        destination address prefixes. Tags are not allowed.

  Example:
  ```hcl
  {
    "nsg_1" = {
      name = "network_security_group_1"
      rules = {
        "AllOutbound" = {
          name =                     = "DefaultOutbound"
          priority                   = 100
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          source_address_prefix      = "*"
          destination_port_range     = "*"
          destination_address_prefix = "*"
        },
        "AllowSSH" = {
          name                       = "InboundSSH"
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          source_address_prefix      = "*"
          destination_port_range     = "22"
          destination_address_prefix = "*"
        },
        "AllowWebBrowsing" = {
          name                       = "InboundWeb"
          priority                   = 300
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          source_address_prefix      = "*"
          destination_port_ranges    = ["80","443"]
          destination_address_prefix = "VirtualNetwork"
        }
      }
    },
    "nsg_2" = {
      name = "empty-nsg
    }
  }
  ```
  EOF
  default     = {}
  nullable    = false
  type = map(object({
    name = string
    rules = optional(map(object({
      name                         = string
      priority                     = number
      direction                    = string
      access                       = string
      protocol                     = string
      source_port_range            = optional(string)
      source_port_ranges           = optional(list(string))
      source_address_prefix        = optional(string)
      source_address_prefixes      = optional(list(string))
      destination_port_range       = optional(string)
      destination_port_ranges      = optional(list(string))
      destination_address_prefix   = optional(string)
      destination_address_prefixes = optional(list(string))
    })), {})
  }))
  validation { # name
    condition     = length([for _, v in var.network_security_groups : v.name]) == length(distinct([for _, v in var.network_security_groups : v.name]))
    error_message = "The `name` property has to be unique."
  }
  validation { # rule.name
    condition = alltrue([
      for _, nsg in var.network_security_groups :
      length([for _, rule in nsg.rules : rule.name]) == length(distinct([for _, rule in nsg.rules : rule.name]))
    ])
    error_message = "The `rule.name` property has to be unique in a particular NSG."
  }
  validation { # rule.priority
    condition = alltrue(flatten([
      for _, nsg in var.network_security_groups : [
        for _, rule in nsg.rules :
        rule.priority >= 100 && rule.priority <= 4096
      ]
    ]))
    error_message = "The `priority` should be a value between 100 and 4096."
  }
  validation { # rule.direction
    condition = alltrue(flatten([
      for _, nsg in var.network_security_groups : [
        for _, rule in nsg.rules :
        contains(["Inbound", "Outbound"], rule.direction)
      ]
    ]))
    error_message = "The `direction` property should be one of Inbound or Outbound."
  }
  validation { # rule.access
    condition = alltrue(flatten([
      for _, nsg in var.network_security_groups : [
        for _, rule in nsg.rules :
        contains(["Allow", "Deny"], rule.access)
      ]
    ]))
    error_message = "The `access` property should be one of Allow or Deny."
  }
  validation { # rule.protocol
    condition = alltrue(flatten([
      for _, nsg in var.network_security_groups : [
        for _, rule in nsg.rules :
        contains(["Tcp", "Udp", "Icmp", "*"], rule.protocol)
      ]
    ]))
    error_message = "The `protocol` property should be one of Tcp, Udp, Icmp or *."
  }
  validation { # rule.source_port_range(s)
    condition = alltrue(flatten([
      for _, nsg in var.network_security_groups : [
        for _, rule in nsg.rules :
        (rule.source_port_range == null || rule.source_port_ranges == null) && !(rule.source_port_range == null && rule.source_port_ranges == null)
      ]
    ]))
    error_message = "The `source_port_range` and `source_port_ranges` properties are required but mutually exclusive."
  }
  validation { # rule.source_port_range
    condition = alltrue(flatten([
      for _, nsg in var.network_security_groups : [
        for _, rule in nsg.rules :
        can(regex("^\\*$|^\\d{1,4}[0-5]?(\\-\\d{1,4}[0-5])?$", rule.source_port_range))
        if rule.source_port_range != null
      ]
    ]))
    error_message = "The `source_port_range` can be either an '*' or a port number (between 0 and 65535) or a range of ports (delimited with a '-')."
  }
  validation { # rule.source_port_ranges
    condition = alltrue(flatten([
      for _, nsg in var.network_security_groups : [
        for _, rule in nsg.rules : [
          for _, range in coalesce(rule.source_port_ranges, []) :
          can(regex("^\\d{1,4}[0-5]?(\\-\\d{1,4}[0-5])?$", range))
        ]
      ]
    ]))
    error_message = "The `source_port_ranges` is a list of port numbers (between 0 and 65535) or a ranges of ports (delimited with a '-')."
  }
  validation { # rule.destination_port_range(s)
    condition = alltrue(flatten([
      for _, nsg in var.network_security_groups : [
        for _, rule in nsg.rules :
        (rule.destination_port_range == null || rule.destination_port_ranges == null) && !(rule.destination_port_range == null && rule.destination_port_ranges == null)
      ]
    ]))
    error_message = "The `destination_port_range` and `destination_port_ranges` properties are required but mutually exclusive."
  }
  validation { # rule.destination_port_range
    condition = alltrue(flatten([
      for _, nsg in var.network_security_groups : [
        for _, rule in nsg.rules :
        can(regex("^\\*$|^\\d{1,4}[0-5]?(\\-\\d{1,4}[0-5])?$", rule.destination_port_range))
        if rule.destination_port_range != null
      ]
    ]))
    error_message = "The `destination_port_range` can be either an '*' or a port number (between 0 and 65535) or a range of ports (delimited with a '-')."
  }
  validation { # rule.destination_port_ranges
    condition = alltrue(flatten([
      for _, nsg in var.network_security_groups : [
        for _, rule in nsg.rules : [
          for _, range in coalesce(rule.destination_port_ranges, []) :
          can(regex("^\\d{1,4}[0-5]?(\\-\\d{1,4}[0-5])?$", range))
        ]
      ]
    ]))
    error_message = "The `destination_port_ranges` is a list of port numbers (between 0 and 65535) or a ranges of ports (delimited with a '-')."
  }
  validation { # rule.source_address_prefix(s)
    condition = alltrue(flatten([
      for _, nsg in var.network_security_groups : [
        for _, rule in nsg.rules :
        (rule.source_address_prefix == null || rule.source_address_prefixes == null) && !(rule.source_address_prefix == null && rule.source_address_prefixes == null)
      ]
    ]))
    error_message = "The `source_address_prefixes` and `source_address_prefixes` properties are required but mutually exclusive."
  }
  validation { # rule.source_address_prefix
    condition = alltrue(flatten([
      for _, nsg in var.network_security_groups : [
        for _, rule in nsg.rules :
        can(regex("^\\*$|^[A-Za-z]+$|^(\\d{1,3}\\.){3}\\d{1,3}(\\/[12]?[0-9]|\\/3[0-2])?$", rule.source_address_prefix))
        if rule.source_address_prefix != null
      ]
    ]))
    error_message = "The `source_address_prefix` can be either '*', a CIDR or an Azure Service Tag."
  }
  validation { # rule.source_address_prefixes
    condition = alltrue(flatten([
      for _, nsg in var.network_security_groups : [
        for _, rule in nsg.rules : [
          for _, prefix in coalesce(rule.source_address_prefixes, []) :
          can(regex("^(\\d{1,3}\\.){3}\\d{1,3}(\\/[12]?[0-9]|\\/3[0-2])?$", prefix))
        ]
      ]
    ]))
    error_message = "The `source_address_prefixes` can be a list of CIDRs."
  }
  validation { # rule.destination_address_prefix(s)
    condition = alltrue(flatten([
      for _, nsg in var.network_security_groups : [
        for _, rule in nsg.rules :
        (rule.destination_address_prefix == null || rule.destination_address_prefixes == null) && !(rule.destination_address_prefix == null && rule.destination_address_prefixes == null)
      ]
    ]))
    error_message = "The `destination_address_prefix` and `destination_address_prefixes` properties are required but mutually exclusive."
  }
  validation { # rule.destination_address_prefix
    condition = alltrue(flatten([
      for _, nsg in var.network_security_groups : [
        for _, rule in nsg.rules :
        can(regex("^\\*$|^[A-Za-z]+$|^(\\d{1,3}\\.){3}\\d{1,3}(\\/[12]?[0-9]|\\/3[0-2])?$", rule.destination_address_prefix))
        if rule.destination_address_prefix != null
      ]
    ]))
    error_message = "The `destination_address_prefix` can be either '*', a CIDR or an Azure Service Tag."
  }
  validation { # rule.destination_address_prefixes
    condition = alltrue(flatten([
      for _, nsg in var.network_security_groups : [
        for _, rule in nsg.rules : [
          for _, prefix in coalesce(rule.destination_address_prefixes, []) :
          can(regex("^(\\d{1,3}\\.){3}\\d{1,3}(\\/[12]?[0-9]|\\/3[0-2])?$", prefix))
        ]
      ]
    ]))
    error_message = "The `destination_address_prefixes` can be a list of CIDRs."
  }
}

variable "route_tables" {
  description = <<-EOF
  Map of objects describing a Route Tables.

  List of available properties:

  - `name`                          - (`string`, required) name of a Route Table.
  - `disable_bgp_route_propagation` - (`bool`, optional, defaults to `false`) controls propagation of routes learned by BGP
  - `routes`                        - (`map`, required) a map of Route Table entries (UDRs):
    - `name`                    - (`string`, required) a name of a UDR.
    - `address_prefix`          - (`string`, required) the destination CIDR to which the route applies, such as `10.1.0.0/16`.
    - `next_hop_type`           - (`string`, required) the type of Azure hop the packet should be sent to.
                                  Possible values are: `VirtualNetworkGateway`, `VnetLocal`, `Internet`, `VirtualAppliance` and `None`.
    - `next_hop_ip_address`     - (`string`, required) contains the IP address packets should be forwarded to.
                                  Used only when `next_hop_type` is set to `VirtualAppliance`, ignored otherwise.

  Example:
  ```hcl
  {
    "rt_1" = {
      name = "route_table_1"
      routes = {
        "route_1" = {
          name           = "route-1"
          address_prefix = "10.1.0.0/16"
          next_hop_type  = "VnetLocal"
        },
        "route_2" = {
          name           = "route-2"
          address_prefix = "10.2.0.0/16"
          next_hop_type  = "VnetLocal"
        },
      }
    },
    "rt_2" = {
      name = "route_table_2"
      routes = {
        "route_3" = {
          name                   = "default-nva-route"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_ip_address = "10.112.0.100"
        }
      },
    },
  }
  ```
  EOF
  default     = {}
  nullable    = false
  type = map(object({
    name                          = string
    disable_bgp_route_propagation = optional(bool, false)
    routes = map(object({
      name                = string
      address_prefix      = string
      next_hop_type       = string
      next_hop_ip_address = optional(string)
    }))
  }))
  validation { # name
    condition     = length([for _, v in var.route_tables : v.name]) == length(distinct([for _, v in var.route_tables : v.name]))
    error_message = "The `name` property has to be unique."
  }
  validation { # route.name
    condition = alltrue([
      for _, rt in var.route_tables :
      length([for _, udr in rt.routes : udr.name]) == length(distinct([for _, udr in rt.routes : udr.name]))
    ])
    error_message = "The `rule.name` property has to be unique in a particular NSG."
  }
  validation { # route.address_prefix
    condition = alltrue(flatten([
      for _, rt in var.route_tables : [
        for _, udr in rt.routes : [
          can(regex("^(\\d{1,3}\\.){3}\\d{1,3}(\\/[12]?[0-9]|\\/3[0-2])?$", udr.address_prefix))
        ]
      ]
    ]))
    error_message = "The `address_prefix` should be in CIDR notation."
  }
  validation { # route.next_hop_type
    condition = alltrue(flatten([
      for _, rt in var.route_tables : [
        for _, udr in rt.routes : can(udr.next_hop_type) ? contains(["VirtualNetworkGateway", "VnetLocal", "Internet", "VirtualAppliance", "None"], udr.next_hop_type) : true
      ]
    ]))
    error_message = "The `next_hop_type` route property should have value of either: \"VirtualNetworkGateway\", \"VnetLocal\", \"Internet\", \"VirtualAppliance\" or \"None\"."
  }
  validation { # route.next_hop_ip_address
    condition = alltrue(flatten([
      for _, rt in var.route_tables : [
        for _, udr in rt.routes :
        can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", udr.next_hop_ip_address))
        if udr.next_hop_ip_address != null
      ]
    ]))
    error_message = "The `next_hop_ip_address` should be a valid IPv4 address."
  }
}

variable "create_subnets" {
  description = <<-EOF
  Controls subnet creation.
  
  Possible variants:

  - `true`      - create subnets described in `var.subnets`
  - `false`     - source subnets described in `var.subnets`
  - `false` and `var.subnets` is empty  - skip subnets management.
  EOF
  default     = true
  nullable    = false
  type        = bool
}

variable "subnets" {
  description = <<-EOF
  Map of objects describing subnets to manage.
  
  By the default the described subnets will be created. 
  If however `create_subnets` is set to `false` this is just a mapping between the existing subnets and UDRs and NSGs that should be assigned to them.
  
  List of available attributes of each subnet entry:

  - `name`                            - (`string`, required) name of a subnet.
  - `address_prefixes`                - (`list(string)`, required when `create_subnets = true`) a list of address prefixes within
                                        VNET's address space to assign to a created subnet.
  - `network_security_group_key`      - (`string`, optional, defaults to `null`) a key identifying an NSG defined in
                                        `network_security_groups` that should be assigned to this subnet.
  - `route_table_key`                 - (`string`, optional, defaults to `null`) a key identifying a Route Table defined in
                                        `route_tables` that should be assigned to this subnet.
  - `enable_storage_service_endpoint` - (`bool`, optional, defaults to `false`) a flag that enables `Microsoft.Storage` service
                                        endpoint on a subnet. This is a suggested setting for the management interface when full
                                        bootstrapping using an Azure Storage Account is used.

  Example:
  ```hcl
  {
    "management" = {
      name                            = "management-snet"
      address_prefixes                = ["10.100.0.0/24"]
      network_security_group_key      = "network_security_group_1"
      enable_storage_service_endpoint = true
    },
    "private" = {
      name                       = "private-snet"
      address_prefixes           = ["10.100.1.0/24"]
      route_table_key            = "route_table_2"
    },
    "public" = {
      name                       = "public-snet"
      address_prefixes           = ["10.100.2.0/24"]
    }
  }
  ```
  EOF
  default     = {}
  nullable    = false
  type = map(object({
    name                            = string
    address_prefixes                = optional(list(string), [])
    network_security_group_key      = optional(string)
    route_table_key                 = optional(string)
    enable_storage_service_endpoint = optional(bool, false)
  }))
  validation { # name
    condition     = length([for _, v in var.subnets : v.name]) == length(distinct([for _, v in var.subnets : v.name]))
    error_message = "The `name` property has to be unique."
  }
  validation { # subnet.address_prefixes
    condition = alltrue(flatten([
      for _, snet in var.subnets : [
        for _, cidr in snet.address_prefixes :
        can(regex("^(\\d{1,3}\\.){3}\\d{1,3}\\/[12]?[0-9]$", cidr))
      ]
    ]))
    error_message = "The `address_prefixes` should be list of CIDR blocks, with the maximum subnet of /29."
  }
}

variable "name" {
  description = "The name of the Azure Virtual Network."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "Location of the resources that will be deployed."
  type        = string
}

variable "tags" {
  description = "Map of tags to assign to all of the created resources."
  default     = {}
  type        = map(string)
}

variable "create_virtual_network" {
  description = "If true, create the Virtual Network, otherwise just use a pre-existing network."
  default     = true
  type        = bool
}

variable "address_space" {
  description = "The address space used by the virtual network. You can supply more than one address space. Required only when you create a VNET."
  default     = null
  type        = list(string)
}

variable "network_security_groups" {
  description = <<-EOF
  Map of objects describing Network Security Groups.

  List of either required or important properties:

  - `name`   -  (`string`, required) name of the Network Security Group.
  - `rules`  - (`map`, optional) A list of objects representing Network Security Rules.

    Notice, all port values are integers between `0` and `65535`. Port ranges can be specified as `minimum-maximum` port value, example: `21-23`. Following attributes are available:

    - `name`                          - (`string`, required) name of the rule
    - `priority`                      - (`number`, required) numeric priority of the rule. The value can be between 100 and 4096 and must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule.
    - `direction`                     - (`string`, required) the direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are `Inbound` and `Outbound`.
    - `access`                        - (`string`, required) specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`.
    - `protocol`                      - (`string`, required) a network protocol this rule applies to. Possible values include `Tcp`, `Udp`, `Icmp`, or `*` (which matches all). For supported values refer to the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule#protocol)
    - `source_port_range`             - (`string`, required, mutually exclusive with `source_port_ranges`) a source port or a range of ports. This can also be an `*` to match all.
    - `source_port_ranges`            - (`list`, required, mutually exclusive with `source_port_range`) a list of source ports or ranges of ports.
    - `destination_port_range`        - (`string`, required, mutually exclusive with `destination_port_ranges`) destination port or a range of ports. This can also be an `*` to match all.
    - `destination_port_ranges`       - (`list`, required, mutually exclusive with `destination_port_range`) a list of destination ports or a ranges of ports.
    - `source_address_prefix`         - (`string`, required, mutually exclusive with `source_address_prefixes`) source CIDR or IP range or `*` to match any IP. This can also be a tag. To see all available tags for a region use the following command (example for US West Central): `az network list-service-tags --location westcentralus`.
    - `source_address_prefixes`       - (`list`, required, mutually exclusive with `source_address_prefixe`) a list of source address prefixes. Tags are not allowed.
    - `destination_address_prefix`    - (`string`, required, mutually exclusive with `destination_address_prefixes`) destination CIDR or IP range or `*` to match any IP. Tags are allowed, see `source_address_prefix` for details.
    - `destination_address_prefixes`  - (`list`, required,  mutually exclusive with `destination_address_prefixes`) a list of destination address prefixes. Tags are not allowed.

  Example:
  ```hcl
  {
    "nsg_1" = {
      name = "network_security_group_1"
      rules = {
        "AllOutbound" = {
          priority                   = 100
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        "AllowSSH" = {
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        "AllowWebBrowsing" = {
          priority                   = 300
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = ["80","443"]
          source_address_prefix      = "*"
          destination_address_prefix = "VirtualNetwork"
        }
      }
    },
    "network_security_group_2" = {
      rules = {}
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
      destination_port_range       = optional(string)
      destination_port_ranges      = optional(list(string))
      source_address_prefix        = optional(string)
      source_address_prefixes      = optional(list(string))
      destination_address_prefix   = optional(string)
      destination_address_prefixes = optional(list(string))
    })), {})
  }))
}

variable "route_tables" {
  description = <<-EOF
  Map of objects describing a Route Tables.

  List of either required or important properties:

  - `name`      - (`string`, required) name of a Route Table.
  - `routes`    - (`map`, required) a map of Route Table entries (UDRs):
    - `name`                    - (`string`, required) a name of a UDR.
    - `address_prefix`          - (`string`, required) the destination CIDR to which the route applies, such as `10.1.0.0/16`.
    - `next_hop_type`           - (`string`, required) the type of Azure hop the packet should be sent to.
      Possible values are: `VirtualNetworkGateway`, `VnetLocal`, `Internet`, `VirtualAppliance` and `None`.
    - `next_hop_in_ip_address`  - (`string`, required) contains the IP address packets should be forwarded to.
      Next hop values are only allowed in routes where the next hop type is `VirtualAppliance`.

  Example:
  ```hcl
  {
    "rt_1" = {
      name = "route_table_1"
      routes = {
        "route_1" = {
          address_prefix = "10.1.0.0/16"
          next_hop_type  = "vnetlocal"
        },
        "route_2" = {
          address_prefix = "10.2.0.0/16"
          next_hop_type  = "vnetlocal"
        },
      }
    },
    "rt_2" = {
      name = "route_table_2"
      routes = {
        "route_3" = {
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.112.0.100"
        }
      },
    },
  }
  ```
  EOF
  default     = {}
  nullable    = false
  type = map(object({
    name = string
    routes = map(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    }))
  }))
}

variable "create_subnets" {
  description = "If true, create the Subnets inside the Virtual Network, otherwise use a pre-existing subnets."
  default     = true
  nullable    = false
  type        = bool
}

variable "subnets" {
  description = <<-EOF
  Map of objects describing subnets to create within a virtual network.
  
  By the default the described subnets will be created. If however `create_subnets` is set to `false` this is just a mapping between the existing subnets and UDRs and NSGs that should be assigned to them.
  
  List of available attributes of each subnet entry:

  - `name`                            - (`string`, required) name of a subnet.
  - `address_prefixes`                - (`list(string)`, required when `create_subnets = true`) a list of address prefixes within VNET's address space to assign to a created subnet.
  - `network_security_group_key`          - (`string`, optional, defaults to `null`) a key identifying an NSG defined in `network_security_groups` that should be assigned to this subnet.
  - `route_table_key`                  - (`string`, optional, defaults to `null`) a key identifying a Route Table defined in `route_tables` that should be assigned to this subnet.
  - `enable_storage_service_endpoint` - (`bool`, optional, defaults to `false`) a flag that enables `Microsoft.Storage` service endpoint on a subnet. This is a suggested setting for the management interface when full bootstrapping using an Azure Storage Account is used.

  Example:
  ```hcl
  {
    "management" = {
      name                            = "management-snet"
      address_prefixes                = ["10.100.0.0/24"]
      network_security_group          = "network_security_group_1"
      route_table                     = "route_table_1"
      enable_storage_service_endpoint = true
    },
    "private" = {
      name                   = "private-snet"
      address_prefixes       = ["10.100.1.0/24"]
      network_security_group = "network_security_group_2"
      route_table            = "route_table_2"
    },
    "public" = {
      name                   = "public-snet"
      address_prefixes       = ["10.100.2.0/24"]
      network_security_group = "network_security_group_3"
      route_table            = "route_table_3"
    },
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
}

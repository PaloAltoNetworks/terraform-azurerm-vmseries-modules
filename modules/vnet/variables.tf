variable "name_prefix" {
  description = "A prefix added to all resource names created by this module: VNET, NSGs, RTs. Subnet, as a sub-resource is not prefixed."
  default     = ""
  type        = string
}

variable "name" {
  description = "The name of the Azure Virtual Network."
  type        = string
}

variable "create_virtual_network" {
  description = "If true, create the Virtual Network, otherwise just use a pre-existing network."
  default     = true
  type        = bool
}

variable "create_subnets" {
  description = "If true, create the Subnets inside the Virtual Network, otherwise use a pre-existing subnets."
  default     = true
  type        = bool
}

variable "location" {
  description = "Location of the resources that will be deployed."
  type        = string
}

variable "tags" {
  description = "Map of tags to assign to all of the created resources."
  type        = map(any)
  default     = {}
}

variable "resource_group_name" {
  description = "Name of the Resource Group to use."
  type        = string
}

variable "address_space" {
  description = "The address space used by the virtual network. You can supply more than one address space."
  type        = list(string)
}

variable "network_security_groups" {
  description = <<-EOF
  Map of Network Security Groups to create.
  List of available attributes of each Network Security Group entry:
  - `name` : Name of the Network Security Group.
  - `location` : (Optional) Specifies the Azure location where to deploy the resource.
  - `rules`: (Optional) A list of objects representing a Network Security Rule. The key of each entry acts as the name of the rule and
      needs to be unique across all rules in the Network Security Group.
      List of attributes available to define a Network Security Rule.
      Notice, all port values are integers between `0` and `65535`. Port ranges can be specified as `minimum-maximum` port value, example: `21-23`:
      - `priority` : Numeric priority of the rule. The value can be between 100 and 4096 and must be unique for each rule in the collection.
      The lower the priority number, the higher the priority of the rule.
      - `direction` : The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are `Inbound` and `Outbound`.
      - `access` : Specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`.
      - `protocol` : Network protocol this rule applies to. Possible values include `Tcp`, `Udp`, `Icmp`, or `*` (which matches all). For supported values refer to the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule#protocol)
      - `source_port_range` : A source port or a range of ports. This can also be an `*` to match all.
      - `source_port_ranges` : A list of source ports or ranges of ports. This can be specified only if `source_port_range` was not used.
      - `destination_port_range` : A destination port or a range of ports. This can also be an `*` to match all.
      - `destination_port_ranges` : A list of destination ports or a ranges of ports. This can be specified only if `destination_port_range` was not used.
      - `source_address_prefix` : Source CIDR or IP range or `*` to match any IP. This can also be a tag. To see all available tags for a region use the following command (example for US West Central): `az network list-service-tags --location westcentralus`.
      - `source_address_prefixes` : A list of source address prefixes. Tags are not allowed. Can be specified only if `source_address_prefix` was not used.
      - `destination_address_prefix` : Destination CIDR or IP range or `*` to match any IP. Tags are allowed, see `source_address_prefix` for details.
      - `destination_address_prefixes` : A list of destination address prefixes. Tags are not allowed. Can be specified only if `destination_address_prefix` was not used.

  Example:
  ```
  {
    "nsg_1" = {
      name = "network_security_group_1"
      location = "Australia Central"
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
}

variable "route_tables" {
  description = <<-EOF
  Map of objects describing a Route Table.
  List of available attributes of each Route Table entry:
  - `name`: Name of a Route Table.
  - `location` : (Optional) Specifies the Azure location where to deploy the resource.
  - `routes` : (Optional) Map of routes within the Route Table.
    List of available attributes of each route entry:
    - `address_prefix` : The destination CIDR to which the route applies, such as `10.1.0.0/16`.
    - `next_hop_type` : The type of Azure hop the packet should be sent to.
      Possible values are: `VirtualNetworkGateway`, `VnetLocal`, `Internet`, `VirtualAppliance` and `None`.
    - `next_hop_in_ip_address` : Contains the IP address packets should be forwarded to. 
      Next hop values are only allowed in routes where the next hop type is `VirtualAppliance`.

  Example:
  ```
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
}

variable "subnets" {
  description = <<-EOF
  Map of subnet objects to create within a virtual network. If `create_subnets` is set to `false` this is just a mapping between the existing subnets and UDRs and NSGs that should be assigned to them.
  
  List of available attributes of each subnet entry:
  - `name` - Name of a subnet.
  - `address_prefixes` : The address prefix to use for the subnet. Only required when a subnet will be created.
  - `network_security_group` : The Network Security Group identifier to associate with the subnet.
  - `route_table_id` : The Route Table identifier to associate with the subnet.
  - `enable_storage_service_endpoint` : Flag that enables `Microsoft.Storage` service endpoint on a subnet. This is a suggested setting for the management interface when full bootstrapping using an Azure Storage Account is used. Defaults to `false`.
  Example:
  ```
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
}

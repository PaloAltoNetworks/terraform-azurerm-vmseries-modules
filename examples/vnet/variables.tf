variable "virtual_network_name" {
  description = "The name of the VNet to create."
  type        = string
}

variable "location" {
  description = "Location of the resources that will be deployed."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to all of the created resources."
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
  A map of Network Security Groups objects to create. The key of each entry acts as the Network Security Group name.
  List of arguments available to define a Network Security Group:
  - `location` : (Optional) Specifies the Azure location where to deploy the resource.
  - `rules`: A list of objects representing a Network Security Rule. The key of each entry acts as the name of the rule and
      needs to be unique across all rules in the Network Security Group.
      List of arguments available to define Network Security Rules:
      - `priority` : Specifies the priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. 
      The lower the priority number, the higher the priority of the rule.
      - `direction` : The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are `Inbound` and `Outbound`.
      - `access` : Specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`.
      - `protocol` : Network protocol this rule applies to. Possible values include `Tcp`, `Udp`, `Icmp`, or `*` (which matches all).
      - `source_port_range` : List of source ports or port ranges.
      - `destination_port_range` : Destination Port or Range. Integer or range between `0` and `65535` or `*` to match any.
      - `source_address_prefix` : List of source address prefixes. Tags may not be used.
      - `destination_address_prefix` : CIDR or destination IP range or `*` to match any IP.


  Example:
  ```
  {
    "network_security_group_1" = {
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
  A map of objects describing a Route Table. The key of each entry acts as the Route Table name.
  List of arguments available to define a Route Table:
  - `location` : (Optional) Specifies the Azure location where to deploy the resource.
  - `routes` : (Optional) A map of routes within a Route Table.
    List of arguments available to define a Route:
    - `address_prefix` : The destination CIDR to which the route applies, such as `10.1.0.0/16`.
    - `next_hop_type` : The type of Azure hop the packet should be sent to.
    Possible values are: `VirtualNetworkGateway`, `VnetLocal`, `Internet`, `VirtualAppliance` and `None`.
    - `next_hop_in_ip_address` : Contains the IP address packets should be forwarded to. 
    Next hop values are only allowed in routes where the next hop type is `VirtualAppliance`.

  Example:
  ```
  {
    "route_table_1" = {
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
    "route_table_2" = {
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
}

variable "subnets" {
  description = <<-EOF
  A map of subnet objects to create within a Virtual Network. The key of each entry acts as the subnet name.
  List of arguments available to define a subnet:
  - `address_prefixes` : The address prefix to use for the subnet.
  - `network_security_group_id` : The Network Security Group ID which should be associated with the subnet.
  - `route_table_id` : The Route Table ID which should be associated with the subnet.
  - `tags` : (Optional) A mapping of tags to assign to the resource.
  
  Example:
  ```
  {
    "management" = {
      address_prefixes       = ["10.100.0.0/24"]
      network_security_group = "network_security_group_1"
      route_table            = "route_table_1"
    },
    "private" = {
      address_prefixes       = ["10.100.1.0/24"]
      network_security_group = "network_security_group_2"
      route_table            = "route_table_2"
    },
    "public" = {
      address_prefixes       = ["10.100.2.0/24"]
      network_security_group = "network_security_group_3"
      route_table            = "route_table_3"
    },
  }
  ```
  EOF
}

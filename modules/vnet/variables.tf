variable "virtual_network_name" {
  description = "The name of the VNet to create."
  type        = string
}

variable "location" {
  description = "Location of the resources that will be deployed. By default, uses the location obtained from the Resource Group Data Source."
  type        = string
  default     = ""
}

variable tags {
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
  A map of network security groups objects to create. The object `key` acts as the network security group name.
  List of arguments available to define a network security group:
  - `location` : Specifies the supported Azure location where to deploy the resource,
  by default uses the location from the Resource Group Data Source.
  - `resource_group_name` : Name of an existing resource group in which to create the network security group,
  by default uses the Resource Group name from the Resource Group Data Source.

  Example:
  ```
  {
    "network_security_group_1" = {
      location = "Australia Central"
    },
    "network_security_group_2" = {}
  }
  ```
  EOF
}

variable "network_security_rules" {
  description = <<-EOF
  A map of network security rules objects to create.
  List of arguments available to define network security rules:
  - `name`: The name of the security rule. This needs to be unique across all Rules in the Network Security Group. 
  - `resource_group_name` : Name of an existing resource group in which to create the network security rules,
  by default uses the Resource Group name from the Resource Group Data Source.
  - `network_security_group_name` : The name of the Network Security Group that we want to attach the rule to.
  - `priority` : Specifies the priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. 
  The lower the priority number, the higher the priority of the rule.
  - `direction` : The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are `Inbound` and `Outbound`.
  - `access` : Specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`.
  - `protocol` : Network protocol this rule applies to. Possible values include `Tcp`, `Udp`, `Icmp`, or `*` (which matches all).
  - `source_port_range` : List of source ports or port ranges.
  - `destination_port_range` : Destination Port or Range. Integer or range between `0` and `65535` or `*` to match any.
  - `source_address_prefix` : List of source address prefixes. Tags may not be used.
  - `destination_address_prefix` : CIDR or destination IP range or * to match any IP. 
  Tags such as ‘VirtualNetwork’, ‘AzureLoadBalancer’ and ‘Internet’ can also be used.
  
  Example:
  ```
  {
    "AllOutbound" = {
      network_security_group_name = "network_security_group_1"
      priority                    = 100
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
    }
  }
  ```
  EOF
}

variable "route_tables" {
  description = <<-EOF
  A map of objects describing a route table. The object `key` acts as the route table name.
  List of arguments available to define a route table:
  - `location` : Specifies the supported Azure location where to deploy the resource,
  by default uses the location from the Resource Group Data Source.
  - `resource_group_name` : Name of an existing resource group in which to create the route table,
  by default uses the Resource Group name from the Resource Group Data Source.

  Example:
  ```
  {
    "route_table_1" = {
      location = "East US"
    },
    "route_table_2" = {},
    "route_table_3" = {},
  }
  ```
  EOF
}

variable "routes" {
  description = <<-EOF
  A map of objects describing routes within a route table. The object `key` acts as the route name.
  List of arguments available to define a route table:
  - `resource_group_name` : Name of an existing resource group in which to create the route table,
  by default uses the Resource Group name from the Resource Group Data Source.
  - `route_table_name` : The name of the route table within which create the route.
  - `address_prefix` : The destination CIDR to which the route applies, such as `10.1.0.0/16`.
  - `next_hop_type` : The type of Azure hop the packet should be sent to. 
  Possible values are `VirtualNetworkGateway`, `VnetLocal`, `Internet`, `VirtualAppliance` and `None`.

  Example:
  ```
  {
    "route_1" = {
      route_table_name = "route_table_1"
      address_prefix   = "10.1.0.0/16"
      next_hop_type    = "vnetlocal"
    },
    "route_2" = {
      route_table_name = "route_table_2"
      address_prefix   = "10.2.0.0/16"
      next_hop_type    = "vnetlocal"
    },
  }
  ```
  EOF
}

variable "subnets" {
  description = <<-EOF
  A map of subnet objects to create within a Virtual Network. The object `key` acts as the subnet name.
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

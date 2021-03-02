Palo Alto Networks VNet Module for Azure
===========

A terraform module for deploying a Virtual Network and its components required for the VM-Series firewalls in Azure.

Usage
-----

```hcl
module "vnet" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/vnet"

  virtual_network_name = "example-vnet"
  resource_group_name  = azurerm_resource_group.this.name
  address_space        = ["10.100.0.0/16"]
  tags = {
    env = "Test"
  }

  network_security_groups = {
    "network_security_group_1" = {}
  }

  network_security_rules = {
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

  route_tables = {
    "route_table_1" = {},
    "route_table_2" = {},
    "route_table_3" = {},
  }

  routes = {
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
    "route_3" = {
      route_table_name = "route_table_3"
      address_prefix   = "10.3.0.0/16"
      next_hop_type    = "vnetlocal"
    },
  }

  subnets = {
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

  depends_on = [azurerm_resource_group.this]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13, <= 0.14 |

## Providers

| Name | Version |
|------|---------|
| azurerm | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| address\_space | The address space used by the virtual network. You can supply more than one address space. | `list(string)` | n/a | yes |
| location | Location of the resources that will be deployed. By default, uses the location obtained from the Resource Group Data Source. | `string` | `""` | no |
| network\_security\_groups | A map of network security groups objects to create. The object `key` acts as the network security group name.<br>List of arguments available to define a network security group:<br>- `location` : Specifies the supported Azure location where to deploy the resource,<br>by default uses the location from the Resource Group Data Source.<br>- `resource_group_name` : Name of an existing resource group in which to create the network security group,<br>by default uses the Resource Group name from the Resource Group Data Source.<br><br>Example:<pre>{<br>  "network_security_group_1" = {<br>    location = "Australia Central"<br>  },<br>  "network_security_group_2" = {}<br>}</pre> | `any` | n/a | yes |
| network\_security\_rules | A map of network security rules objects to create.<br>List of arguments available to define network security rules:<br>- `name`: The name of the security rule. This needs to be unique across all Rules in the Network Security Group. <br>- `resource_group_name` : Name of an existing resource group in which to create the network security rules,<br>by default uses the Resource Group name from the Resource Group Data Source.<br>- `network_security_group_name` : The name of the Network Security Group that we want to attach the rule to.<br>- `priority` : Specifies the priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. <br>The lower the priority number, the higher the priority of the rule.<br>- `direction` : The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are `Inbound` and `Outbound`.<br>- `access` : Specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`.<br>- `protocol` : Network protocol this rule applies to. Possible values include `Tcp`, `Udp`, `Icmp`, or `*` (which matches all).<br>- `source_port_range` : List of source ports or port ranges.<br>- `destination_port_range` : Destination Port or Range. Integer or range between `0` and `65535` or `*` to match any.<br>- `source_address_prefix` : List of source address prefixes. Tags may not be used.<br>- `destination_address_prefix` : CIDR or destination IP range or \* to match any IP. <br>Tags such as ‘VirtualNetwork’, ‘AzureLoadBalancer’ and ‘Internet’ can also be used.<br><br>Example:<pre>{<br>  "AllOutbound" = {<br>    network_security_group_name = "network_security_group_1"<br>    priority                    = 100<br>    direction                   = "Outbound"<br>    access                      = "Allow"<br>    protocol                    = "Tcp"<br>    source_port_range           = "*"<br>    destination_port_range      = "*"<br>    source_address_prefix       = "*"<br>    destination_address_prefix  = "*"<br>  }<br>}</pre> | `any` | n/a | yes |
| resource\_group\_name | Name of the Resource Group to use. | `string` | n/a | yes |
| route\_tables | A map of objects describing a route table. The object `key` acts as the route table name.<br>List of arguments available to define a route table:<br>- `location` : Specifies the supported Azure location where to deploy the resource,<br>by default uses the location from the Resource Group Data Source.<br>- `resource_group_name` : Name of an existing resource group in which to create the route table,<br>by default uses the Resource Group name from the Resource Group Data Source.<br><br>Example:<pre>{<br>  "route_table_1" = {<br>    location = "East US"<br>  },<br>  "route_table_2" = {},<br>  "route_table_3" = {},<br>}</pre> | `any` | n/a | yes |
| routes | A map of objects describing routes within a route table. The object `key` acts as the route name.<br>List of arguments available to define a route table:<br>- `resource_group_name` : Name of an existing resource group in which to create the route table,<br>by default uses the Resource Group name from the Resource Group Data Source.<br>- `route_table_name` : The name of the route table within which create the route.<br>- `address_prefix` : The destination CIDR to which the route applies, such as `10.1.0.0/16`.<br>- `next_hop_type` : The type of Azure hop the packet should be sent to. <br>Possible values are `VirtualNetworkGateway`, `VnetLocal`, `Internet`, `VirtualAppliance` and `None`.<br><br>Example:<pre>{<br>  "route_1" = {<br>    route_table_name = "route_table_1"<br>    address_prefix   = "10.1.0.0/16"<br>    next_hop_type    = "vnetlocal"<br>  },<br>  "route_2" = {<br>    route_table_name = "route_table_2"<br>    address_prefix   = "10.2.0.0/16"<br>    next_hop_type    = "vnetlocal"<br>  },<br>}</pre> | `any` | n/a | yes |
| subnets | A map of subnet objects to create within a Virtual Network. The object `key` acts as the subnet name.<br>List of arguments available to define a subnet:<br>- `address_prefixes` : The address prefix to use for the subnet.<br>- `network_security_group_id` : The Network Security Group ID which should be associated with the subnet.<br>- `route_table_id` : The Route Table ID which should be associated with the subnet.<br>- `tags` : (Optional) A mapping of tags to assign to the resource.<br><br>Example:<pre>{<br>  "management" = {<br>    address_prefixes       = ["10.100.0.0/24"]<br>    network_security_group = "network_security_group_1"<br>    route_table            = "route_table_1"<br>  },<br>  "private" = {<br>    address_prefixes       = ["10.100.1.0/24"]<br>    network_security_group = "network_security_group_2"<br>    route_table            = "route_table_2"<br>  },<br>  "public" = {<br>    address_prefixes       = ["10.100.2.0/24"]<br>    network_security_group = "network_security_group_3"<br>    route_table            = "route_table_3"<br>  },<br>}</pre> | `any` | n/a | yes |
| tags | A mapping of tags to assign to all of the created resources. | `map(any)` | `{}` | no |
| virtual\_network\_name | The name of the VNet to create. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| subnet\_id | The ID of the created Subnet. |
| virtual\_network\_id | The ID of the created Virtual Network. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

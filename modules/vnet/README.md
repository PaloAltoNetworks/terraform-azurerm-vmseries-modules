<!-- BEGIN_TF_DOCS -->
# Palo Alto Networks VNet Module for Azure

A Terraform module for deploying a Virtual Network and its components required for the VM-Series firewalls in Azure.

## Usage

This module is designed to work in several *modes* depending on which variables or flags are set. Most common usage scenarios are:

- create all -  creates a VNET, Subnet, NSGs and Route Tables. In this example the two latter are assigned to the Subnet. The NSG and Route Table have rules defined:
  ```hcl
  name                = "transit"
  resource_group_name = "existing-rg"
  address_space       = ["10.0.0.0/25"]
  network_security_groups = {
    inbound = {
      name = "inbound-nsg"
      rules = {
        mgmt_inbound = {
          name                       = "allow-traffic"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_address_prefixes    = ["1.2.3.4"]
          source_port_range          = "*"
          destination_address_prefix = "10.0.0.0/28"
          destination_port_ranges    = ["22", "443"]
        }
      }
    }
  }
  route_tables = {
    default = {
      name = "default-rt"
      routes = {
        "default" = {
          name                   = "default-udr"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "5.6.7.8"
        }
      }
    }
  }
  subnets = {
    "subnet" = {
      name                   = "snet"
      address_prefixes       = ["10.0.0.0/28"]
      network_security_group = "inbound"
      route_table            = "default"
    }
  }
  ```

- source a VNET but create Subnets, NSGs and Route Tables. This is a similar example to the above one, NSG and Route Table are empty this time:

  ```hcl
  create_virtual_network = false
  name                   = "existing-vnet"
  resource_group_name    = "existing-rg"
  network_security_groups = {
    inbound = { name = "inbound-nsg" }
  }
  route_tables = {
    default = { name = "default-rt" }
  }
  subnets = {
    "subnet" = {
      name                   = "snet"
      address_prefixes       = ["10.0.0.0/28"]
      network_security_group = "inbound"
      route_table            = "default"
    }
  }
  ```

- source a VNET and Subnet, but create NSGs and Route Tables. This is a common brownfield use case: we will source Subnets, and create and assign NSGs and Route Tables to them:

  ```hcl
  create_virtual_network = false
  name                   = "existing-vnet"
  resource_group_name    = "existing-rg"
  network_security_groups = {
    inbound = {
      name = "inbound-nsg"
      rules = {
        mgmt_inbound = {
          name                       = "allow-traffic"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_address_prefixes    = ["1.2.3.4"]
          source_port_range          = "*"
          destination_address_prefix = "10.0.0.0/28"
          destination_port_ranges    = ["22", "443"]
        }
      }
    }
  }
  route_tables = {
    default = {
      name = "default-rt"
      routes = {
        "default" = {
          name                   = "default-udr"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "5.6.7.8"
        }
      }
    }
  }
  create_subnets = false
  subnets = {
    "subnet" = {
      name                   = "snet"
      network_security_group = "inbound"
      route_table            = "default"
    }
  }
  ```

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`name`](#name) | `string` | The name of the Azure Virtual Network.
[`resource_group_name`](#resource_group_name) | `string` | Name of the Resource Group to use.
[`location`](#location) | `string` | Location of the deployed resources.


## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`tags`](#tags) | `map` | Map of tags to assign to all created resources.
[`create_virtual_network`](#create_virtual_network) | `bool` | Controls Virtual Network creation.
[`address_space`](#address_space) | `list` | The address space used by the virtual network.
[`network_security_groups`](#network_security_groups) | `map` | Map of objects describing Network Security Groups.
[`route_tables`](#route_tables) | `map` | Map of objects describing a Route Tables.
[`create_subnets`](#create_subnets) | `bool` | Controls subnet creation.
[`subnets`](#subnets) | `map` | Map of objects describing subnets to manage.



## Module's Outputs

Name |  Description
--- | ---
`virtual_network_id` | The identifier of the created or sourced Virtual Network.
`vnet_cidr` | VNET address space.
`subnet_ids` | The identifiers of the created or sourced Subnets.
`subnet_cidrs` | Subnet CIDRs (sourced or created).
`network_security_group_ids` | The identifiers of the created Network Security Groups.
`route_table_ids` | The identifiers of the created Route Tables.

## Module's Nameplate


Requirements needed by this module:

- `terraform`, version: >= 1.3, < 2.0
- `azurerm`, version: ~> 3.25


Providers used in this module:

- `azurerm`, version: ~> 3.25




Resources used in this module:

- `network_security_group` (managed)
- `network_security_rule` (managed)
- `route` (managed)
- `route_table` (managed)
- `subnet` (managed)
- `subnet_network_security_group_association` (managed)
- `subnet_route_table_association` (managed)
- `virtual_network` (managed)
- `subnet` (data)
- `virtual_network` (data)

## Inputs/Outpus details

### Required Inputs


#### name

The name of the Azure Virtual Network.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>

#### resource_group_name

Name of the Resource Group to use.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>

#### location

Location of the deployed resources.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>










### Optional Inputs





#### tags

Map of tags to assign to all created resources.

Type: map(string)

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### create_virtual_network

Controls Virtual Network creation. If `true`, create the Virtual Network, otherwise just use a pre-existing network.

Type: bool

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>

#### address_space

The address space used by the virtual network. You can supply more than one address space. Required only when you create a VNET.

Type: list(string)

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### network_security_groups

Map of objects describing Network Security Groups.

List of available properties:

- `name`   - (`string`, required) name of the Network Security Group.
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
  "nsg_2" = {
    name = "empty-nsg
  }
}
```


Type: 

```hcl
map(object({
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
```


Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### route_tables

Map of objects describing a Route Tables.

List of available properties:

- `name`          - (`string`, required) name of a Route Table.
- `routes`        - (`map`, required) a map of Route Table entries (UDRs):
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


Type: 

```hcl
map(object({
    name = string
    routes = map(object({
      name                = string
      address_prefix      = string
      next_hop_type       = string
      next_hop_ip_address = optional(string)
    }))
  }))
```


Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### create_subnets

Controls subnet creation.
  
Possible variants:

- `true`  - create subnets described in `var.subnets`
- `false` - source subnets described in `var.subnets`
- `false` and `var.subnets` is empty - skip subnets management.


Type: bool

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>

#### subnets

Map of objects describing subnets to manage.
  
By the default the described subnets will be created. 
If however `create_subnets` is set to `false` this is just a mapping between the existing subnets and UDRs and NSGs that should be assigned to them.
  
List of available attributes of each subnet entry:

- `name`                            - (`string`, required) name of a subnet.
- `address_prefixes`                - (`list(string)`, required when `create_subnets = true`) a list of address prefixes within VNET's address space to assign to a created subnet.
- `network_security_group_key`      - (`string`, optional, defaults to `null`) a key identifying an NSG defined in `network_security_groups` that should be assigned to this subnet.
- `route_table_key`                 - (`string`, optional, defaults to `null`) a key identifying a Route Table defined in `route_tables` that should be assigned to this subnet.
- `enable_storage_service_endpoint` - (`bool`, optional, defaults to `false`) a flag that enables `Microsoft.Storage` service endpoint on a subnet.
                                      This is a suggested setting for the management interface when full bootstrapping using an Azure Storage Account is used.

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


Type: 

```hcl
map(object({
    name                            = string
    address_prefixes                = optional(list(string), [])
    network_security_group_key      = optional(string)
    route_table_key                 = optional(string)
    enable_storage_service_endpoint = optional(bool, false)
  }))
```


Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>


<!-- END_TF_DOCS -->
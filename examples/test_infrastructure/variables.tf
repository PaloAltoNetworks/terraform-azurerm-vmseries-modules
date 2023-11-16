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
  
  NOTICE. This prefix is not applied to existing resources.
  If you plan to reuse i.e. a VNET please specify it's full name, even if it is also prefixed with the same value as the one in this property.
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
    name                    = string
    resource_group_name     = optional(string)
    create_virtual_network  = optional(bool, true)
    address_space           = optional(list(string))
    hub_resource_group_name = optional(string)
    hub_vnet_name           = optional(string)
    network_security_groups = optional(map(object({
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

variable "hub_resource_group_name" {
  description = "Name of the Resource Group hosting the hub/transit infrastructure. This value is required to create peering between the spoke and the hub VNET."
  type        = string
  default     = null
}

variable "hub_vnet_name" {
  description = "Name of the hub/transit VNET. This value is required to create peering between the spoke and the hub VNET."
  type        = string
  default     = null
}

variable "vm_size" {
  description = "Azure test VM size."
  default     = "Standard_D1_v2"
  type        = string
}

variable "username" {
  description = "Name of the VM admin account."
  default     = "panadmin"
  type        = string
}

variable "password" {
  description = "A password for the admin account."
  default     = null
  type        = string
}

variable "test_vms" {
  description = <<-EOF
  A map defining test VMs.

  Values contain the following elements:

  - `name`: a name of the VM
  - `vnet_key`: a key describing a VNET defined in `var.vnets`
  - `subnet_key`: a key describing a subnet found in a VNET definition

  EOF
  default     = {}
  type = map(object({
    name       = string
    vnet_key   = string
    subnet_key = string
  }))
}

variable "bastions" {
  description = <<-EOF
  A map containing Azure Bastion definitions.

  This map follows resource definition convention, following values are available:
  - `name`: Bastion name
  - `vnet_key`: a key describing a VNET defined in `var.vnets`. This VNET should already have an existing subnet called `AzureBastionSubnet` (the name is hardcoded by Microsoft).
  - `subnet_key`: a key pointing to a subnet dedicated to a Bastion deployment (the name should be `AzureBastionSubnet`.)

  EOF
  default     = {}
  type = map(object({
    name       = string
    vnet_key   = string
    subnet_key = string
  }))
}
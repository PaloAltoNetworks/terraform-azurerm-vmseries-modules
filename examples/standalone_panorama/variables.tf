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
  
  **Note!** \
  This prefix is not applied to existing resources. If you plan to reuse i.e. a VNET please specify it's full name, even if it is also prefixed with the same value as the one in this property.
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


### PANORAMA
variable "availability_sets" {
  description = <<-EOF
  A map defining availability sets. Can be used to provide infrastructure high availability when zones cannot be used.

  Following properties are supported:
  - `name` - name of the Application Insights.
  - `update_domain_count` - specifies the number of update domains that are used, defaults to 5 (Azure defaults).
  - `fault_domain_count` - specifies the number of fault domains that are used, defaults to 3 (Azure defaults).

  Please keep in mind that Azure defaults are not working for each region (especially small ones, w/o any Availability Zones).
  Please verify how many update and fault domains are supported in a region before deploying this resource.
  EOF
  default     = {}
  nullable    = false
  type = map(object({
    name                = string
    update_domain_count = optional(number, 5)
    fault_domain_count  = optional(number, 3)
  }))
}

variable "panoramas" {
  description = <<-EOF
  A map defining Azure Virtual Machine based on Palo Alto Networks Panorama image.
  
  For details and defaults for available options please refer to the [`panorama`](../../modules/panorama/README.md) module.

  The basic Panorama VM configuration properties are as follows:

  - `name`            - (`string`, required) name of the VM, will be prefixed with the value of `var.name_prefix`.
  - `authentication`  - (`map`, optional, defaults to example defaults) authentication settings for the deployed VM.

      The `authentication` property is optional and holds the firewall admin access details. By default, standard username
      `panadmin` will be set and a random password will be auto-generated for you (available in Terraform outputs).

      **Note!** \
      The `disable_password_authentication` property is by default `false` in this example. When using this value, you don't have
      to specify anything but you can still additionally pass SSH keys for authentication. You can however set this property to 
      `true`, then you have to specify `ssh_keys` property.

      For all properties and their default values see [module's documentation](../../modules/panorama/README.md#authentication).

  - `image`           - (`map`, required) properties defining a base image used by the deployed VM.

      The `image` property is required but there are only 2 properties (mutually exclusive) that have to be set, either:

      - `version`   - (`string`) describes the PAN-OS image version from Azure Marketplace.
      - `custom_id` - (`string`) absolute ID of your own custom PAN-OS image.

      For details on the other properties refer to [module's documentation](../../modules/panorama/README.md#image).

  - `virtual_machine` - (`map`, optional, defaults to module defaults) a map that groups most common VM configuration options.

      Following properties are available:

      - `vnet_key`  - (`string`, required) a key of a VNET defined in `var.vnets`. This is the VNET that hosts subnets used to
                      deploy network interfaces for deployed VM.
      - `size`      - (`string`, optional, defaults to module defaults) Azure VM size (type). Consult the *VM-Series Deployment
                      Guide* as only a few selected sizes are supported.
      - `zone`      - (`string`, optional, defaults to module defaults) the Availability Zone in which the VM will be created.
      - `disk_type` - (`string`, optional, defaults to module defaults) type of a Managed Disk which should be created, possible
                      values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS` (works only for selected `size` values).
      
      For details on the other properties refer to [module's documentation](../../modules/panorama/README.md#virtual_machine).

  - `interfaces`      - (`list`, required) configuration of all network interfaces, order does matter - the 1<sup>st</sup>
                        interface should be the management one. 
                        
      Following properties are available:

      - `name`             - (`string`, required) name of the network interface (will be prefixed with `var.name_prefix`).
      - `subnet_key`       - (`string`, required) a key of a subnet to which the interface will be assigned as defined in
                             `var.vnets`.
      - `create_public_ip` - (`bool`, optional, defaults to module defaults) create a Public IP for an interface.

      For details on the other properties refer to [module's documentation](../../modules/panorama/README.md#interfaces).

  - `logging_disks`   - (`map`, optional, defaults to `null`) configuration of additional data disks for Panorama logs. 
  
      Following properties are available:

      - `name` - (`string`, required) the Managed Disk name.
      - `lun`  - (`string`, required) the Logical Unit Number of the Data Disk, which needs to be unique within the VM.

      For details on the other properties refer to [module's documentation](../../modules/panorama/README.md#logging_disks).
  EOF
  default     = {}
  nullable    = false
  type = map(object({
    name = string
    authentication = object({
      username                        = optional(string, "panadmin")
      password                        = optional(string)
      disable_password_authentication = optional(bool, false)
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
      vnet_key                   = string
      size                       = optional(string)
      zone                       = string
      disk_type                  = optional(string)
      disk_name                  = optional(string)
      avset_key                  = optional(string)
      encryption_at_host_enabled = optional(bool)
      disk_encryption_set_id     = optional(string)
      diagnostics_storage_uri    = optional(string)
      identity_type              = optional(string)
      identity_ids               = optional(list(string))
    })
    interfaces = list(object({
      name                          = string
      subnet_key                    = string
      private_ip_address            = optional(string)
      create_public_ip              = optional(bool, false)
      public_ip_name                = optional(string)
      public_ip_resource_group_name = optional(string)
    }))
    logging_disks = optional(map(object({
      name      = string
      size      = optional(string)
      lun       = string
      disk_type = optional(string)
    })), {})
  }))
}

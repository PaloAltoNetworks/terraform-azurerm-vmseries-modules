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
  description = "Name of the Resource Group to ."
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
  A map defining VNETs. A key is the VNET name, value is a set of properties like described below.
  
  For detailed documentation on each property refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/blob/v0.5.0/modules/vnet/README.md)

  - `name` : a name of a Virtual Network
  - `create_virtual_network` : (default: `true`) when set to `true` will create a VNET, `false` will source an existing VNET
  - `address_space` : a list of CIDRs for VNET
  - `resource_group_name` :  (default: current RG) a name of a Resource Group in which the VNET will reside

  - `create_subnets` : (default: `true`) if true, create the Subnets inside the Virtual Network, otherwise use pre-existing subnets
  - `subnets` : map of Subnets to create

  - `network_security_groups` : map of Network Security Groups to create
  - `route_tables` : map of Route Tables to create.
  EOF
}



### PANORAMA
variable "vmseries_username" {
  description = "Initial administrative username to use for all systems."
  default     = "panadmin"
  type        = string
}

variable "vmseries_password" {
  description = "Initial administrative password to use for all systems. Set to null for an auto-generated password."
  default     = null
  type        = string
}

variable "panorama_version" {
  description = "Panorama PanOS version. It's also possible to specify the Pan-OS version per Panorama (in case you would like to deploy more than one), see `var.panoramas` variable."
  type        = string
}
variable "panorama_sku" {
  description = "Panorama SKU, basically a type of licensing used in Azure."
  default     = "byol"
  type        = string
}
variable "panorama_size" {
  description = "A size of a VM that will run Panorama. It's also possible to specify the the VM size per Panorama, see `var.panoramas` variable."
  default     = "Standard_D5_v2"
  type        = string
}
variable "panoramas" {
  description = <<-EOF
  A map containing Panorama definitions.
  
  All definitions share a VM size, SKU and PanOS version (`panorama_size`, `panorama_sku`, `panorama_version` respectively). Defining more than one Panorama makes sense when creating for example HA pairs. 

  Following properties are available:

  - `name` : a name of a Panorama VM
  - `size` : size of the Panorama virtual machine, when specified overrides `var.panorama_size`.
  - `version` : PanOS version, when specified overrides `var.panorama_version`.
  - `vnet_key`: a VNET used to host Panorama VM, this is a key from a VNET definition stored in `vnets` variable
  - `subnet_key`: a Subnet inside a VNET used to host Panorama VM, this is a key from a Subnet definition stored inside a VNET definition references by the `vnet_key` property
  - `avzone`: when `enable_zones` is `true` this specifies the zone in which Panorama will be deployed
  - `avzones`: when `enable_zones` is `true` these are availability zones used by Panorama's public IPs
  - `custom_image_id`: a custom build of Panorama to use, overrides the stock image version.

  - `interfaces` : configuration of all NICs assigned to a VM. A list of maps, each map is a NIC definition. Notice that the order DOES matter. NICs are attached to VMs in Azure in the order they are defined in this list, therefore the management interface has to be defined first. Following properties are available:
    - `name`: string that will form the NIC name
    - `subnet_key` : (string) a key of a subnet as defined in `var.vnets`
    - `create_pip` : (boolean) flag to create Public IP for an interface, defaults to `false`
    - `public_ip_name` : (string) when `create_pip` is set to `false` a name of a Public IP resource that should be associated with this Network Interface
    - `public_ip_resource_group` : (string) when associating an existing Public IP resource, name of the Resource Group the IP is placed in, defaults to the `var.resource_group_name`
    - `private_ip_address` : (string) a static IP address that should be assigned to an interface, defaults to `null` (in that case DHCP is used)

  - `logging_disks` : a map containing configuration of additional disks that should be attached to a Panorama appliance. Following properties are available:
    - `size` : size of a disk, 2TB by default
    - `lun` : slot to which the disk should be attached
    - `disk_type` : type of a disk, determines throughput, `Standard_LRS` by default.

  Example:

  ```
    {
      "pn-1" = {
        name     = "panorama01"
        vnet_key = "vnet"
        interfaces = [
          {
            name               = "management"
            subnet_key         = "panorama"
            private_ip_address = "10.1.0.10"
            create_pip         = true
          },
        ]
      }
    }
  ```
  EOF
  default     = {}
  type        = any
}

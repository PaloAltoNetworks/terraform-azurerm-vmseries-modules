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

  - `name` :  A name of a VNET.
  - `create_virtual_network` : (default: `true`) when set to `true` will create a VNET, `false` will source an existing VNET, in both cases the name of the VNET is specified with `name`
  - `address_space` : a list of CIDRs for VNET
  - `resource_group_name` :  (default: current RG) a name of a Resource Group in which the VNET will reside

  - `create_subnets` : (default: `true`) if true, create the Subnets inside the Virtual Network, otherwise use pre-existing subnets
  - `subnets` : map of Subnets to create

  - `network_security_groups` : map of Network Security Groups to create
  - `route_tables` : map of Route Tables to create.
  EOF
  type        = any
}

variable "nva_ilb_ip" {
  description = "An IP address of the private Load Balancer in front of the NGFWs. This IP will be used to create UDRs for the spoke VNETs."
  type        = string
}

variable "hub_resource_group_name" {
  description = "Name of the Resource Group hosting the hub/transit infrastructure. This value is required to create peering between the spoke and the hub VNET."
  type        = string
}

variable "hub_vnet_name" {
  description = "Name of the hub/transit VNET. This value is required to create peering between the spoke and the hub VNET."
  type        = string
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
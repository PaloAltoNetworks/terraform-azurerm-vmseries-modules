variable "location" {
  description = "The Azure region to use."
  default     = "East US 2"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group to create. If not provided, it will be auto-generated."
  default     = ""
  type        = string
}

variable "name_prefix" {
  description = "A prefix for all the names of the created Azure objects. It can end with a dash `-` character, if your naming convention prefers such separator."
  default     = "pantf"
  type        = string
}

variable "username" {
  description = "Initial administrative username to use for all systems."
  default     = "panadmin"
  type        = string
}

variable "password" {
  description = "Initial administrative password to use for all systems. Set to null for an auto-generated password."
  default     = null
  type        = string
}

variable "vmseries" {
  description = <<-EOF
  Map of virtual machines to create to run VM-Series. Keys are the individual names, values
  are the objects containing the attributes unique to that individual virtual machine:

  - `avzone`: the Azure Availability Zone identifier ("1", "2", "3"). Default is "1" in order to avoid non-HA deployments.
  - `trust_private_ip`: the static private IP to assign to the trust-side data interface (nic2). If unspecified, uses a dynamic IP.

  The hostname of each of the VM-Series will consist of a `name_prefix` concatenated with its map key.

  Basic:
  ```
  {
    "fw00" = { avzone = 1 }
    "fw01" = { avzone = 2 }
  }
  ```

  Full example:
  ```
  {
    "fw00" = {
      trust_private_ip = "192.168.0.10"
      avzone           = "1"
    }
    "fw01" = { 
      trust_private_ip = "192.168.0.11"
      avzone           = "2"
    }
  }
  ```
  EOF
}

variable "storage_account_name" {
  description = <<-EOF
  Default name of the storage account to create.
  The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters.
  EOF
  default     = "pantfstorage"
  type        = string
}

variable "files" {
  description = "Map of all files to copy to bucket. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\\`. For example `{\"dir/my.txt\" = \"config/init-cfg.txt\"}`"
  default     = {}
  type        = map(string)
}

variable "storage_share_name" {
  description = "Name of storage share to be created that holds `files` for bootstrapping."
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the VNet to create."
  type        = string
}

variable "address_space" {
  description = "The address space used by the virtual network. You can supply more than one address space."
  type        = list(string)
}

variable "network_security_groups" {
  description = "Definition of Network Security Groups to create. Refer to the `vnet` module documentation for more information."
}

variable "allow_inbound_mgmt_ips" {
  description = <<-EOF
    List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access management interfaces of VM-Series.
    If you use Panorama, include its address in the list (as well as the secondary Panorama's).
  EOF
  default     = []
  type        = list(string)
}

variable "allow_inbound_data_ips" {
  description = <<-EOF
    List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access public data interfaces of VM-Series.
    If the list is empty, the contents of `allow_inbound_mgmt_ips` are substituted instead.
  EOF
  default     = []
  type        = list(string)
}

variable "route_tables" {
  description = "Definition of Route Tables to create. Refer to the `vnet` module documentation for more information."
}

variable "subnets" {
  description = "Definition of Subnets to create. Refer to the `vnet` module documentation for more information."
}

variable "vnet_tags" {
  description = "A mapping of tags to assign to the created virtual network and other network-related resources. By default equals to `common_vmseries_tags`."
  type        = map(any)
  default     = {}
}

variable "olb_private_ip" {
  description = "The private IP address to assign to the outbound load balancer. This IP **must** fall in the `private_subnet` network."
  default     = "10.110.0.21"
  type        = string
}

variable "frontend_ips" {
  description = "A map of objects describing frontend IP configurations and rules for the inbound load balancer. See the [loadbalancer documentation](./modules/loadbalancer/README.md) for details."
}

variable "common_vmseries_sku" {
  description = "VM-series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "bundle2"
  type        = string
}

variable "common_vmseries_version" {
  description = "VM-series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "9.1.3"
  type        = string
}

variable "common_vmseries_vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported."
  default     = "Standard_D3_v2"
  type        = string
}

variable "common_vmseries_tags" {
  description = "A map of tags to be associated with the virtual machines, their interfaces and public IP addresses."
  default     = {}
  type        = map
}

variable "inbound_lb_name" {
  description = "Name of the inbound load balancer (the public-facing one)."
  default     = "lb_inbound"
  type        = string
}

variable "outbound_lb_name" {
  description = "Name of the outbound load balancer."
  default     = "lb_outbound"
  type        = string
}

### spoke vnet
variable "spoke_resource_group_name" {
  description = "Name for a created resource group."
  default     = null
  type        = string
}

variable "spoke_virtual_network_name" {
  description = "The name of the spoke VNet to create."
  type        = string
}

variable "spoke_address_space" {
  description = "The address space used by the spoke virtual network. You can supply more than one address space."
  type        = list(string)
}

variable "spoke_route_tables" {
  description = "Definition of Route Tables to create. Refer to the `VNet` module documentation for more information."
}

variable "spoke_subnets" {
  description = "Definition of Subnets to create. Refer to the `VNet` module documentation for more information."
}

variable "vmspoke" {
  description = <<-EOF
  Map of virtual machines to create to run sample VM. Keys are the individual names, values
  are the objects containing the attributes unique to that individual virtual machine:

  - `avzone`: the Azure Availability Zone identifier ("1", "2", "3"). If unspecified, the Availability Set is created instead.
  EOF
}

variable "spoke_vm_publisher" {
  description = "Specifies the publisher of the spoke image."
}

variable "spoke_vm_offer" {
  description = "Specifies the offer of the image from the Azure Marketplace"
}

variable "spoke_vm_sku" {
  description = "Spoke VM SKU from Azure Marketplace."
}

variable "spoke_vm_version" {
  description = "Spoke image version."
}

variable "spoke_vm_size" {
  description = "Spoke VM size (type) to be created."
}

variable "peering_spoke_name" {
  description = "A name definition for peering from spoke vnet to transit vnet."
}

variable "peering_common_name" {
  description = "A name definition for peering from transit vnet to spoke vnet."
}

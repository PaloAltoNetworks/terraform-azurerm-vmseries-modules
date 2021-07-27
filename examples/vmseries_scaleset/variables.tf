variable "resource_group_name" {
  description = "Name of the Resource Group to create."
  type        = string
}

variable "location" {
  description = "The Azure region to use."
  default     = "Australia Central"
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

variable "storage_account_name" {
  description = <<-EOF
  Default name of the storage account to create.
  The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters.
  EOF
  default     = "pantfstorage"
  type        = string
}

variable "inbound_files" {
  description = "Map of all files to copy to `inbound_storage_share_name`. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\\`. For example `{\"dir/my.txt\" = \"config/init-cfg.txt\"}`"
  default     = {}
  type        = map(string)
}

variable "outbound_files" {
  description = "Map of all files to copy to `outbound_storage_share_name`. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\\`. For example `{\"dir/my.txt\" = \"config/init-cfg.txt\"}`"
  default     = {}
  type        = map(string)
}

variable "inbound_storage_share_name" {
  description = "Name of storage share to be created that holds `files` for bootstrapping inbound VM-Series."
  type        = string
}

variable "outbound_storage_share_name" {
  description = "Name of storage share to be created that holds `files` for bootstrapping outbound VM-Series."
  type        = string
}

variable "vmseries_count" {
  description = "Total number of VM series to deploy per direction (inbound/outbound)."
  default     = 1
}

variable "virtual_network_name" {
  description = "Name of the Virtual Network to create."
  type        = string
}

variable "address_space" {
  description = "The address space used by the virtual network. You can supply more than one address space."
  type        = list(string)
}

variable "network_security_groups" {
  description = "Map of Network Security Groups to create. Refer to the `vnet` module documentation for more information."
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
  description = "Map of Route Tables to create. Refer to the `vnet` module documentation for more information."
}

variable "subnets" {
  description = "Map of Subnets to create. Refer to the `vnet` module documentation for more information."
}

variable "vnet_tags" {
  description = "Map of tags to assign to the created virtual network and other network-related resources. By default equals to `inbound_vmseries_tags`."
  type        = map(string)
  default     = {}
}

variable "lb_public_name" {
  description = "Name of the public-facing load balancer."
  type        = string
  default     = "lb_public"
}

variable "lb_private_name" {
  description = "Name of the private load balancer."
  type        = string
  default     = "lb_private"
}

variable "olb_private_ip" {
  description = "The private IP address to assign to the outbound load balancer. This IP **must** fall in the `private_subnet` network."
  default     = "10.110.0.21"
}

variable "public_frontend_ips" {
  description = "Map of objects describing frontend IP configurations and rules for the inbound load balancer. Refer to the `loadbalancer` module documentation for more information."
}

variable "private_frontend_ips" {
  description = "Map of objects describing frontend IP configurations and rules for the private load balancer. Refer to the `loadbalancer` module documentation for more information."
}

variable "common_vmseries_sku" {
  description = "VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "bundle2"
  type        = string
}

variable "inbound_vmseries_version" {
  description = "Inbound VM-series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "10.0.4"
  type        = string
}

variable "inbound_vmseries_vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported."
  default     = "Standard_D3_v2"
  type        = string
}

variable "inbound_vmseries_tags" {
  description = "Map of tags to be associated with the inbound virtual machines, their interfaces and public IP addresses."
  default     = {}
  type        = map(string)
}

variable "outbound_vmseries_version" {
  description = "Outbound VM-series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "10.0.4"
  type        = string
}

variable "outbound_vmseries_vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported."
  default     = "Standard_D3_v2"
  type        = string
}

variable "outbound_vmseries_tags" {
  description = "Map of tags to be associated with the outbound virtual machines, their interfaces and public IP addresses."
  default     = {}
  type        = map(string)
}

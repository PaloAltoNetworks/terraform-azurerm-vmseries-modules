#----------------------#
#   Global Variables   #
#----------------------#
variable "location" {
  description = "The Azure region to use."
  default     = "Australia Central"
  type        = string
}

variable "create_resource_group_name" {
  description = "Name for a created resource group. The input is ignored if `existing_resource_group_name` is set. If null, uses an auto-generated name."
  default     = null
  type        = string
}

variable "existing_resource_group_name" {
  description = "Name for an existing resource group to use. If null, use instead `create_resource_group_name`."
  default     = null
  type        = string
}

variable "name_prefix" {
  description = "A prefix for all names in this module."
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

variable "instances" {
  description = <<-EOF
  Map of virtual machine instances to create for VM-Series. Keys are the individual hostnames, values
  are the per-vm objects containing the attributes unique to specific virtual machines:

  - `mgmt_public_ip_address_id`: the Public IP identifier to assign to the nic0 interface (the management interface which listens on ssh/https).
  - `nic1_public_ip_address_id`: the Public IP identifier to assign to the first data interface (nic1). Assigning to remaining data interfaces is unsupported.
  - `zone`: the Azure Availability Zone identifier ("1", "2", "3"). If unspecified, the Availability Set is created instead.

  Basic:
  ```
  {
    "fw00" = {
      mgmt_public_ip_address_id = azurerm_public_ip.this.id
    }
    "fw01" = { 
      mgmt_public_ip_address_id = azurerm_public_ip.that.id
    }
  }
  ```

  Full example:
  ```
  {
    "fw00" = {
      mgmt_public_ip_address_id = azurerm_public_ip.m0.id
      nic1_public_ip_address_id = azurerm_public_ip.d0.id
      zone                      = "1"
    }
    "fw01" = { 
      mgmt_public_ip_address_id = azurerm_public_ip.m1.id
      nic1_public_ip_address_id = azurerm_public_ip.d1.id
      zone                      = "2"
    }
  }
  ```
  EOF
  default = {
    "fw00" = {}
  }
}

#----------------------#
#      Networking      #
#----------------------#
variable "management_ips" {
  description = "A map where the keys are the IP addresses or ranges that are permitted to access the out-of-band management interfaces belonging to firewalls and Panorama devices. The map's values are priorities, integers in the range 102-60000 inclusive. All priorities should be unique."
  type        = map(number)
}

# Subnet definitions
#  All subnet defs are joined with their vnet prefix to form a full CIDR prefix
#  ex. for management, ${management_vnet_prefix}${management_subnet}
#  Thus to change the VNET addressing you only need to update the relevent _vnet_prefix variable.

variable "management_vnet_prefix" {
  default     = "10.255."
  description = "The private prefix used for the management virtual network"
}

variable "management_subnet" {
  default     = "0.0/24"
  description = "The private network that terminates all FW and Panorama IP addresses."
}

variable "firewall_vnet_prefix" {
  default     = "10.110."
  description = "The private prefix used for all firewall networks"
}

variable "vm_management_subnet" {
  default     = "255.0/24"
  description = "The subnet used for the management NICs on the vm-series"
}

variable "public_subnet" {
  default     = "129.0/24"
  description = "The private network that is the external or public side of the VM series firewalls (eth1/1)"
}

variable "private_subnet" {
  default     = "0.0/24"
  description = "The private network behind or on the internal side of the VM series firewalls (eth1/2)"
}

variable "olb_private_ip" {
  # !! This IP MUST fall in the private-subnet network. !!
  description = "The private IP address to assign to the Outgoing Load balancer frontend"
  default     = "10.110.0.21"
}

variable "frontend_ips" {
  description = "A map of objects describing LB Frontend IP configurations and rules. See the module's documentation for details."
}

#----------------------#
#      VM Options      #
#----------------------#

variable "panorama_sku" {
  description = "Panorama SKU."
  default     = "byol"
  type        = string
}

variable "panorama_version" {
  description = "Panorama PAN-OS Software version. List published images with `az vm image list -o table --all --publisher paloaltonetworks --offer panorama`"
  default     = "9.0.5"
  type        = string
}

variable "vm_series_sku" {
  description = "VM-series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "bundle2"
  type        = string
}

variable "vm_series_version" {
  description = "VM-series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "9.0.4"
  type        = string
}

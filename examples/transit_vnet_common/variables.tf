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
  A map defining VNETs. A key is the VNET name, value is a set of properties describing a VNET.
  
  - `create_virtual_network` : (default: `true`) when set to `true` will create a VNET, `false` will source an existing VNET (in this case the name should already contain a prefix).
  - `resource_group_name` :  (default: current RG) a name of a Resource Group in which the VNET will reside or will be sourced from.
  - `create_subnets` : (default: `true`) if true, create the Subnets inside the Virtual Network, otherwise use pre-existing subnets. Subnet names are not pre-fixable.
  - `address_space` : a list of CIDRs for VNET.
  - `subnets` : map of Subnets to create or source subnets
  - `network_security_groups` : map of Network Security Groups to create
  - `route_tables` : map of Route Tables to create.

  For details on configuring the last three properties refer to [VNET module documentation](../../modules/vnet/README.md).
  EOF
  type        = any
}

variable "natgws" {
  description = <<-EOF
  A map defining NAT Gateways, where key is the NatGW name and value is a set of properties described below.

  - `create_natgw` : (default: `true`) when set to `true` will create a NatGW, `false` will source an existing one (in this case the name should already contain a prefix).
  - `vnet_name` : a name of a VNET that will host this resource, this a key from the `var.vnets` map.
  - `subnet_name` : a name of a Subnet that NatGW will be assigned to, this is a key from the `subnets` property from a VNET definition described by the `vnet_name` property.
  - `zone` : Availability Zone is a zonal resource, provide a zone in which this resource will be created, when omitted, zone is set by AzureRM.

  Properties below are only briefly documented, for details, default values, limitation refer to [modules documentation](../../modules/natgw):

  - `idle_timeout` : session timeout for idle connections.
  - `create_pip` : (default: `true`) create a Public IP to be used by NatGW.
  - `existing_pip_name` : for `create_pip` set to `false`, a name of an exiting Public IP resource.
  - `existing_pip_resource_group_name` : for `create_pip` set to `false`, a name of a Resource Group hosting the existing Public IP.
  - `create_pip_prefix` : (default: `true`) create a Public IP Prefix to be used by NatGW
  - `pip_prefix_length` : when creating a prefix resource, this is a netmask (IPv4) setting the amount of IP addresses available in the prefix.
  - `existing_pip_prefix_name` : for `create_pip_prefix` set to `false`, a name of an existing prefix resource
  - `existing_pip_prefix_resource_group_name` : for `create_pip_prefix` set to `false`, a name of a Resource Group hosting the existing prefix.
  EOF
  default     = {}
  type        = any
}




### Load Balancing
variable "load_balancers" {
  description = <<-EOF
  A map containing configuration for all (private and public) Load Balancer that will be created in this deployment.

  Key is the name of the Load Balancer as it will be available in Azure. This name is also used to reference the Load Balancer further in the code.
  Value is an object containing following properties:

  - `vnet_name` : (both) a name of a VNET that will host this resource, this a key from the `var.vnets` map
  - `network_security_group_name`: (public LB) a name of a security group created with the `vnet_security` module, an ingress rule will be created in that NSG for each listener. 
  - `network_security_allow_source_ips`: (public LB) a list of IP addresses that will used in the ingress rules.
  - `avzones` : (public LB) a list of Availability Zones in which the Public IP will be available
  - `frontend_ips`: (both) a map configuring both a listener and a load balancing rule, key is the name that will be used as an application name inside LB config as well as to create a rule in NSG (for public LBs), value is an object with the following properties:
    - `create_public_ip`: (public LB) defaults to `false`, when set to `true` a Public IP will be created and associated with a listener
    - `public_ip_name`: (public LB) defaults to `null`, when `create_public_ip` is set to `false` this property is used to reference an existing Public IP object in Azure
    - `public_ip_resource_group`: (public LB) defaults to `null`, when using an existing Public IP created in a different Resource Group than the currently used use this property is to provide the name of that RG
    - `private_ip_address`: (private LB) defaults to `null`, specify a static IP address that will be used by a listener
    - `subnet_name`: (private LB) defaults to `null`, when `private_ip_address` is set specifies a subnet to which the LB will be attached, in case of VMSeries this should be a internal/trust subnet
    - `zones` - defaults to `null`, specify in which zones you want to create frontend IP address. Pass list with zone coverage, ie: `["1","2","3"]`
    - `rules` - a map configuring the actual rules load balancing rules, a key is a rule name, a value is an object with the following properties:
      - `protocol`: protocol used by the rule, can be one the following: `TCP`, `UDP` or `All` when creating an HA PORTS rule
      - `port`: port used by the rule, for HA PORTS rule set this to `0`
  EOF
  default     = {}
  type        = any
}



### GENERIC VMSERIES
variable "vmseries_version" {
  description = "VM-Series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  type        = string
}

variable "vmseries_vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported."
  type        = string
}

variable "vmseries_sku" {
  description = "VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "byol"
  type        = string
}

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

variable "availability_set" {
  description = <<-EOF
  A map defining availability sets. Can be used to provide infrastructure high availability when zones cannot be used.

  Key is the AS name, value can contain following properties:
  - `update_domain_count` - specifies the number of update domains that are used, defaults to 5 (Azure defaults)
  - `fault_domain_count` - specifies the number of fault domains that are used, defaults to 3 (Azure defaults)
  EOF
  default     = {}
  type        = any
}

variable "vmseries" {
  description = <<-EOF
  Map of virtual machines to create to run VM-Series - inbound firewalls. Keys are the individual names, values
  are objects containing attributes unique to that individual virtual machine:

  - `vnet_name` : a name of a VNET that will host this resource, this a key from the `var.vnets` map.
  - `avzone` : the Azure Availability Zone identifier ("1", "2", "3"). Default is "1" in order to avoid non-HA deployments.
  - `availability_set_name` : a name of an Availability Set as declared in `availability_set` property. Specify when HA is required but cannot go for zonal deployment.
  - `bootstrap_options`: Bootstrap options to pass to VM-Series instances, semicolon separated values.
  - `add_to_appgw_backend` : bool, `false` by default, set this to `true` to add this backend to an Application Gateway.
  - `app_insights_settings` : a map defining Application Insights settings for this resource.

  - `interfaces`: configuration of all NICs assigned to a VM. A list containing properties for each interface. Order is important, as Azure assigns NICs to a VM in the order you provide them here. Therefore the 1st NIC should be the Management one:
    - `name` : a name of an interface
    - `subnet_name`: (string) a name of a subnet as created in using `vnet_security` module
    - `create_pip`: (boolean) flag to create Public IP for an interface, defaults to `false`
    - `load_balancer_name`: (string) name of a Load Balancer created with the `loadbalancer` module to which a VM should be assigned, defaults to `null`
    - `private_ip_address`: (string) a static IP address that should be assigned to an interface, defaults to `null` (in that case DHCP is used)
  EOF
  default     = {}
  type        = any
}
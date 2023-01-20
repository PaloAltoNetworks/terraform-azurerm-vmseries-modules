# GENERAL INFORMATION
variable "location" {
  description = "The Azure region to use."
  default     = "East US 2"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group to create. If not provided, it will be auto-generated."
  default     = "transit-vnet-common"
  type        = string
}

variable "name_prefix" {
  description = "A prefix for all the names of the created Azure objects. It can end with a dash `-` character, if your naming convention prefers such separator."
  default     = "example-"
  type        = string
}

variable "tags" {
  description = "Map of tags to assign to the created resources."
  default = {
    "CreatedBy"   = "Palo Alto Networks"
    "CreatedWith" = "Terraform"
  }
  type = map(string)
}

variable "enable_zones" {
  description = "If `true`, enable zone support for resources."
  default     = true
  type        = bool
}

# NETWORK
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
  default     = {}
  type        = any
}


variable "route_tables" {
  description = "Definition of Route Tables to create. Refer to the `vnet` module documentation for more information."
  default     = {}
  type        = any
}

variable "subnets" {
  description = "Definition of Subnets to create. Refer to the `vnet` module documentation for more information."
  type        = any
}


# LOAD BALANCING
variable "load_balancers" {
  description = <<-EOF
  A map containing configuration for all (private and public) Load Balancer that will be created in this deployment.

  Key is the name of the Load Balancer as it will be available in Azure. This name is also used to reference the Load Balancer further in the code.
  Value is an object containing following properties:

  - `network_security_group_name`: (public LB) a name of a security group created with the `vnet_security` module, an ingress rule will be created in that NSG for each listener. 
  - `network_security_allow_source_ips`: (public LB) a list of IP addresses that will used in the ingress rules.
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

  Example of a public Load Balancer:

  ```
  "public_https_app" = {
    network_security_group_name = "untrust_nsg"
    network_security_allow_source_ips = [ "1.2.3.4" ]
    frontend_ips = {
      "https_app_1" = {
        create_public_ip = true
        rules = {
          "balanceHttps" = {
            protocol = "Tcp"
            port     = 443
          }
        }
      }
    }
  }
  ```

  Example of a private Load Balancer with HA PORTS rule:

  ```
  "ha_ports" = {
    frontend_ips = {
      "ha-ports" = {
        subnet_name        = "trust_snet"
        private_ip_address = "10.0.0.1"
        rules = {
          HA_PORTS = {
            port     = 0
            protocol = "All"
          }
        }
      }
    }
  }
  ```

  EOF
}


# VMSERIES
variable "username" {
  description = "Initial administrative username to use for all systems."
  default     = "panadmin"
  type        = string
}

variable "password" {
  description = "Initial administrative password to use for all systems. Set to null for an auto-generated password."
  default     = null
  type        = string
  sensitive   = true
}

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
  type        = string
}

variable "vmseries" {
  description = <<-EOF
  Map of virtual machines to create to run VM-Series - inbound firewalls. Keys are the individual names, values
  are objects containing attributes unique to that individual virtual machine:

  - `avzone`: the Azure Availability Zone identifier ("1", "2", "3"). Default is "1" in order to avoid non-HA deployments.
  - `availability_set_name` : a name of an Availability Set as declared in `availability_set` property. Specify when HA is required but cannot go for zonal deployment.
  - `bootstrap_options`: Bootstrap options to pass to VM-Series instances, semicolon separated values.
  - `add_to_appgw_backend` : bool, `false` by default, set this to `true` to add this backend to an Application Gateway.

  - `interfaces`: a list containing configuration of all NICs assigned to a VM. Order is important as the interfaces are assigned to a VM in the order specified in this list. The management interface should be the first one. Following properties are available:
    - `name`: (string) a name of an interface
    - `subnet_name`: (string) a name of a subnet as created in using `vnet_security` module
    - `create_pip`: (boolean) flag to create Public IP for an interface, defaults to `false`
    - `backend_pool_lb_name`: (string) name of a Load Balancer created with the `loadbalancer` module to which a VM should be assigned, defaults to `null`
    - `private_ip_address`: (string) a static IP address that should be assigned to an interface, defaults to `null` (in that case DHCP is used)

  Example:
  ```
  {
    "fw00" = {
      bootstrap_options = "type=dhcp-client"
      avzone = 1
      interfaces = {
        mgmt = {
          subnet_name        = "mgmt"
          create_pip         = true
          private_ip_address = "10.0.0.1"
        }
        trust = {
          subnet_name          = "trust"
          private_ip_address   = "10.0.1.1"
          backend_pool_lb_name = "private_lb"
        }
      }
    }
  }
  ```
  EOF
}
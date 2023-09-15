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

  - `name` :  A name of a VNET.
  - `create_virtual_network` : (default: `true`) when set to `true` will create a VNET, `false` will source an existing VNET, in both cases the name of the VNET is specified with `name`
  - `address_space` : a list of CIDRs for VNET
  - `resource_group_name` :  (default: current RG) a name of a Resource Group in which the VNET will reside

  - `create_subnets` : (default: `true`) if true, create the Subnets inside the Virtual Network, otherwise use pre-existing subnets
  - `subnets` : map of Subnets to create

  - `network_security_groups` : map of Network Security Groups to create
  - `route_tables` : map of Route Tables to create.
  EOF
}

variable "natgws" {
  description = <<-EOF
  A map defining Nat Gateways. 

  Please note that a NatGW is a zonal resource, this means it's always placed in a zone (even when you do not specify one explicitly). Please refer to Microsoft documentation for notes on NatGW's zonal resiliency. 

  Following properties are supported:

  - `name` : a name of the newly created NatGW.
  - `create_natgw` : (default: `true`) create or source (when `false`) an existing NatGW. Created or sourced: the NatGW will be assigned to a subnet created by the `vnet` module.
  - `resource_group_name : name of a Resource Group hosting the NatGW (newly create or the existing one).
  - `zone` : Availability Zone in which the NatGW will be placed, when skipped AzureRM will pick a zone.
  - `idle_timeout` : connection IDLE timeout in minutes, for newly created resources
  - `vnet_key` : a name (key value) of a VNET defined in `var.vnets` that hosts a subnet this NatGW will be assigned to.
  - `subnet_keys` : a list of subnets (key values) the NatGW will be assigned to, defined in `var.vnets` for a VNET described by `vnet_name`.
  - `create_pip` : (default: `true`) create a Public IP that will be attached to a NatGW
  - `existing_pip_name` : when `create_pip` is set to `false`, source and attach and existing Public IP to the NatGW
  - `existing_pip_resource_group_name` : when `create_pip` is set to `false`, name of the Resource Group hosting the existing Public IP
  - `create_pip_prefix` : (default: `false`) create a Public IP Prefix that will be attached to the NatGW.
  - `pip_prefix_length` : length of the newly created Public IP Prefix, can bet between 0 and 31 but this actually supported value depends on the Subscription.
  - `existing_pip_prefix_name` : when `create_pip_prefix` is set to `false`, source and attach and existing Public IP Prefix to the NatGW
  - `existing_pip_prefix_resource_group_name` : when `create_pip_prefix` is set to `false`, name of the Resource Group hosting the existing Public IP Prefix.

  Example:
  ```
  natgws = {
    "natgw" = {
      name         = "public-natgw"
      vnet_key     = "transit-vnet"
      subnet_keys  = ["public"]
      zone         = 1
    }
  }
  ```
  EOF
  default     = {}
  type        = any
}



### Load Balancing
variable "load_balancers" {
  description = <<-EOF
  A map containing configuration for all (private and public) Load Balancer that will be created in this deployment.

  Following properties are available (for details refer to module's documentation):

  - `name`: name of the Load Balancer resource.
  - `nsg_vnet_key`: (public LB) defaults to `null`, a key describing a vnet (as defined in `vnet` variable) that hold an NSG we will update with an ingress rule for each listener.
  - `nsg_key`: (public LB) defaults to `null`, a key describing an NSG (as defined in `vnet` variable, under `nsg_vnet_key`) we will update with an ingress rule for each listener.
  - `network_security_group_name`: (public LB) defaults to `null`, in case of a brownfield deployment (no possibility to depend on `vnet` variable), a name of a security group, an ingress rule will be created in that NSG for each listener. **NOTE** this is the FULL NAME of the NSG (including prefixes).
  - `network_security_group_rg_name`: (public LB) defaults to `null`, in case of a brownfield deployment (no possibility to depend on `vnet` variable), a name of a resource group for the security group, to be used when the NSG is hosted in a different RG than the one described in `var.resource_group_name`.
  - `network_security_allow_source_ips`: (public LB) a list of IP addresses that will used in the ingress rules.
  - `avzones`: (both) for regional Load Balancers, a list of supported zones (this has different meaning for public and private LBs - please refer to module's documentation for details).
  - `frontend_ips`: (both) a map configuring both a listener and a load balancing rule, key is the name that will be used as an application name inside LB config as well as to create a rule in NSG (for public LBs), value is an object with the following properties:
    - `create_public_ip`: (public LB) defaults to `false`, when set to `true` a Public IP will be created and associated with a listener
    - `public_ip_name`: (public LB) defaults to `null`, when `create_public_ip` is set to `false` this property is used to reference an existing Public IP object in Azure
    - `public_ip_resource_group`: (public LB) defaults to `null`, when using an existing Public IP created in a different Resource Group than the currently used use this property is to provide the name of that RG
    - `private_ip_address`: (private LB) defaults to `null`, specify a static IP address that will be used by a listener
    - `vnet_key`: (private LB) defaults to `null`, when `private_ip_address` is set specifies a vnet's key (as defined in `vnet` variable). This will be the VNET hosting this Load Balancer
    - `subnet_key`: (private LB) defaults to `null`, when `private_ip_address` is set specifies a subnet's key (as defined in `vnet` variable) to which the LB will be attached, in case of VMSeries this should be a internal/trust subnet
    - `rules` - a map configuring the actual rules load balancing rules, a key is a rule name, a value is an object with the following properties:
      - `protocol`: protocol used by the rule, can be one the following: `TCP`, `UDP` or `All` when creating an HA PORTS rule
      - `port`: port used by the rule, for HA PORTS rule set this to `0`

  Example of a public Load Balancer:

  ```
  "public_lb" = {
    name                              = "https_app_lb"
    network_security_group_name       = "untrust_nsg"
    network_security_allow_source_ips = ["1.2.3.4"]
    avzones                           = ["1", "2", "3"]
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
  "private_lb" = {
    name = "ha_ports_internal_lb
    frontend_ips = {
      "ha-ports" = {
        vnet_key           = "trust_vnet"
        subnet_key         = "trust_snet"
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
  default     = {}
}



### GENERIC VMSERIES
variable "vmseries_version" {
  description = "VM-Series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks`. It's also possible to specify the Pan-OS version per firewall, see `var.vmseries` variable."
  type        = string
}

variable "vmseries_vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported. It's also possible to specify the the VM size per firewall, see `var.vmseries` variable."
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

variable "availability_sets" {
  description = <<-EOF
  A map defining availability sets. Can be used to provide infrastructure high availability when zones cannot be used.

  Following properties are supported:
  - `name` - name of the Application Insights.
  - `update_domain_count` - specifies the number of update domains that are used, defaults to 5 (Azure defaults).
  - `fault_domain_count` - specifies the number of fault domains that are used, defaults to 3 (Azure defaults).

  Please keep in mind that Azure defaults are not working for each region (especially the small ones, w/o any Availability Zones). Please verify how many update and fault domain are supported in a region before deploying this resource.
  EOF
  default     = {}
  type        = any
}

variable "application_insights" {
  description = <<-EOF
  A map defining Azure Application Insights. There are three ways to use this variable:

  * when the value is set to `null` (default) no AI is created
  * when the value is a map containing `name` key (other keys are optional) a single AI instance will be created under the name that is the value of the `name` key
  * when the value is an empty map or a map w/o the `name` key, an AI instance per each VMSeries VM will be created. All instances will share the same configuration. All instances will have names corresponding to their VM name.

  Names for all AI instances are prefixed with `var.name_prefix`.

  Properties supported (for details on each property see [modules documentation](../../modules/application_insights/README.md)):

  - `name` : (optional, string) a name of a single AI instance
  - `workspace_mode` : (optional, bool) defaults to `true`, use AI Workspace mode instead of the Classical (deprecated)
  - `workspace_name` : (optional, string) defaults to AI name suffixed with `-wrkspc`, name of the Log Analytics Workspace created when AI is deployed in Workspace mode
  - `workspace_sku` : (optional, string) defaults to PerGB2018, SKU used by WAL, see module documentation for details
  - `metrics_retention_in_days` : (optional, number) defaults to current Azure default value, see module documentation for details

  Example of an AIs created per VM, in Workspace mode, with metrics retention set to 1 year:
  ```
  vmseries = {
    'vm-1' = {
      ....
    }
    'vm-2' = {
      ....
    }
  }

  application_insights = {
    metrics_retention_in_days = 365
  }
  ```
  EOF
  default     = null
  type        = map(string)
}

variable "bootstrap_storage" {
  description = <<-EOF
  A map defining Azure Storage Accounts used to host file shares for bootstrapping NGFWs. This variable defines only Storage Accounts, file shares are defined per each VM. See `vmseries` variable, `bootstrap_storage` property.

  Following properties are supported (except for name, all are optional):

  - `name` : name of the Storage Account. Please keep in mind that storage account name has to be globally unique. This name will not be prefixed with the value of `var.name_prefix`.
  - `create_storage_account` : (defaults to `true`) create or source (when `false`) an existing Storage Account.
  - `resource_group_name` : (defaults to `var.resource_group_name`) name of the Resource Group hosting the Storage Account (existing or newly created). The RG has to exist.
  - `storage_acl` : (defaults to `false`) enables network ACLs on the Storage Account. If this is enabled - `storage_allow_vnet_subnets` and `storage_allow_inbound_public_ips` options become available. The ACL defaults to default `Deny`.
  - `storage_allow_vnet_subnets` : (defaults to `[]`) whitelist containing the allowed vnet and associated subnets that are allowed to access the Storage Account. Note that the respective subnets require `enable_storage_service_endpoint` set to `true` to work properly.
  - `storage_allow_inbound_public_ips` : (defaults to `[]`) whitelist containing the allowed public IP subnets that can access the Storage Account. Note that the code automatically tries to query https://ifconfig.me/ip to obtain the public IP address of the machine executing the code so that the bootstrap files can be successfully uploaded to the Storage Account.

  The properties below do not directly change anything in the Storage Account settings. They can be used to control common parts of the `DAY0` configuration (used only when full bootstrap is used). These properties can also be specified per firewall, but when specified here they tak higher precedence:
  - `public_snet_key` : required, name of the key in `var.vnets` map defining a public subnet, required to calculate the Azure router IP for the public subnet.
  - `private_snet_key` : required, name of the key in `var.vnets` map defining a private subnet, required to calculate the Azure router IP for the private subnet.
  - `intranet_cidr` : optional, CIDR of the private networks required to build a general static route to resources protected by this firewall, when skipped the 1st CIDR from `vnet_name` address space will be used.
  - `ai_update_interval` : if Application Insights are used this property can override the default metrics update interval (in minutes).

  EOF
  default     = {}
  type        = any
}

variable "vmseries" {
  description = <<-EOF
  Map of virtual machines to create to run VM-Series - inbound firewalls. Following properties are supported:

  - `name` : name of the VMSeries virtual machine.
  - `vm_size` : size of the VMSeries virtual machine, when specified overrides `var.vmseries_vm_size`.
  - `version` : PanOS version, when specified overrides `var.vmseries_version`.
  - `vnet_key` : a key of a VNET defined in the `var.vnets` map. This value will be used during network interfaces creation.
  - `add_to_appgw_backend` : bool, `false` by default, set this to `true` to add this backend to an Application Gateway.
  - `avzone`: the Azure Availability Zone identifier ("1", "2", "3"). Default is "1".
  - `availability_set_key` : a key of an Availability Set as declared in `availability_sets` property. Specify when HA is required but cannot go for zonal deployment.

  - `bootstrap_options` : string, optional bootstrap options to pass to VM-Series instances, semicolon separated values. When defined this precedence over `bootstrap_storage`
  - `bootstrap_storage` : a map containing definition of the bootstrap package content. When present triggers a creation of a File Share in an existing Storage Account, following properties supported:
    - `name` : a name of a key in `var.bootstrap_storage` variable defining a Storage Account
    - `static_files` : a map where key is a path to a file, value is the location of the file in the bootstrap package (file share). All files in this map are copied 1:1 to the bootstrap package
    - `template_bootstrap_xml` : path to the `bootstrap.xml` template. When defined it will trigger creation of the `bootstrap.xml` file and the file will be uploaded to the storage account. This is a simple `day 0` configuration file that should set up only basic networking. Specifying this property forces additional properties that are required to properly template the file. They can be defined per each VM or globally for all VMs (in this case place them in the bootstrap storage definition). The properties are listed below.
    - `public_snet_key` : required, name of the key in `var.vnets` map defining a public subnet, required to calculate the Azure router IP for the public subnet.
    - `private_snet_key` : required, name of the key in `var.vnets` map defining a private subnet, required to calculate the Azure router IP for the private subnet.
    - `intranet_cidr` : optional, CIDR of the private networks required to build a general static route to resources protected by this firewall, when skipped the 1st CIDR from `vnet_name` address space will be used.
    - `ai_update_interval` : if Application Insights are used this property can override the default metrics update interval (in minutes).

  - `interfaces` : configuration of all NICs assigned to a VM. A list of maps, each map is a NIC definition. Notice that the order DOES matter. NICs are attached to VMs in Azure in the order they are defined in this list, therefore the management interface has to be defined first. Following properties are available:
    - `name`: string that will form the NIC name
    - `subnet_key` : (string) a key of a subnet as defined in `var.vnets`
    - `create_pip` : (boolean) flag to create Public IP for an interface, defaults to `false`
    - `public_ip_name` : (string) when `create_pip` is set to `false` a name of a Public IP resource that should be associated with this Network Interface
    - `public_ip_resource_group` : (string) when associating an existing Public IP resource, name of the Resource Group the IP is placed in, defaults to the `var.resource_group_name`
    - `load_balancer_key` : (string) key of a Load Balancer defined in the `var.loadbalancers`  variable, defaults to `null`
    - `private_ip_address` : (string) a static IP address that should be assigned to an interface, defaults to `null` (in that case DHCP is used)

  Example:
  ```
  {
    "fw01" = {
      name = "firewall01"
      bootstrap_storage = {
        name                   = "storageaccountname"
        static_files           = { "files/init-cfg.txt" = "config/init-cfg.txt" }
        template_bootstrap_xml = "templates/bootstrap_common.tmpl"
        public_snet_key        = "public"
        private_snet_key       = "private"
      }
      avzone   = 1
      vnet_key = "trust"
      interfaces = [
        {
          name               = "mgmt"
          subnet_key         = "mgmt"
          create_pip         = true
          private_ip_address = "10.0.0.1"
        },
        {
          name                 = "trust"
          subnet_key           = "private"
          private_ip_address   = "10.0.1.1"
          load_balancer_key    = "private_lb"
        },
        {
          name                 = "untrust"
          subnet_key           = "public"
          private_ip_address   = "10.0.2.1"
          load_balancer_key    = "public_lb"
          public_ip_name       = "existing_public_ip"
        }
      ]
    }
  }
  ```
  EOF
}

# Application Gateway
variable "appgws" {
  description = <<-EOF
  A map defining all Application Gateways in the current deployment.

  For detailed documentation on how to configure this resource, for available properties, especially for the defaults and the `rules` property refer to [module documentation](../../modules/appgw/README.md).

  Following properties are supported:
  - `name` : name of the Application Gateway.
  - `vnet_key` : a key of a VNET defined in the `var.vnets` map.
  - `subnet_key` : a key of a subnet as defined in `var.vnets`. This has to be a subnet dedicated to Application Gateways v2.
  - `zones` : for zonal deployment this is a list of all zones in a region - this property is used by both: the Application Gateway and the Public IP created in front of the AppGW.
  - `capacity` : (optional) number of Application Gateway instances, not used when autoscalling is enabled (see `capacity_min`)
  - `capacity_min` : (optional) when set enables autoscaling and becomes the minimum capacity
  - `capacity_max` : (optional) maximum capacity for autoscaling
  - `enable_http2` : enable HTTP2 support on the Application Gateway
  - `waf_enabled` : (optional) enables WAF Application Gateway, defining WAF rules is not supported, defaults to `false`
  - `vmseries_public_nic_name` : name of the public VMSeries interface as defined in `interfaces` property.
  - `managed_identities` : (optional) a list of existing User-Assigned Managed Identities, which Application Gateway uses to retrieve certificates from Key Vault
  - `ssl_policy_type` : (optional) type of an SSL policy, defaults to `Predefined`
  - `ssl_policy_name` : (optional) name of an SSL policy, for `ssl_policy_type` set to `Predefined`
  - `ssl_policy_min_protocol_version` : (optional) minimum version of the TLS protocol for SSL Policy, for `ssl_policy_type` set to `Custom`
  - `ssl_policy_cipher_suites` : (optional) a list of accepted cipher suites, for `ssl_policy_type` set to `Custom`
  - `ssl_profiles` : (optional) a map of SSL profiles that can be later on referenced in HTTPS listeners by providing a name of the profile in the `ssl_profile_name` property

  EOF
  default     = {}
}

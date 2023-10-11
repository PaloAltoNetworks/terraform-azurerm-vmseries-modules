# Common
variable "name_prefix" {
  description = "Prefix for resource names."
  default     = ""
  type        = string
}

variable "location" {
  description = "Location where the resources will be deployed."
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
  description = "Name of the Resource Group to create or use."
  type        = string
}

variable "enable_zones" {
  description = "If `true`, enable zone support for resources."
  default     = true
  type        = bool
}

variable "tags" {
  description = "Map of tags to assign to all of the created resources."
  default     = {}
  type        = map(string)
}

# VNets
variable "vnets" {
  description = <<-EOF
  A map defining VNETs.
  
  For detailed documentation on each property refer to [module documentation](../../modules/vnet/README.md)

  - `create_virtual_network`  - (`bool`, optional, defaults to `true`) when set to `true` will create a VNET, `false` will source an existing VNET.
  - `name`                    - (`string`, required) a name of a VNET. In case `create_virtual_network = false` this should be a full resource name, including prefixes.
  - `address_space`           - (`list(string)`, required when `create_virtual_network = false`) a list of CIDRs for a newly created VNET
  - `resource_group_name`     - (`string`, optional, defaults to current RG) a name of an existing Resource Group in which the VNET will reside or is sourced from

  - `create_subnets`          - (`bool`, optinoal, defaults to `true`) if `true`, create Subnets inside the Virtual Network, otherwise use source existing subnets
  - `subnets`                 - (`map`, optional) map of Subnets to create or source, for details see [VNET module documentation](../../modules/vnet/README.md#subnets)

  - `network_security_groups` - (`map`, optional) map of Network Security Groups to create, for details see [VNET module documentation](../../modules/vnet/README.md#network_security_groups)
  - `route_tables`            - (`map`, optional) map of Route Tables to create, for details see [VNET module documentation](../../modules/vnet/README.md#route_tables)
  EOF

  type = map(object({
    name                   = string
    create_virtual_network = optional(bool, true)
    address_space          = optional(list(string))
    resource_group_name    = optional(string)
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
        name                   = string
        address_prefix         = string
        next_hop_type          = string
        next_hop_in_ip_address = optional(string)
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

# GWLB
variable "gateway_load_balancers" {
  description = <<-EOF
  Map with Gateway Load Balancer definitions. Following settings are supported:
  - `name`                - (required|string) Gateway Load Balancer name.
  - `vnet_key`            - (required|string) Key of a VNet from `var.vnets` that contains target Subnet for LB's frontned. Used to get Subnet ID in combination with `subnet_key` below.
  - `subnet_key`          - (required|string) Key of a Subnet from `var.vnets[vnet_key]`.
  - `frontend_ip_config`  - (optional|map) Remaining Frontned IP configuration.
  - `resource_group_name` - (optional|string) LB's Resource Group, by default the one specified by `var.resource_group_name`.
  - `backends`            - (optional|map) LB's backend configurations.
  - `heatlh_probe`        - (optional|map) Health probe configuration.

  Please consult [module documentation](../../modules/gwlb/README.md) for details.
  EOF
  default     = {}
  type        = any
}

# VM-Series
variable "application_insights" {
  description = <<-EOF
  A map defining Azure Application Insights. There are three ways to use this variable:

  * when the value is set to `null` (default) no AI is created
  * when the value is a map containing `name` key (other keys are optional) a single AI instance will be created under the name that is the value of the `name` key
  * when the value is an empty map or a map w/o the `name` key, an AI instance per each VMSeries VM will be created. All instances will share the same configuration. All instances will have names corresponding to their VM name.

  Names for all AI instances are prefixed with `var.name_prefix`.

  Properties supported (for details on each property see [module documentation](../modules/application_insights/README.md)):

  - `name`                      - (optional|string) Name of a single AI instance
  - `workspace_mode`            - (optional|bool) Use AI Workspace mode instead of the Classical (deprecated), defaults to `true`.
  - `workspace_name`            - (optional|string) Name of the Log Analytics Workspace created when AI is deployed in Workspace mode, defaults to AI name suffixed with `-wrkspc`.
  - `workspace_sku`             - (optional|string) SKU used by WAL, see module documentation for details, defaults to PerGB2018.
  - `metrics_retention_in_days` - (optional|number) Defaults to current Azure default value, see module documentation for details.

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

variable "bootstrap_storages" {
  description = <<-EOF
  A map defining Azure Storage Accounts used to host file shares for bootstrapping NGFWs. This variable defines only Storage Accounts, file shares are defined per each VM. See `vmseries` variable, `bootstrap_storage` property.
  Following properties are supported:
  - `name`                             - (required|string) Name of the Storage Account. Please keep in mind that storage account name has to be globally unique. This name will not be prefixed with the value of `var.name_prefix`.
  - `create_storage_account`           - (optional|bool) Whether to create or source an existing Storage Account, defaults to `true`.
  - `resource_group_name`              - (optional|string) Name of the Resource Group hosting the Storage Account, defaults to `var.resource_group_name`.
  - `storage_acl`                      - (optional|bool) Allows to enable network ACLs on the Storage Account. If set to `true`,  `storage_allow_vnet_subnets` and `storage_allow_inbound_public_ips` options become available. Defaults to `false`.
  - `storage_allow_vnet_subnets`       - (optional|map) Map with objects that contains `vnet_key`/`subnet_key` used to identify subnets allowed to access the Storage Account. Note that `enable_storage_service_endpoint` has to be set to `true` in the corresponding subnet configuration.
  - `storage_allow_inbound_public_ips` - (optional|list) Whitelist that contains public IPs/ranges allowed to access the Storage Account. Note that the code automatically to queries https://ifcondif.me to obtain the public IP address of the machine executing the code to enable bootstrap files upload.
  EOF
  default     = {}
  type        = any
}

variable "vmseries_common" {
  description = <<-EOF
  Configuration common for all firewall instances. Following settings can be specified:
  - `username`           - (required|string)
  - `password`           - (optional|string)
  - `ssh_keys`           - (optional|string)
  - `img_version`        - (optional|string)
  - `img_sku`            - (optional|string)
  - `vm_size`            - (optional|string)
  - `bootstrap_options`  - (optional|string)
  - `vnet_key`           - (optional|string)
  - `interfaces`         - (optional|list(object))
  - `ai_update_interval` - (optional|number)

  All are used directly as inputs for `vmseries` module (please see [documentation](../../modules/vmseries/README.md) for details), except for the last three:
  - `vnet_key`           - (required|string) Used to identify VNet in which subnets for interfaces exist.
  - `ai_update_interval` - (optional|number) If Application Insights are used this property can override the default metrics update interval (in minutes).
  EOF
  type        = any
}

variable "vmseries" {
  description = <<-EOF
  Map with VM-Series instance specific configuration. Following properties are supported:
  - `name`                 - (required|string) Instance name.
  - `avzone`               - (optional|string) AZ to deploy instance in, defaults to "1".
  - `availability_set_key` - (optional|string) Key from `var.availability_sets`, used to determine Availabbility Set ID.
  - `bootstrap_storage`    - (optional|map) Map that contains bootstrap package contents definition, when present triggers creation of a File Share in an existing Storage Account. Following properties supported:
    - `key`                    - (required|string) Identifies Storage Account to use from `var.bootstrap_storages`.
    - `static_files`           - (optional|map) Map where keys are local file paths, values determine destination in the bootstrap package (file share) where the file will be copied.
    - `template_bootstrap_xml` - (optional|string) Path to the `bootstrap.xml` template. When defined it will trigger creation of the `bootstrap.xml` file and it's upload to the boostrap package. This is a simple `day 0` configuration file that should set up only basic networking. Specifying this property forces additional properties that are required to properly template the file. They can be defined per each VM or globally for all VMs (in `var.vmseries_common`). The properties are listed below.
  - `interfaces`         - List of objects with interface definitions. Utilizes all properties of `interfaces` input (see [documantation](../../modules/vmseries/README.md#inputs)), expect for `subnet_id` and `lb_backend_pool_id`, which are determined based on the following new items:
    - `subnet_key`       - (optional|string) Key of a subnet from `var.vnets[vnet_key]` to associate interface with.
    - `gwlb_key`         - (optional|string) Key from `var.gwlbs` that identifies GWLB that will be associated with the interface, required when `enable_backend_pool` is `true`.
    - `gwlb_backend_key` - (optional|string) Key that identifies a backend from the GWLB selected by `gwlb_key` to associate th interface with, required when `enable_backend_pool` is `true`.

  Additionally, it's possible to override following settings from `var.vmseries_common`:
  - `bootstrap_options` - When defined, it not only takes precedence over `var.vmseries_common.bootstrap_options`, but also over `bootstrap_storage` described below.
  - `img_version`
  - `img_sku`
  - `vm_size`
  - `ai_update_interval`
  EOF
  type        = map(any)
}

variable "availability_sets" {
  description = <<-EOF
  A map defining availability sets. Can be used to provide infrastructure high availability when zones cannot be used.

  Following properties are supported:
  - `name`                - (required|string) Name of the Application Insights.
  - `update_domain_count` - (optional|int) Specifies the number of update domains that are used, defaults to 5 (Azure defaults).
  - `fault_domain_count`  - (optional|int) Specifies the number of fault domains that are used, defaults to 3 (Azure defaults).

  Please keep in mind that Azure defaults are not working for each region (especially the small ones, w/o any Availability Zones). Please verify how many update and fault domain are supported in a region before deploying this resource.
  EOF
  default     = {}
  type        = any
}

# Application
variable "load_balancers" {
  description = <<-EOF
  A map containing configuration for all (private and public) Load Balancer that will be created in this deployment.
  Following properties are available (for details refer to module's documentation):
  - `name`                              - (required|string) Name of the Load Balancer resource.
  - `network_security_group_name`       - (optional|string) Public LB only - name of a security group, an ingress rule will be created in that NSG for each listener. **NOTE** this is the FULL NAME of the NSG (including prefixes).
  - `network_security_group_rg_name`    - (optional|string) Public LB only - name of a resource group for the security group, to be used when the NSG is hosted in a different RG than the one described in `var.resource_group_name`.
  - `network_security_allow_source_ips` - (optional|string) Public LB only - list of IP addresses that will be allowed in the ingress rules.
  - `avzones`                           - (optional|list) For regional Load Balancers, a list of supported zones (this has different meaning for public and private LBs - please refer to module's documentation for details).
  - `frontend_ips`                      - (optional|map) Map configuring both a listener and load balancing/outbound rules, key is the name that will be used as an application name inside LB config as well as to create a rule in NSG (for public LBs), values are objects with the following properties:
    - `create_public_ip`         - (optional|bool) Public LB only - defaults to `false`, when set to `true` a Public IP will be created and associated with a listener
    - `public_ip_name`           - (optional|string) Public LB only - defaults to `null`, when `create_public_ip` is set to `false` this property is used to reference an existing Public IP object in Azure
    - `public_ip_resource_group` - (optional|string) Public LB only - defaults to `null`, when using an existing Public IP created in a different Resource Group than the currently used use this property is to provide the name of that RG
    - `private_ip_address`       - (optional|string) Private LB only - defaults to `null`, specify a static IP address that will be used by a listener
    - `vnet_key`                 - (optional|string) Private LB only - defaults to `null`, when `private_ip_address` is set specifies a vnet's key (as defined in `vnet` variable). This will be the VNET hosting this Load Balancer
    - `subnet_key`               - (optional|string) Private LB only - defaults to `null`, when `private_ip_address` is set specifies a subnet's key (as defined in `vnet` variable) to which the LB will be attached, in case of VMSeries this should be a internal/trust subnet
    - `in_rules`/`out_rules`     - (optional|map) Configuration of load balancing/outbound rules, please refer to [load_balancer module documentation](../../modules/loadbalancer/README.md#inputs) for details.

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
    name = "internal_app_lb"
    frontend_ips = {
      "ha-ports" = {
        vnet_key           = "internal_app_vnet"
        subnet_key         = "internal_app_snet"
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

variable "appvms_common" {
  description = <<-EOF
  Common settings for sample applications:
  - `username` - (required|string)
  - `password` - (optional|string)
  - `ssh_keys` - (optional|list(string)
  - `vm_size` - (optional|string)
  - `disk_type` - (optional|string)
  - `accelerated_networking` - (optional|bool)

  At least one of `password` or `ssh_keys` has to be provided.
  EOF
  type        = any
}

variable "appvms" {
  description = <<-EOF
  Configuration for sample application VMs. Available settings:
  - `name`              - (required|string) Instance name.
  - `avzone`            - (optional|string) AZ to deploy instance in, defaults to "1".
  - `vnet_key`          - (required|string) Used to identify VNet in which subnets for interfaces exist.
  - `subnet_key`        - (required|string) Key of a subnet from `var.vnets[vnet_key]` to associate interface with.
  - `load_balancer_key` - (optional|string) Key from `var.gwlbs` that identifies GWLB that will be associated with the interface, required when `enable_backend_pool` is `true`.
  EOF
  default     = {}
  type        = any
}

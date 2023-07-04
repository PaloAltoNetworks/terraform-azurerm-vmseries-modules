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
  
  For detailed documentation on each property refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/blob/v0.5.4/modules/vnet/README.md)

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
  - `network_security_group_name`: (public LB) a name of a security group, an ingress rule will be created in that NSG for each listener. **NOTE** this is the FULL NAME of the NSG (including prefixes).
  - `network_security_group_rg_name`: (public LB) a name of a resource group for the security group, to be used when the NSG is hosted in a different RG than the one described in `var.resource_group_name`.
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


variable "application_insights" {
  description = <<-EOF
  A map defining Azure Application Insights. There are three ways to use this variable:

  * when the value is set to `null` (default) no AI is created
  * when the value is a map containing `name` key (other keys are optional) a single AI instance will be created under the name that is the value of the `name` key
  * when the value is an empty map or a map w/o the `name` key, an AI instance per each VMSeries VM will be created. All instances will share the same configuration. All instances will have names corresponding to their VM name.

  Names for all AI instances are prefixed with `var.name_prefix`.

  Properties supported (for details on each property see [modules documentation](../modules/application_insights/README.md)):

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



### GENERIC VMSERIES
variable "vmseries_version" {
  description = "VM-Series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks`. It's also possible to specify the Pan-OS version per Scale Set, see `var.vmss` variable."
  type        = string
}

variable "vmseries_vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported. It's also possible to specify the the VM size per Scale Set, see `var.vmss` variable."
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

variable "vmss" {
  description = <<-EOF
  A map defining all Virtual Machine Scale Sets.

  For detailed documentation on how to configure this resource, for available properties, especially for the defaults refer to [module documentation](../../modules/vmss/README.md)

  Please take a closer look to the properties below. They are either required or control the most important aspects of the module:

  - `name`                  - (`string`, required) name of the Virtual Machine Scale Set
  - `vm_size`               - (`string`, optional, defaults to `var.vmseries_vm_size`) size of the VMSeries virtual machines created with this Scale Set, when specified overrides`var.vmseries_vm_size`
  - `version`               - (`string`, optional, defaults to `var.vmseries_version`) PanOS version
  - `vnet_key`              - (`string`, required) a key of a VNET defined in the `var.vnets` map
  - `bootstrap_options`     - (`string`, optional, defaults to `''`) bootstrap options passed to every VM instance upon creation
  - `zones`                 - (`list(string)`, optional, defaults to []) a list of Availability Zones to use for Zone redundancy
  - `scale_in_policy`       - (`string`, optional, see module defaults) policy of removing VMs when scaling in
  - `storage_account_type`  - (`string`, optional, see module defaults) type of managed disk that will be used on all VMs
  - `interfaces`            - (`list`, required) configuration of all NICs assigned to a VM. A list of maps, each map is a NIC definition. Notice that the order **DOES** matter. NICs are attached to VMs in Azure in the order they are defined in this list, therefore the management interface has to be defined first. Following properties are available:
      - `name`                    - (`string`, required) string that will form the NIC name
      - `subnet_key`              - (`string`, required) a key of a subnet as defined in `var.vnets`
      - `create_pip`              - (`bool`, optional, defaults to `false`) flag to create Public IP for an interface, defaults to `false`
      - `load_balancer_key`       - (`string`, optional, defaults to `null`) key of a Load Balancer defined in the `var.loadbalancers` variable
      - `application_gateway_key` - (`string`, optional, defaults to `null`) key of an Application Gateway defined in the `var.appgws`
      - `pip_domain_name_label`   - (`string`, optional, defaults to `null`) prefix which should be used for the Domain Name Label for each VM instance

  If you would like to set up autoscaling, following additional options are available:

  - `autoscale_config`        - (`map`, optional, defaults to `{}`) map containing basic autoscale configuration
    - `count_default`           - (`number`, optional, see module defaults) default number or instances when autoscalling is not available
    - `count_minimum`           - (`number`, optional, see module defaults) minimum number of instances to reach when scaling in
    - `count_maximum`           - (`number`, optional, see module defaults) maximum number of instances when scaling out
    - `notification_emails`     - (`list(string)`, optional, defaults to `[]`) a list of e-mail addresses to notify about scaling events
  - `autoscale_metrics`       - (`map`, optional, defaults to `{}`) metrics and thresholds used to trigger scaling events, see module documentation for details
  - `scaleout_config`         - (`map`, optional, defaults to `{}`) scale out configuration, for details see module documentation
    - `statistic`               - (`string`, optional, see module defaults) aggregation method for statistics coming from different VMs
    - `time_aggregation`        - (`string`, optional, see module defaults) aggregation method applied to statistics in time window
    - `window_minutes`          - (`string`, optional, see module defaults) time windows used to analyze statistics
    - `cooldown_minutes`        - (`string`, optional, see module defaults) time to wait after a scaling event before analyzing the statistics again
  - `scalein_config`          - (`map`, optional, defaults to `{}`) scale in configuration, same properties supported as for `scaleout_config`

  Following properties are optional and can be used to fine-tune your infrastructure:

  - `application_insights_id`       - (`string`, optional, defaults to `null`) ID of Application Insights instance that should be used to provide metrics for autoscaling
  - `encryption_at_host_enabled`    - (`bool`, optional, see module defaults) should all of the disks attached to this Virtual Machine be encrypted
  - `overprovision`                 - (`bool`, optional, see module defaults) when provisioning new VM, multiple will be provisioned but the 1st one to run will be kept
  - `platform_fault_domain_count`   - (`number`, optional, see module defaults) number of fault domains to use
  - `proximity_placement_group_id`  - (`string`, optional, defaults to `null`) ID of a proximity placement group the VMSS should be placed in
  - `scale_in_force_deletion`       - (`bool`, optional, see module defaults) when `true`, forces deletion of VMs during scale in
  - `single_placement_group`        - (`bool`, optional, see module defaults) limit the Scale Set to one Placement Group
  - `disk_encryption_set_id`        - (`string`, optional, defaults to `null`) the ID of the Disk Encryption Set which should be used to encrypt this Data Disk
  - `accelerated_networking`        - (`bool`, optional, see module defaults) enable Azure accelerated networking for all dataplane network interfaces
  - `use_custom_image`              - (`bool`, optional, defaults to `false`) flag that controls usage of a custom OS image
  - `custom_image_id`               - (`string`|required when `use_custom_image` is `true`) absolute ID of your own Custom Image to be used for creating new VM-Series

  Example, no auto scaling:

  ```
  {
  "vmss" = {
    name              = "ngfw-vmss"
    vnet_key          = "transit"
    bootstrap_options = "type=dhcp"

    interfaces = [
      {
        name       = "management"
        subnet_key = "management"
      },
      {
        name       = "private"
        subnet_key = "private"
      },
      {
        name                    = "public"
        subnet_key              = "public"
        load_balancer_key       = "public"
        application_gateway_key = "public"
      }
    ]
  }
  ```

  EOF
  default     = {}
  type        = any
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

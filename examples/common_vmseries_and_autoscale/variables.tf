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

  - `create_virtual_network`  - (`bool`, optional, defaults to `true`) when set to `true` will create a VNET, 
                                `false` will source an existing VNET.
  - `name`                    - (`string`, required) a name of a VNET. In case `create_virtual_network = false` this should be
                                a full resource name, including prefixes.
  - `address_space`           - (`list(string)`, required when `create_virtual_network = false`) a list of CIDRs for a newly
                                created VNET
  - `resource_group_name`     - (`string`, optional, defaults to current RG) a name of an existing Resource Group in which
                                the VNET will reside or is sourced from
  - `create_subnets`          - (`bool`, optional, defaults to `true`) if `true`, create Subnets inside the Virtual Network,
                                otherwise use source existing subnets
  - `subnets`                 - (`map`, optional) map of Subnets to create or source, for details see
                                [VNET module documentation](../../modules/vnet/README.md#subnets)
  - `network_security_groups` - (`map`, optional) map of Network Security Groups to create, for details see
                                [VNET module documentation](../../modules/vnet/README.md#network_security_groups)
  - `route_tables`            - (`map`, optional) map of Route Tables to create, for details see
                                [VNET module documentation](../../modules/vnet/README.md#route_tables)
  EOF

  type = map(object({
    name                   = string
    resource_group_name    = optional(string)
    create_virtual_network = optional(bool, true)
    address_space          = optional(list(string))
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
        name                = string
        address_prefix      = string
        next_hop_type       = string
        next_hop_ip_address = optional(string)
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
  A map containing configuration for all (private and public) Load Balancers.

  This is a brief description of available properties. For a detailed one please refer to
  [module documentation](../../modules/loadbalancer/README.md).

  Following properties are available:

  - `name`                    - (`string`, required) a name of the Load Balancer
  - `zones`                   - (`list`, optional, defaults to `["1", "2", "3"]`) list of zones the resource will be
                                available in, please check the
                                [module documentation](../../modules/loadbalancer/README.md#zones) for more details
  - `health_probes`           - (`map`, optional, defaults to `null`) a map defining health probes that will be used by
                                load balancing rules;
                                please check [module documentation](../../modules/loadbalancer/README.md#health_probes)
                                for more specific use cases and available properties
  - `nsg_auto_rules_settings` - (`map`, optional, defaults to `null`) a map defining a location of an existing NSG rule
                                that will be populated with `Allow` rules for each load balancing rule (`in_rules`); please check 
                                [module documentation](../../modules/loadbalancer/README.md#nsg_auto_rules_settings)
                                for available properties; please note that in this example two additional properties are
                                available:
    - `nsg_key`         - (`string`, optional, mutually exclusive with `nsg_name`) a key pointing to an NSG definition
                          in the `var.vnets` map
    - `nsg_vnet_key`    - (`string`, optional, mutually exclusive with `nsg_name`) a key pointing to a VNET definition
                          in the `var.vnets` map that stores the NSG described by `nsg_key`
  - `frontend_ips`            - (`map`, optional, defaults to `{}`) a map containing frontend IP configuration with respective
                                `in_rules` and `out_rules`

    Please refer to [module documentation](../../modules/loadbalancer/README.md#frontend_ips) for available properties.

    > [!NOTE] 
    > In this example the `subnet_id` is not available directly, three other properties were introduced instead.

    - `subnet_key`  - (`string`, optional, defaults to `null`) a key pointing to a Subnet definition in the `var.vnets` map
    - `vnet_key`    - (`string`, optional, defaults to `null`) a key pointing to a VNET definition in the `var.vnets` map
                      that stores the Subnet described by `subnet_key`
  EOF
  default     = {}
  nullable    = false
  type = map(object({
    name  = string
    zones = optional(list(string), ["1", "2", "3"])
    health_probes = optional(map(object({
      name                = string
      protocol            = string
      port                = optional(number)
      probe_threshold     = optional(number)
      interval_in_seconds = optional(number)
      request_path        = optional(string)
    })))
    nsg_auto_rules_settings = optional(object({
      nsg_name                = optional(string)
      nsg_vnet_key            = optional(string)
      nsg_key                 = optional(string)
      nsg_resource_group_name = optional(string)
      source_ips              = list(string)
      base_priority           = optional(number)
    }))
    frontend_ips = optional(map(object({
      name                     = string
      public_ip_name           = optional(string)
      create_public_ip         = optional(bool, false)
      public_ip_resource_group = optional(string)
      vnet_key                 = optional(string)
      subnet_key               = optional(string)
      private_ip_address       = optional(string)
      gwlb_key                 = optional(string)
      in_rules = optional(map(object({
        name                = string
        protocol            = string
        port                = number
        backend_port        = optional(number)
        health_probe_key    = optional(string)
        floating_ip         = optional(bool)
        session_persistence = optional(string)
        nsg_priority        = optional(number)
      })), {})
      out_rules = optional(map(object({
        name                     = string
        protocol                 = string
        allocated_outbound_ports = optional(number)
        enable_tcp_reset         = optional(bool)
        idle_timeout_in_minutes  = optional(number)
      })), {})
    })), {})
  }))
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

  Following properties are available:
  - `name` : (string|required) name of the Virtual Machine Scale Set.
  - `vm_size` : size of the VMSeries virtual machines created with this Scale Set, when specified overrides `var.vmseries_vm_size`.
  - `version` : PanOS version, when specified overrides `var.vmseries_version`.
  - `vnet_key` : (string|required) a key of a VNET defined in the `var.vnets` map.
  - `bootstrap_options` : (string|`''`) bootstrap options passed to every VM instance upon creation.
  - `zones` : (list(string)|`[]`) a list of Availability Zones to use for Zone redundancy
  - `encryption_at_host_enabled` : (bool|`null` - Azure defaults) should all of the disks attached to this Virtual Machine be encrypted
  - `overprovision` : (bool|`null` - module defaults) when provisioning new VM, multiple will be provisioned but the 1st one to run will be kept
  - `platform_fault_domain_count` : (number|`null` - Azure defaults) number of fault domains to use
  - `proximity_placement_group_id` : (string|`null`) ID of a proximity placement group the VMSS should be placed in
  - `scale_in_policy` : (string|`null` - Azure defaults) policy of removing VMs when scaling in
  - `scale_in_force_deletion` : (bool|`null` - module default) forces (`true`) deletion of VMs during scale in
  - `single_placement_group` : (bool|`null` - Azure defaults) limit the Scale Set to one Placement Group
  - `storage_account_type` : (string|`null` - module defaults) type of managed disk that will be used on all VMs
  - `disk_encryption_set_id` : (string|`null`) the ID of the Disk Encryption Set which should be used to encrypt this Data Disk
  - `accelerated_networking` : (bool|`null`- module defaults) enable Azure accelerated networking for all dataplane network interfaces
  - `use_custom_image` : (bool|`false`) 
  - `custom_image_id` : (string|reqquired when `use_custom_image` is `true`) absolute ID of your own Custom Image to be used for creating new VM-Series
  - `application_insights_id` : (string|`null`) ID of Application Insights instance that should be used to provide metrics for autoscaling
  - `interfaces` : (list(string)|`[]`) configuration of all NICs assigned to a VM. A list of maps, each map is a NIC definition. Notice that the order DOES matter. NICs are attached to VMs in Azure in the order they are defined in this list, therefore the management interface has to be defined first. Following properties are available:
    - `name` : (string|required) string that will form the NIC name
    - `subnet_key` : (string|required) a key of a subnet as defined in `var.vnets`
    - `create_pip` : (bool|`false`) flag to create Public IP for an interface, defaults to `false`
    - `load_balancer_key` : (string|`null`) key of a Load Balancer defined in the `var.loadbalancers` variable
    - `application_gateway_key` : (string|`null`) key of an Application Gateway defined in the `var.appgws`
    - `pip_domain_name_label` : (string|`null`) prefix which should be used for the Domain Name Label for each VM instance
  - `autoscale_config` : (map|`{}`) map containing basic autoscale configuration
    - `count_default` : (number|`null` - module defaults) default number or instances when autoscalling is not available
    - `count_minimum` : (number|`null` - module defaults) minimum number of instances to reach when scaling in
    - `count_maximum` : (number|`null` - module defaults) maximum number of instances when scaling out
    - `notification_emails` : (list(string)|`null` - module defaults) a list of e-mail addresses to notify about scaling events
  - `autoscale_metrics` : (map|`{}`) metrics and thresholds used to trigger scaling events, see module documentation for details
  - `scaleout_config` : (map|`{}`) scale out configuration, for details see module documentation
    - `statistic` : (string|`null` - module defaults) aggregation method for statistics coming from different VMs
    - `time_aggregation` : (string|`null` - module defaults) aggregation method applied to statistics in time window
    - `window_minutes` : (string|`null` - module defaults) time windows used to analyze statistics
    - `cooldown_minutes` : (string|`null` - module defaults) time to wait after a scaling event before analyzing the statistics again
  - `scalein_config` : (map|`{}`) scale in configuration, same properties supported as for `scaleout_config`

  Example, no auto scaling:

  ```
  {
  "vmss" = {
    name              = "ngfw-vmss"
    vnet_key          = "transit"
    bootstrap_options = "type=dhcp-client"

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



### Application Gateway
variable "appgws" {
  description = <<-EOF
  A map defining all Application Gateways in the current deployment.

  For detailed documentation on how to configure this resource, for available properties, especially for the defaults, refer to [module documentation](../../modules/appgw/README.md).

  Following properties are supported:
  - `name`                              - (`string`, required) name of the Application Gateway.
  - `public_ip`                         - (`string`, required) public IP address.
  - `vnet_key`                          - (`string`, required) a key of a VNET defined in the `var.vnets` map.
  - `subnet_key`                        - (`string`, required) a key of a subnet as defined in `var.vnets`. This has to be a subnet dedicated to Application Gateways v2.
  - `managed_identities`                - (`list`, optional) a list of existing User-Assigned Managed Identities, which Application Gateway uses to retrieve certificates from Key Vault.
  - `capacity`                          - (`number`, object) capacity configuration for Application Gateway (refer to [module documentation](../../modules/appgw/README.md) for details)
  - `waf`                               - (`object`, required) WAF basic configuration, defining WAF rules is not supported
  - `enable_http2`                      - (`bool`, optional) enable HTTP2 support on the Application Gateway
  - `zones`                             - (`list`, required) for zonal deployment this is a list of all zones in a region - this property is used by both: the Application Gateway and the Public IP created in front of the AppGW.
  - `frontend_ip_configuration_name`    - (`string`, optional) frontend IP configuration name
  - `vmseries_public_nic_name`          - (`string`, optional) VM-Series NIC name, for which IP address will be used in backend pool
  - `listeners`                         - (`map`, required) map of listeners (refer to [module documentation](../../modules/appgw/README.md) for details)
  - `backend_pool`                      - (`object`, optional) backend pool (refer to [module documentation](../../modules/appgw/README.md) for details)
  - `backends`                          - (`map`, optional) map of backends (refer to [module documentation](../../modules/appgw/README.md) for details)
  - `probes`                            - (`map`, optional) map of probes (refer to [module documentation](../../modules/appgw/README.md) for details)
  - `rewrites`                          - (`map`, optional) map of rewrites (refer to [module documentation](../../modules/appgw/README.md) for details)
  - `rules`                             - (`map`, required) map of rules (refer to [module documentation](../../modules/appgw/README.md) for details)
  - `redirects`                         - (`map`, optional) map of redirects (refer to [module documentation](../../modules/appgw/README.md) for details)
  - `url_path_maps`                     - (`map`, optional) map of URL path maps (refer to [module documentation](../../modules/appgw/README.md) for details)
  - `ssl_policy_type`                   - (`string`, optional) type of an SSL policy, defaults to `Predefined`
  - `ssl_policy_name`                   - (`string`, optional) name of an SSL policy, for `ssl_policy_type` set to `Predefined`
  - `ssl_policy_min_protocol_version`   - (`string`, optional) minimum version of the TLS protocol for SSL Policy, for `ssl_policy_type` set to `Custom`
  - `ssl_policy_cipher_suites`          - (`list`, optional) a list of accepted cipher suites, for `ssl_policy_type` set to `Custom`
  - `ssl_profiles`                      - (`map`, optional) a map of SSL profiles that can be later on referenced in HTTPS listeners by providing a name of the profile in the `ssl_profile_name` property
  EOF
  type = map(object({
    name = string
    public_ip = object({
      name           = string
      resource_group = optional(string)
      create         = optional(bool, true)
    })
    vnet_key           = string
    subnet_key         = string
    managed_identities = optional(list(string))
    capacity = object({
      static = optional(number)
      autoscale = optional(object({
        min = optional(number)
        max = optional(number)
      }))
    })
    waf = optional(object({
      prevention_mode  = bool
      rule_set_type    = optional(string, "OWASP")
      rule_set_version = optional(string)
    }))
    enable_http2                   = optional(bool)
    zones                          = list(string)
    frontend_ip_configuration_name = optional(string, "public_ipconfig")
    vmseries_public_nic_name       = optional(string, "public")
    listeners = map(object({
      name                     = string
      port                     = number
      protocol                 = optional(string, "Http")
      host_names               = optional(list(string))
      ssl_profile_name         = optional(string)
      ssl_certificate_path     = optional(string)
      ssl_certificate_pass     = optional(string)
      ssl_certificate_vault_id = optional(string)
      custom_error_pages       = optional(map(string), {})
    }))
    backend_pool = optional(object({
      name         = string
      vmseries_ips = optional(list(string), [])
    }))
    backends = optional(map(object({
      name                  = string
      path                  = optional(string)
      hostname_from_backend = optional(string)
      hostname              = optional(string)
      port                  = optional(number, 80)
      protocol              = optional(string, "Http")
      timeout               = optional(number, 60)
      cookie_based_affinity = optional(string, "Enabled")
      affinity_cookie_name  = optional(string)
      probe                 = optional(string)
      root_certs = optional(map(object({
        name = string
        path = string
      })), {})
    })))
    probes = optional(map(object({
      name       = string
      path       = string
      host       = optional(string)
      port       = optional(number)
      protocol   = optional(string, "Http")
      interval   = optional(number, 5)
      timeout    = optional(number, 30)
      threshold  = optional(number, 2)
      match_code = optional(list(number))
      match_body = optional(string)
    })), {})
    rewrites = optional(map(object({
      name = optional(string)
      rules = optional(map(object({
        name     = string
        sequence = number
        conditions = optional(map(object({
          pattern     = string
          ignore_case = optional(bool, false)
          negate      = optional(bool, false)
        })), {})
        request_headers  = optional(map(string), {})
        response_headers = optional(map(string), {})
      })))
    })), {})
    rules = map(object({
      name         = string
      priority     = number
      backend      = optional(string)
      listener     = string
      rewrite      = optional(string)
      url_path_map = optional(string)
      redirect     = optional(string)
    }))
    redirects = optional(map(object({
      name                 = string
      type                 = string
      target_listener      = optional(string)
      target_url           = optional(string)
      include_path         = optional(bool, false)
      include_query_string = optional(bool, false)
    })), {})
    url_path_maps = optional(map(object({
      name    = string
      backend = string
      path_rules = optional(map(object({
        paths    = list(string)
        backend  = optional(string)
        redirect = optional(string)
      })))
    })), {})
    ssl_global = optional(object({
      ssl_policy_type                 = string
      ssl_policy_name                 = optional(string)
      ssl_policy_min_protocol_version = optional(string)
      ssl_policy_cipher_suites        = optional(list(string))
    }))
    ssl_profiles = optional(map(object({
      name                            = string
      ssl_policy_name                 = optional(string)
      ssl_policy_min_protocol_version = optional(string)
      ssl_policy_cipher_suites        = optional(list(string))
    })), {})
  }))
}

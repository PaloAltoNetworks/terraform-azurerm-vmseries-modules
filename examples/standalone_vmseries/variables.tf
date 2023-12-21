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
      name                          = string
      disable_bgp_route_propagation = optional(bool)
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
  A map defining NAT Gateways. 

  Please note that a NAT Gateway is a zonal resource, this means it's always placed in a zone (even when you do not specify one
  explicitly). Please refer to Microsoft documentation for notes on NAT Gateway's zonal resiliency.
  For detailed documentation on each property refer to [module documentation](../../modules/natgw/README.md).
  
  Following properties are supported:
  - `create_natgw`       - (`bool`, optional, defaults to `true`) create (`true`) or source an existing NAT Gateway (`false`),
                           created or sourced: the NAT Gateway will be assigned to a subnet created by the `vnet` module.
  - `name`               - (`string`, required) a name of a NAT Gateway. In case `create_natgw = false` this should be a full
                           resource name, including prefixes.
  - `resource_group_name - (`string`, optional) name of a Resource Group hosting the NAT Gateway (newly created or the existing
                           one).
  - `zone`               - (`string`, optional) an Availability Zone in which the NAT Gateway will be placed, when skipped
                           AzureRM will pick a zone.
  - `idle_timeout`       - (`number`, optional, defults to 4) connection IDLE timeout in minutes, for newly created resources.
  - `vnet_key`           - (`string`, required) a name (key value) of a VNET defined in `var.vnets` that hosts a subnet this
                           NAT Gateway will be assigned to.
  - `subnet_keys`        - (`list(string)`, required) a list of subnets (key values) the NAT Gateway will be assigned to, defined
                           in `var.vnets` for a VNET described by `vnet_name`.
  - `public_ip`          - (`object`, optional) an object defining a public IP resource attached to the NAT Gateway.
  - `public_ip_prefix`   - (`object`, optional) an object defining a public IP prefix resource attached to the NAT Gatway.

  Example:
  ```
  natgws = {
    "natgw" = {
      name        = "natgw"
      vnet_key    = "transit-vnet"
      subnet_keys = ["management"]
      public_ip = {
        create = true
        name   = "natgw-pip"
      }
    }
  }
  ```
  EOF
  default     = {}
  type = map(object({
    create_natgw        = optional(bool, true)
    name                = string
    resource_group_name = optional(string)
    zone                = optional(string)
    idle_timeout        = optional(number, 4)
    vnet_key            = string
    subnet_keys         = list(string)
    public_ip = optional(object({
      create              = bool
      name                = string
      resource_group_name = optional(string)
    }))
    public_ip_prefix = optional(object({
      create              = bool
      name                = string
      resource_group_name = optional(string)
      length              = optional(number)
    }))
  }))
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

variable "ngfw_metrics" {
  description = <<-EOF
  A map controlling metrics-relates resources.

  When set to explicit `null` (default) it will disable any metrics resources in this deployment.

  When defined it will either create or source a Log Analytics Workspace and create Application Insights instances (one per each
  Scale Set). All instances will be automatically connected to the workspace.
  The name of the Application Insights instance will be derived from the Scale Set name and suffixed with `-ai`.

  All the settings available below are common to the Log Analytics Workspace and Application Insight instances.

  Following properties are available:

  - `name`                      - (`string`, required) name of the (common) Log Analytics Workspace
  - `create_workspace`          - (`bool`, optional, defaults to `true`) controls whether we create or source an existing Log
                                  Analytics Workspace
  - `resource_group_name`       - (`string`, optional, defaults to `var.resource_group_name`) name of the Resource Group hosting
                                  the Log Analytics Workspace
  - `sku`                       - (`string`, optional, defaults to module defaults) the SKU of the Log Analytics Workspace.
  - `metrics_retention_in_days` - (`number`, optional, defaults to module defaults) workspace and insights data retention in
                                  days, possible values are between 30 and 730. For sourced Workspaces this applies only to 
                                  the Application Insights instances.
  EOF
  default     = null
  type = object({
    name                      = string
    create_workspace          = optional(bool, true)
    resource_group_name       = optional(string)
    sku                       = optional(string)
    metrics_retention_in_days = optional(number)
  })
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
  default     = {}
  nullable    = false
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

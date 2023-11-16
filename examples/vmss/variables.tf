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
  ```hcl
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


### VNET
variable "vnets" {
  description = <<-EOF
  A map defining VNETs.
  
  For detailed documentation on each property refer to [module documentation](../../modules/vnet/README.md)

  - `create_virtual_network`  - (`bool`, optional, defaults to `true`) when set to `true` will create a VNET, `false` will source an existing VNET.
  - `name`                    - (`string`, required) a name of a VNET. In case `create_virtual_network = false` this should be a full resource name, including prefixes.
  - `address_space`           - (`list(string)`, required when `create_virtual_network = false`) a list of CIDRs for a newly created VNET
  - `resource_group_name`     - (`string`, optional, defaults to current RG) a name of an existing Resource Group in which the VNET will reside or is sourced from

  - `create_subnets`          - (`bool`, optional, defaults to `true`) if `true`, create Subnets inside the Virtual Network, otherwise use source existing subnets
  - `subnets`                 - (`map`, optional) map of Subnets to create or source, for details see [VNET module documentation](../../modules/vnet/README.md#subnets)

  - `network_security_groups` - (`map`, optional) map of Network Security Groups to create, for details see [VNET module documentation](../../modules/vnet/README.md#network_security_groups)
  - `route_tables`            - (`map`, optional) map of Route Tables to create, for details see [VNET module documentation](../../modules/vnet/README.md#route_tables)
  EOF

  type = map(object({
    name                   = string
    create_virtual_network = optional(bool, true)
    address_space          = optional(list(string), [])
    resource_group_name    = optional(string)
    network_security_groups = optional(map(object({
      name     = string
      location = optional(string)
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
      name     = string
      location = optional(string)
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

variable "authentication" {
  default = {}
  type = object({
    username                        = optional(string)
    password                        = optional(string)
    disable_password_authentication = optional(bool)
    ssh_keys                        = optional(list(string), [])
  })
}

variable "vm_image_configuration" {
  default = {}
  type = object({
    img_version             = optional(string)
    img_publisher           = optional(string)
    img_offer               = optional(string)
    img_sku                 = optional(string)
    enable_marketplace_plan = optional(bool)
    custom_image_id         = optional(string)
  })
}

variable "ngfw_metrics" {
  description = <<-EOF
  A map defining metrics related resources for Next Generation Firewall.

  All the settings available below are common to the Log Analytics Workspace and Application Insight instances.

  > [!Note]
  > We do not explicitly define Application Insights instances. Each Virtual Machine Scale Set will receive one automatically
  > if there is at least one autoscaling profile defined.
  > The name of the Application Insights instance will be derived from the Scale Set name and suffixed with `-ai`.

  Following properties are available:

  - `name`                      - (`string`, required) name of the (common) Log Analytics Workspace
  - `create_workspace`          - (`bool`, optional, defaults to `true`) controls whether we create or source an existing Log
                                  Analytics Workspace
  - `resource_group_name`       - (`string`, optional, defaults to `var.resource_group_name`) name of the Resource Group hosting
                                  the Log Analytics Workspace
  - `sku`                       - (`string`, optional, defaults to module defaults) the SKU of the Log Analytics Workspace.
  - `metrics_retention_in_days` - (`number`, optional, defaults to module defaults) workspace and insights data retention in
                                  days, possible values are between 30 and 730.
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

variable "scale_sets" {
  description = <<-EOF
  A map defining Azure Virtual Machine Scale Set based on Next Generation Firewall image.

  For details and defaults for available options please refer to the[`vmss`](../../modules/vmss/README.md) module.

  Following properties are available:

  - `name`                    - (`string`) name of the scale set, will be prefixed with the value of `var.name_prefix`
  - `scale_set_configuration` - (`map`, optional, defaults to `{}`) a map that groups most common Scale Set configuration options.

    Below we present only the most important ones, for the rest please refer to
    [module's documentation](../../modules/vmss/README.md#scale_set_configuration):

    - `vm_size`               - (`string`, optional, defaults to module defaults) Azure VM size (type). Consult the *VM-Series
                                Deployment Guide* as only a few selected sizes are supported
    - `zones`                 - (`list`, optional, defaults to module defaults) a list of Availability Zones in which VMs from
                                this Scale Set will be created
    - `storage_account_type`  - (`string`, optional, defaults to module defaults) type of Managed Disk which should be created,
                                possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS` (works only for selected
                                `vm_size` values)

  - `autoscaling_configuration` - (`map`, optional, defaults to `{}`) a map that groups common autoscaling configuration, but not
                                  the scaling profiles (metrics thresholds, etc)

    Below we present only the most important properties, for the rest please refer to
    [module's documentation](../../modules/vmss/README.md#autoscaling_configuration).

    - `default_count`   - (`number`, optional, defaults module defaults) minimum number of instances that should be present in the
                          scale set when the autoscaling engine cannot read the metrics or is otherwise unable to compare the
                          metrics to the thresholds

  - `interfaces`  - (`list`, required) configuration of all network interfaces, order does matter - the 1<sup>st</sup> interface
                    should be the management one. Following properties are available:
    - `name`                    - (`string`, required) name of the network interface (will be prefixed with `var.name_prefix`)
    - `subnet_key`              - (`string`, required) a key of a subnet to which the interface will be assigned as defined in
                                  `var.vnets`
    - `vnet_key`                - (`string`, required) a key of a VNET hosting the subnet specified by `subnet_key`
    - `create_public_ip`        - (`bool`, optional, defaults to module defaults) create Public IP for an interface
    - `load_balancer_key`       - (`string`, optional, defaults to `null`) key of a Load Balancer defined in the
                                  `var.loadbalancers` variable
    - `application_gateway_key` - (`string`, optional, defaults to `null`) key of an Application Gateway defined in the
                                  `var.appgws`
    - `pip_domain_name_label`   - (`string`, optional, defaults to `null`) prefix which should be used for the Domain Name Label
                                  for each VM instance

  - `autoscaling_profiles`  - (`list`, optional, defaults to `[]`) a list of autoscaling profiles, for details on available
                              configuration please refer to
                              [module's documentation](../../modules/vmss/README.md#autoscaling_profiles)

  EOF
  default     = null
  type = map(object({
    name = string
    scale_set_configuration = optional(object({
      vm_size                      = optional(string)
      zones                        = optional(list(string))
      storage_account_type         = optional(string)
      accelerated_networking       = optional(bool)
      encryption_at_host_enabled   = optional(bool)
      overprovision                = optional(bool)
      platform_fault_domain_count  = optional(number)
      proximity_placement_group_id = optional(string)
      disk_encryption_set_id       = optional(string)
    }), {})
    autoscaling_configuration = optional(object({
      default_count           = optional(number)
      scale_in_policy         = optional(string)
      scale_in_force_deletion = optional(bool)
      notification_emails     = optional(list(string), [])
      webhooks_uris           = optional(map(string), {})
    }), {})
    interfaces = list(object({
      name                    = string
      vnet_key                = string
      subnet_key              = string
      create_public_ip        = optional(bool)
      load_balancer_key       = optional(string)
      application_gateway_key = optional(string)
      pip_domain_name_label   = optional(string)
    }))
    autoscaling_profiles = optional(list(object({
      name          = string
      minimum_count = optional(number)
      default_count = number
      maximum_count = optional(number)
      recurrence = optional(object({
        timezone   = optional(string)
        days       = list(string)
        start_time = string
        end_time   = string
      }))
      scale_rules = optional(list(object({
        name = string
        scale_out_config = object({
          threshold                  = number
          operator                   = optional(string)
          grain_window_minutes       = number
          grain_aggregation_type     = optional(string)
          aggregation_window_minutes = number
          aggregation_window_type    = optional(string)
          cooldown_window_minutes    = number
          change_count_by            = optional(number)
        })
        scale_in_config = object({
          threshold                  = number
          operator                   = optional(string)
          grain_window_minutes       = optional(number)
          grain_aggregation_type     = optional(string)
          aggregation_window_minutes = optional(number)
          aggregation_window_type    = optional(string)
          cooldown_window_minutes    = number
          change_count_by            = optional(number)
        })
      })), [])
    })), [])
  }))
}
variable "name" {
  description = "The name of the Azure Virtual Machine Scale Set."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "The name of the Azure region to deploy the resources in."
  type        = string
}

variable "tags" {
  description = "The map of tags to assign to all created resources."
  default     = {}
  type        = map(string)
}

variable "authentication" {
  description = <<-EOF
  A map defining authentication settings (including username and password).

  Following properties are available:

  - `username`                        - (`string`, optional, defaults to `panadmin`) the initial administrative VMseries username
  - `password`                        - (`string`, optional, defaults to `null`) the initial administrative VMSeries password
  - `disable_password_authentication` - (`bool`, optional, defaults to `true`) disables password-based authentication
  - `ssh_keys`                        - (`list`, optional, defaults to `[]`) a list of initial administrative SSH public keys

  > [!Important]
  > The `password` property is required when `ssh_keys` is not specified.

  > [!Important]
  > `ssh_keys` property is a list of strings, so each item should be the actual public key value.
  > If you would like to load them from files use the `file` function.
  > For example: `[ file("/path/to/public/keys/key_1.pub") ]`.

  EOF
  type = object({
    username                        = optional(string, "panadmin")
    password                        = optional(string)
    disable_password_authentication = optional(bool, true)
    ssh_keys                        = optional(list(string), [])
  })
  sensitive = true
  validation {
    condition     = var.authentication.password != null || length(var.authentication.ssh_keys) > 0
    error_message = "Either `var.authentication.password` or `var.authentication.ssh_key` must be set in order to have access to the device"
  }
}

variable "vm_image_configuration" {
  description = <<-EOF
  Basic Azure VM configuration.

  Following properties are available:

  - `img_version`             - (`string`, optional, defaults to `null`) VMSeries PAN-OS version; list available with 
                                `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all`
  - `img_publisher`           - (`string`, optional, defaults to `paloaltonetworks`) the Azure Publisher identifier for a image
                                which should be deployed
  - `img_offer`               - (`string`, optional, defaults to `vmseries-flex`) the Azure Offer identifier corresponding to a
                                published image
  - `img_sku`                 - (`string`, optional, defaults to `byol`) VMSeries SKU; list available with
                                `az vm image list -o table --all --publisher paloaltonetworks`
  - `enable_marketplace_plan` - (`bool`, optional, defaults to `true`) when set to `true` accepts the license for a offer/plan
                                on Azure Market Place
  - `custom_image_id`         - (`string`, optional, defaults to `null`) absolute ID of your own custom PanOS image to be used for
                                creating new Virtual Machines

  > [!Important]
  > `custom_image_id` and `img_version` properties are mutually exclusive.
  EOF
  type = object({
    img_version             = optional(string)
    img_publisher           = optional(string, "paloaltonetworks")
    img_offer               = optional(string, "vmseries-flex")
    img_sku                 = optional(string, "byol")
    enable_marketplace_plan = optional(bool, true)
    custom_image_id         = optional(string)
  })
  validation {
    condition = (var.vm_configuration.custom_image_id != null && vm_configuration.img_version != null
      ) || (
      var.vm_configuration.custom_image_id == null && vm_configuration.img_version == null
    )
    error_message = "Either `custom_image_id` or `img_version` has to be defined."
  }
}


variable "scale_set_configuration" {
  description = <<-EOF
  Scale set parameters configuration.

  This map contains basic, as well as some optional Virtual Machine Scale Set parameters. Both types contain sane defaults.
  Nevertheless they should be at least reviewed to meet deployment requirements.

  List of either required or important properties: 

  - `vm_size`               - (`string`, optional, defaults to `Standard_D3_v2`) Azure VM size (type). Consult the *VM-Series
                              Deployment Guide* as only a few selected sizes are supported
  - `zones`                 - (`list`, optional, defaults to `["1", "2", "3"]`) a list of Availability Zones in which VMs from
                              this Scale Set will be created
  - `storage_account_type`  - (`string`, optional, defaults to `StandardSSD_LRS`) type of Managed Disk which should be created,
                              possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS` (works only for selected
                              `vm_size` values)

  List of other, optional properties: 

  - `accelerated_networking`        - (`bool`, optional, defaults to `true`) when set to `true`  enables Azure accelerated
                                      networking (SR-IOV) for all dataplane network interfaces, this does not affect the
                                      management interface (always disabled)
  - `disk_encryption_set_id`        - (`string`, optional, defaults to `null`) the ID of the Disk Encryption Set which should be
                                      used to encrypt this VM's disk
  - `zone_balance`                  - (`bool`, optional, defaults to `true`) when set to `true` VMs in this Scale Set will be
                                      evenly distributed across configured Availability Zones
  - `encryption_at_host_enabled`    - (`bool`, optional, defaults to Azure defaults) should all of disks be encrypted
                                      by enabling Encryption at Host
  - `overprovision`                 - (`bool`, optional, defaults to `true`) See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)
  - `platform_fault_domain_count`   - (`number`, optional, defaults to Azure defaults) specifies the number of fault domains that
                                      are used by this Virtual Machine Scale Set
  - `proximity_placement_group_id`  - (`string`, optional, defaults to Azure defaults) the ID of the Proximity Placement Group
                                      in which the Virtual Machine Scale Set should be assigned to
  - `single_placement_group`        - (`bool`, defaults to Azure defaults) when `true` this Virtual Machine Scale Set will be
                                      limited to a Single Placement Group, which means the number of instances will be capped
                                      at 100 Virtual Machines

  EOF
  type = object({
    vm_size                      = optional(string, "Standard_D3_v2")
    zones                        = optional(list(string), ["1", "2", "3"])
    zone_balance                 = optional(bool, true)
    storage_account_type         = optional(string, "StandardSSD_LRS")
    accelerated_networking       = optional(bool, true)
    encryption_at_host_enabled   = optional(bool)
    overprovision                = optional(bool, true)
    platform_fault_domain_count  = optional(number)
    proximity_placement_group_id = optional(string)
    disk_encryption_set_id       = optional(string)
  })
  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.scale_set_configuration.storage_account_type)
    error_message = "The `storage_account_type` property can be one of: `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`."
  }
}

variable "bootstrap_options" {
  description = <<-EOF
  Bootstrap options to pass to VM-Series instance.

  Proper syntax is a string of semicolon separated properties, for example:
  `bootstrap_options = "type=dhcp-client;panorama-server=1.2.3.4"`

  For more details on bootstrapping [see documentation](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/init-cfgtxt-file-components).
  EOF
  default     = ""
  type        = string
  nullable    = false
  sensitive   = true
}

variable "diagnostics_storage_uri" {
  description = "The storage account's blob endpoint to hold diagnostic files."
  default     = null
  type        = string
}

variable "interfaces" {
  description = <<-EOF
  List of the network interfaces specifications.

  > [!Notice]
  > The ORDER in which you specify the interfaces DOES MATTER.

  Interfaces will be attached to VM in the order you define here, therefore:

  - the first should be the management interface, which does not participate in data filtering
  - the remaining ones are the dataplane interfaces.
  
  Following configuration options are available:

  - `name`                      - (`string`, required) the interface name
  - `subnet_id`                 - (`string`, required) ID of an existing subnet to create the interface in
  - `create_public_ip`          - (`bool`, optional, defaults to `false`) if `true`, create a public IP for the interface
  - `lb_backend_pool_ids`       - (`list`, optional, defaults to `[]`) a list of identifiers of existing Load Balancer backend
                                  pools to associate the interface with
  - `appgw_backend_pool_ids`    - (`list`, optional, defaults to `[]`) a list of identifier of Application Gateway's backend
                                  pools to associate the interface with
  - `pip_domain_name_label`     - (`string`, optional, defaults to `null`) the Prefix which should be used for the Domain Name
                                  Label for each Virtual Machine Instance.

  Example:

  ```hcl
  [
    {
      name       = "management"
      subnet_id  = azurerm_subnet.my_mgmt_subnet.id
      create_pip = true
    },
    {
      name      = "private"
      subnet_id = azurerm_subnet.my_priv_subnet.id
    },
    {
      name                = "public"
      subnet_id           = azurerm_subnet.my_pub_subnet.id
      lb_backend_pool_ids = [azurerm_lb_backend_address_pool.lb_backend.id]
    }
  ]
  ```
  EOF
  type = list(object({
    name                   = string
    subnet_id              = string
    create_public_ip       = optional(bool, false)
    lb_backend_pool_ids    = optional(list(string), [])
    appgw_backend_pool_ids = optional(list(string), [])
    pip_domain_name_label  = optional(string)
  }))
  validation {
    condition     = length(var.interfaces[0].lb_backend_pool_ids) == 0 && length(var.interfaces[0].appgw_backend_pool_ids) == 0
    error_message = "The `lb_backend_pool_ids` and `appgw_backend_pool_ids` properties are not acceptable for the 1st (management) interface."
  }
}

variable "autoscaling_configuration" {
  description = <<-EOF
  Autoscaling configuration common to all policies

  Following properties are available:
  - `application_insights_id`       - (`string`, optional, defaults to `null`) an ID of Application Insights instance that should
                                      be used to provide metrics for autoscaling; to **avoid false positives** this should be an
                                      instance **dedicated to this Scale Set**
  - `autoscale_count_default`       - (`number`, optional, defaults to `2`) minimum number of instances that should be present
                                      in the scale set when the autoscaling engine cannot read the metrics or is otherwise unable
                                      to compare the metrics to the thresholds
  - `scale_in_policy`               - (`string`, optional, defaults to Azure default) controls which VMs are chosen for removal
                                      during a scale-in, can be one of: `Default`, `NewestVM`, `OldestVM`.
  - `scale_in_force_deletion`       - (`bool`, optional, defaults to `false`) when `true` will **force delete** machines during a
                                      scale-in
  - `autoscale_notification_emails` - (`list`, optional, defaults to `[]`) list of email addresses to notify about autoscaling
                                      events
  - `autoscale_webhooks_uris`       - (`map`, optional, defaults to `{}`) the URIs receive autoscaling events; a map where keys
                                      are just arbitrary identifiers and the values are the webhook URIs
  EOF
  default     = {}
  type = object({
    application_insights_id       = optional(string)
    autoscale_count_default       = optional(number, 2)
    scale_in_policy               = optional(string)
    scale_in_force_deletion       = optional(bool, false)
    autoscale_notification_emails = optional(list(string), [])
    autoscale_webhooks_uris       = optional(map(string), {})
  })
  validation {
    condition     = contains(["Default", "NewestVM", "OldestVM"], var.autoscaling_configuration.scale_in_policy)
    error_message = "The `scale_in_policy` property can be one of: `Default`, `NewestVM`, `OldestVM`."
  }
}





variable "autoscale_count_minimum" {
  description = "The minimum number of instances that should be present in the scale set."
  default     = 2
  type        = number
  nullable    = false
}

variable "autoscale_count_maximum" {
  description = "The maximum number of instances that should be present in the scale set."
  default     = 5
  type        = number
  nullable    = false
}



variable "autoscale_metrics" {
  description = <<-EOF
  Map of objects, where each key is the metric name to be used for autoscaling.
  Each value of the map has the attributes `scaleout_threshold` and `scalein_threshold`, which cause the instance count to grow by 1 when metrics are greater or equal, or decrease by 1 when lower or equal, respectively.
  The thresholds are applied to results of metrics' aggregation over a time window.
  Example:
  ```
  {
    "DataPlaneCPUUtilizationPct" = {
      scaleout_threshold = 80
      scalein_threshold  = 20
    }
    "panSessionUtilization" = {
      scaleout_threshold = 80
      scalein_threshold  = 20
    }
  }
  ```

  Other possible metrics include panSessionActive, panSessionThroughputKbps, panSessionThroughputPps, DataPlanePacketBufferUtilization.
  EOF
  default     = {}
  type        = map(any)
}

variable "scaleout_statistic" {
  description = "Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines. Possible values are Average, Min and Max."
  default     = "Max"
  type        = string
  nullable    = false
}

variable "scaleout_time_aggregation" {
  description = "Specifies how the metric should be combined over the time `scaleout_window_minutes`. Possible values are Average, Count, Maximum, Minimum, Last and Total."
  default     = "Maximum"
  type        = string
  nullable    = false
}

variable "scaleout_window_minutes" {
  description = <<-EOF
  This is amount of time in minutes that autoscale engine will look back for metrics. For example, 10 minutes means that every time autoscale runs,
  it will query metrics for the past 10 minutes. This allows metrics to stabilize and avoids reacting to transient spikes.
  Must be between 5 and 720 minutes.
  EOF
  default     = 10
  type        = number
  nullable    = false
}

variable "scaleout_cooldown_minutes" {
  description = "Azure only considers adding a VM after this number of minutes has passed since the last VM scaling action. It should be much higher than `scaleout_window_minutes`, to account both for the VM-Series spin-up time and for the subsequent metrics stabilization time. Must be between 1 and 10080 minutes."
  default     = 25
  type        = number
  nullable    = false
}

variable "scalein_statistic" {
  description = "Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines. Possible values are Average, Min and Max."
  default     = "Max"
  type        = string
  nullable    = false
}

variable "scalein_time_aggregation" {
  description = "Specifies how the metric should be combined over the time `scalein_window_minutes`. Possible values are Average, Count, Maximum, Minimum, Last and Total."
  default     = "Maximum"
  type        = string
  nullable    = false
}

variable "scalein_window_minutes" {
  description = <<-EOF
  This is amount of time in minutes that autoscale engine will look back for metrics. For example, 10 minutes means that every time autoscale runs,
  it will query metrics for the past 10 minutes. This allows metrics to stabilize and avoids reacting to transient spikes.
  Must be between 5 and 720 minutes.
  EOF
  default     = 15
  type        = number
  nullable    = false
}

variable "scalein_cooldown_minutes" {
  description = "Azure only considers deleting a VM after this number of minutes has passed since the last VM scaling action. Should be higher or equal to `scalein_window_minutes`. Must be between 1 and 10080 minutes."
  default     = 2880
  type        = number
  nullable    = false
}



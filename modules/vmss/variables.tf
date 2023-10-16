variable "name" {
  description = "Name of the created scale set."
  type        = string
}

variable "location" {
  description = "Region to install VM-Series and dependencies."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group where to place the resources created."
  type        = string
}

variable "vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported."
  default     = "Standard_D3_v2"
  type        = string
}

variable "interfaces" {
  description = <<-EOF
  List of the network interface specifications.

  NOTICE. The ORDER in which you specify the interfaces DOES MATTER.
  Interfaces will be attached to VM in the order you define here, therefore:
  * The first should be the management interface, which does not participate in data filtering.
  * The remaining ones are the dataplane interfaces.
  
  Options for an interface object:
  - `name`                     - (required|string) Interface name.
  - `subnet_id`                - (required|string) Identifier of an existing subnet to create interface in.
  - `create_pip`               - (optional|bool) If true, create a public IP for the interface
  - `lb_backend_pool_ids`      - (optional|list(string)) A list of identifiers of an existing Load Balancer backend pools to associate interface with.
  - `appgw_backend_pool_ids`   - (optional|list(String)) A list of identifier of the Application Gateway backend pools to associate interface with.
  - `pip_domain_name_label`    - (optional|string) The Prefix which should be used for the Domain Name Label for each Virtual Machine Instance.

  Example:

  ```
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
  type        = any
}

variable "username" {
  description = "Initial administrative username to use for VM-Series."
  default     = "panadmin"
  type        = string
}

variable "password" {
  description = "Initial administrative password to use for VM-Series."
  type        = string
  sensitive   = true
}

variable "ssh_keys" {
  description = <<-EOF
  A list of initial administrative SSH public keys that allow key-pair authentication. If not defined the `password` variable must be specified.
  
  This is a list of strings, so each item should be the actual public key value. If you would like to load them from files instead, following method is available:

  ```
  [
    file("/path/to/public/keys/key_1.pub"),
    file("/path/to/public/keys/key_2.pub")
  ]
  ```
  EOF
  default     = []
  type        = list(string)
}

variable "disable_password_authentication" {
  description = "If true, disables password-based authentication on VM-Series instances."
  default     = true
  type        = bool
}

variable "encryption_at_host_enabled" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#encryption_at_host_enabled)."
  default     = null
  type        = bool
}

variable "overprovision" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)."
  default     = false
  type        = bool
  nullable    = false
}

variable "platform_fault_domain_count" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)."
  default     = null
  type        = number
}

variable "proximity_placement_group_id" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)."
  default     = null
  type        = string
}

variable "scale_in_policy" {
  description = <<-EOF
  Which virtual machines are chosen for removal when a Virtual Machine Scale Set is scaled in. Either:

  - `Default`, which, baring the availability zone usage and fault domain usage, deletes VM with the highest-numbered instance id,
  - `NewestVM`, which, baring the availability zone usage, deletes VM with the newest creation time,
  - `OldestVM`, which, baring the availability zone usage, deletes VM with the oldest creation time.
  EOF
  default     = null
  type        = string
}

variable "scale_in_force_deletion" {
  description = "When set to `true` will force delete machines selected for removal by the `scale_in_policy`."
  default     = false
  type        = bool
  nullable    = false
}

variable "single_placement_group" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)."
  default     = null
  type        = bool
}

variable "zone_balance" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)."
  default     = true
  type        = bool
}

variable "zones" {
  description = "The availability zones to use, for example `[\"1\", \"2\", \"3\"]`. If an empty list, no Availability Zones are used: `[]`."
  default     = ["1", "2", "3"]
  type        = list(string)
  nullable    = false
}

variable "storage_account_type" {
  description = "Type of Managed Disk which should be created. Possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`. The `Premium_LRS` works only for selected `vm_size` values, details in Azure docs."
  default     = "StandardSSD_LRS"
  type        = string
  nullable    = false
}

variable "disk_encryption_set_id" {
  description = "The ID of the Disk Encryption Set which should be used to encrypt this Data Disk."
  default     = null
  type        = string
}

variable "use_custom_image" {
  description = "If true, use `custom_image_id` and ignore the inputs `username`, `password`, `img_version`, `img_publisher`, `img_offer`, `img_sku` (all these are used only for published images, not custom ones)."
  default     = false
  type        = bool
}

variable "custom_image_id" {
  description = "Absolute ID of your own Custom Image to be used for creating new VM-Series. The Custom Image is expected to contain PAN-OS software."
  default     = null
  type        = string
}

variable "enable_plan" {
  description = "Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku \"byol\", which means \"bring your own license\", still requires accepting on the Marketplace (as of 2021). Can be set to `false` when using a custom image."
  default     = true
  type        = bool
}

variable "img_publisher" {
  description = "The Azure Publisher identifier for a image which should be deployed."
  default     = "paloaltonetworks"
  type        = string
}

variable "img_offer" {
  description = "The Azure Offer identifier corresponding to a published image. For `img_version` 9.1.1 or above, use \"vmseries-flex\"; for 9.1.0 or below use \"vmseries1\"."
  default     = "vmseries-flex"
  type        = string
}

variable "img_sku" {
  description = "VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "byol"
  type        = string
}

variable "img_version" {
  description = "VM-Series PAN-OS version - list available for a default `img_offer` with `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all`"
  type        = string
}

variable "accelerated_networking" {
  description = "If true, enable Azure accelerated networking (SR-IOV) for all dataplane network interfaces. [Requires](https://docs.paloaltonetworks.com/pan-os/9-0/pan-os-new-features/virtualization-features/support-for-azure-accelerated-networking-sriov) PAN-OS 9.0 or higher. The PAN-OS management interface (nic0) is never accelerated, whether this variable is true or false."
  default     = true
  type        = bool
  nullable    = false
}

variable "application_insights_id" {
  description = <<-EOF
  An ID of Application Insights instance that should be used to provide metrics for autoscaling.

  **Note**, to avoid false positives this should be an instance dedicated to this VMSS.
  ```
  EOF
  default     = null
  type        = string
}

variable "autoscale_count_default" {
  description = "The minimum number of instances that should be present in the scale set when the autoscaling engine cannot read the metrics or is otherwise unable to compare the metrics to the thresholds."
  default     = 2
  type        = number
  nullable    = false
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

variable "autoscale_notification_emails" {
  description = "List of email addresses to notify about autoscaling events."
  default     = []
  type        = list(string)
  nullable    = false
}

variable "autoscale_webhooks_uris" {
  description = "Map where each key is an arbitrary identifier and each value is a webhook URI. The URIs receive autoscaling events."
  default     = {}
  type        = map(string)
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

variable "tags" {
  description = "Map of tags to use for all the created resources."
  default     = {}
  type        = map(string)
}

variable "bootstrap_options" {
  description = <<-EOF
  Bootstrap options to pass to VM-Series instance.

  Proper syntax is a string of semicolon separated properties.
  Example:
    bootstrap_options = "type=dhcp-client;panorama-server=1.2.3.4"

  For more details on bootstrapping see documentation: https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/init-cfgtxt-file-components
  EOF
  default     = ""
  type        = string
  sensitive   = true
}

variable "diagnostics_storage_uri" {
  description = "The storage account's blob endpoint to hold diagnostic files."
  default     = null
  type        = string
}
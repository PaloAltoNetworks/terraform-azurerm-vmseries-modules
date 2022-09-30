variable "location" {
  description = "Region to install VM-Series and dependencies."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group where to place the resources created."
  type        = string
}

variable "name_prefix" {
  description = "A prefix for all the names of the created Azure objects. It can end with a dash `-` character, if your naming convention prefers such separator."
  type        = string
}

variable "vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported."
  default     = "Standard_D3_v2"
  type        = string
}

variable "subnet_mgmt" {
  description = "Management subnet."
  type        = object({ id = string })
}

variable "subnet_public" {
  description = "Public subnet (untrusted)."
  type        = object({ id = string })
}

variable "subnet_private" {
  description = "Private subnet (trusted)."
  type        = object({ id = string })
}

variable "create_mgmt_pip" {
  default = true
  type    = bool
}

variable "create_public_pip" {
  default = true
  type    = bool
}

variable "mgmt_pip_domain_name_label" {
  default = null
  type    = string
}

variable "mgmt_pip_prefix_id" {
  description = "Public IP address prefix id to use for management interface."
  default     = null
  type        = string
}

variable "public_pip_domain_name_label" {
  default = null
  type    = string
}

variable "username" {
  description = "Initial administrative username to use for VM-Series."
  default     = "panadmin"
  type        = string
}

variable "password" {
  description = "Initial administrative password to use for VM-Series."
  type        = string
}

variable "disable_password_authentication" {
  description = "If true, disables password-based authentication on VM-Series instances."
  default     = false
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
}

variable "storage_account_type" {
  description = "Type of Managed Disk which should be created. Possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`. The `Premium_LRS` works only for selected `vm_size` values, details in Azure docs."
  default     = "StandardSSD_LRS"
  type        = string
}

variable "disk_encryption_set_id" {
  default = null
  type    = string
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
}

variable "img_offer" {
  description = "The Azure Offer identifier corresponding to a published image. For `img_version` 9.1.1 or above, use \"vmseries-flex\"; for 9.1.0 or below use \"vmseries1\"."
  default     = "vmseries-flex"
}

variable "img_sku" {
  description = "VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "bundle2"
  type        = string
}

variable "img_version" {
  description = "VM-Series PAN-OS version - list available for a default `img_offer` with `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all`"
  default     = "9.1.3"
  type        = string
}

variable "private_backend_pool_id" {
  description = "Identifier of the load balancer backend pool to associate with the private interface of each VM-Series firewall."
  type        = string
  default     = null
}

variable "public_backend_pool_id" {
  description = "Identifier of the load balancer backend pool to associate with the public interface of each VM-Series firewall."
  type        = string
  default     = null
}

variable "create_public_interface" {
  description = "If true, create the third network interface for virtual machines."
  default     = true
  type        = bool
}

variable "accelerated_networking" {
  description = "If true, enable Azure accelerated networking (SR-IOV) for all dataplane network interfaces. [Requires](https://docs.paloaltonetworks.com/pan-os/9-0/pan-os-new-features/virtualization-features/support-for-azure-accelerated-networking-sriov) PAN-OS 9.0 or higher. The PAN-OS management interface (nic0) is never accelerated, whether this variable is true or false."
  default     = true
  type        = bool
}

variable "app_insights_settings" {
  description = <<-EOF
  A map of the Application Insights related parameters. Full configuration description available under [vmseries/README.md](../../modules/vmseries/README.md#input_app_insights_settings)

  NOTICE. Even if you keep this property set to `null` but set up the `autoscale_metrics` property Application Insights will be created as it is required to gather Palo Alto's autoscaling specific metrics.
  ```
  EOF
  default     = null
  type        = map(any)
}

variable "name_autoscale" {
  description = "Name of the Autoscale Settings to be created. Can be null, in which case a default name is auto-generated."
  default     = null
  type        = string
}

variable "autoscale_count_default" {
  description = "The minimum number of instances that should be present in the scale set when the autoscaling engine cannot read the metrics or is otherwise unable to compare the metrics to the thresholds."
  default     = 2
  type        = number
}

variable "autoscale_count_minimum" {
  description = "The minimum number of instances that should be present in the scale set."
  default     = 2
  type        = number
}

variable "autoscale_count_maximum" {
  description = "The maximum number of instances that should be present in the scale set."
  default     = 5
  type        = number
}

variable "autoscale_notification_emails" {
  description = "List of email addresses to notify about autoscaling events."
  default     = []
  type        = list(string)
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
}

variable "scaleout_statistic" {
  description = "Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines. Possible values are Average, Min and Max."
  default     = "Max"
  type        = string
}

variable "scaleout_time_aggregation" {
  description = "Specifies how the metric should be combined over the time `scaleout_window_minutes`. Possible values are Average, Count, Maximum, Minimum, Last and Total."
  default     = "Maximum"
  type        = string
}

variable "scaleout_window_minutes" {
  description = <<-EOF
  This is amount of time in minutes that autoscale engine will look back for metrics. For example, 10 minutes means that every time autoscale runs,
  it will query metrics for the past 10 minutes. This allows metrics to stabilize and avoids reacting to transient spikes.
  Must be between 5 and 720 minutes.
  EOF
  default     = 10
  type        = number
}

variable "scaleout_cooldown_minutes" {
  description = "Azure only considers adding a VM after this number of minutes has passed since the last VM scaling action. It should be much higher than `scaleout_window_minutes`, to account both for the VM-Series spin-up time and for the subsequent metrics stabilization time. Must be between 1 and 10080 minutes."
  default     = 25
  type        = number
}

variable "scalein_statistic" {
  description = "Aggregation to use within each minute (the time grain) for metrics coming from different virtual machines. Possible values are Average, Min and Max."
  default     = "Max"
  type        = string
}

variable "scalein_time_aggregation" {
  description = "Specifies how the metric should be combined over the time `scalein_window_minutes`. Possible values are Average, Count, Maximum, Minimum, Last and Total."
  default     = "Maximum"
  type        = string
}

variable "scalein_window_minutes" {
  description = <<-EOF
  This is amount of time in minutes that autoscale engine will look back for metrics. For example, 10 minutes means that every time autoscale runs,
  it will query metrics for the past 10 minutes. This allows metrics to stabilize and avoids reacting to transient spikes.
  Must be between 5 and 720 minutes.
  EOF
  default     = 15
  type        = number
}

variable "scalein_cooldown_minutes" {
  description = "Azure only considers deleting a VM after this number of minutes has passed since the last VM scaling action. Should be higher or equal to `scalein_window_minutes`. Must be between 1 and 10080 minutes."
  default     = 2880
  type        = number
}

variable "tags" {
  description = "Map of tags to use for all the created resources."
  default     = {}
  type        = map(string)
}

#  ---   #
# Naming #
#  ---   #

variable "name_scale_set" {
  default = "scaleset"
}

variable "name_mgmt_nic_profile" {
  default = "nic-fw-mgmt-profile"
}

variable "name_mgmt_nic_ip" {
  default = "nic-fw-mgmt"
}

variable "name_fw_mgmt_pip" {
  default = "fw-mgmt-pip"
}

variable "name_fw_public_pip" {
  default = "fw-mgmt-pip"
}

variable "name_public_nic_profile" {
  default = "nic-fw-public-profile"
}

variable "name_public_nic_ip" {
  default = "nic-fw-public"
}

variable "name_private_nic_profile" {
  default = "nic-fw-private-profile"
}

variable "name_private_nic_ip" {
  default = "nic-fw-private"
}

variable "bootstrap_options" {
  description = <<-EOF
  Bootstrap options to pass to VM-Series instance.
  
  Proper syntax is a string of semicolon separated properties.
  Example:
    bootstrap_options = "type=dhcp-client;panorama-server=1.2.3.4"

  A list of available properties: type, ip-address, default-gateway, netmask, ipv6-address, ipv6-default-gateway, hostname, panorama-server, panorama-server-2, tplname, dgname, dns-primary, dns-secondary, vm-auth-key, op-command-modes, op-cmd-dpdk-pkt-io, plugin-op-commands, dhcp-send-hostname, dhcp-send-client-id, dhcp-accept-server-hostname, dhcp-accept-server-domain, auth-key.

  For more details on bootstrapping see documentation: https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/init-cfgtxt-file-components
  EOF
  default     = ""
  type        = string
  validation {
    condition = alltrue([
      for v in var.bootstrap_options == "" ? [] : split(";", var.bootstrap_options) :
      contains(
        ["storage-account", "access-key", "file-share", "share-directory", "type", "ip-address", "default-gateway", "netmask", "ipv6-address", "ipv6-default-gateway", "hostname", "panorama-server", "panorama-server-2", "tplname", "dgname", "dns-primary", "dns-secondary", "vm-auth-key", "op-command-modes", "op-cmd-dpdk-pkt-io", "plugin-op-commands", "dhcp-send-hostname", "dhcp-send-client-id", "dhcp-accept-server-hostname", "dhcp-accept-server-domain", "auth-key", "vm-series-auto-registration-pin-value", "vm-series-auto-registration-pin-id"],
        split("=", v)[0]
      )
    ])
    error_message = "Error in validating bootstrap_options, for details see variable description."
  }
}

variable "diagnostics_storage_uri" {
  description = "The storage account's blob endpoint to hold diagnostic files."
  default     = null
  type        = any
}
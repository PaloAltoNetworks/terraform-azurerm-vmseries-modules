variable "inbound_resource_group_name" {
  description = "Name of the Resource Group to create if `create_inbound_resource_group` is true. Name of the pre-existing Resource Group to use otherwise."
  type        = string
}

variable "create_inbound_resource_group" {
  description = "If true, create a new Resource Group for inbound VM-Series. Otherwise use a pre-existing group."
  default     = true
  type        = bool
}

variable "outbound_resource_group_name" {
  description = "Name of the Resource Group to create if `create_outbound_resource_group` is true. Name of the pre-existing Resource Group to use otherwise."
  type        = string
}

variable "create_outbound_resource_group" {
  description = "If true, create a new Resource Group for outbound VM-Series. Otherwise use a pre-existing group."
  default     = true
  type        = bool
}

variable "location" {
  description = "The Azure region to use."
  default     = "Australia Central"
  type        = string
}

variable "name_prefix" {
  description = "A prefix for all the names of the created Azure objects. It can end with a dash `-` character, if your naming convention prefers such separator."
  default     = "pantf"
  type        = string
}

variable "username" {
  description = "Initial administrative username to use for all systems."
  default     = "panadmin"
  type        = string
}

variable "password" {
  description = "Initial administrative password to use for all systems. Set to null for an auto-generated password."
  default     = null
  type        = string
}

variable "storage_account_name" {
  description = <<-EOF
  Default name of the storage account to create.
  The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters.
  EOF
  default     = "pantfstorage"
  type        = string
}

variable "inbound_files" {
  description = "Map of all files to copy to `inbound_storage_share_name`. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\\`. For example `{\"dir/my.txt\" = \"config/init-cfg.txt\"}`"
  default     = {}
  type        = map(string)
}

variable "outbound_files" {
  description = "Map of all files to copy to `outbound_storage_share_name`. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\\`. For example `{\"dir/my.txt\" = \"config/init-cfg.txt\"}`"
  default     = {}
  type        = map(string)
}

variable "inbound_storage_share_name" {
  description = "Name of storage share to be created that holds `files` for bootstrapping inbound VM-Series."
  type        = string
}

variable "outbound_storage_share_name" {
  description = "Name of storage share to be created that holds `files` for bootstrapping outbound VM-Series."
  type        = string
}

variable "inbound_count_minimum" {
  description = "Minimal number of inbound VM-Series to deploy."
  default     = 1
  type        = number
}

variable "outbound_count_minimum" {
  description = "Minimal number of outbound VM-Series to deploy."
  default     = 1
  type        = number
}

variable "inbound_count_maximum" {
  description = "Maximal number of inbound VM-Series to scale out to."
  default     = 2
  type        = number
}

variable "outbound_count_maximum" {
  description = "Maximal number of outbound VM-Series to scale out to."
  default     = 2
  type        = number
}

variable "autoscale_notification_emails" {
  description = "List of email addresses to notify about autoscaling events."
  default     = []
  type        = list(string)
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

  Other possible metrics include `panSessionActive`, `panSessionThroughputKbps`, `panSessionThroughputPps`, `DataPlanePacketBufferUtilization`.
  EOF

  default = {}
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
  description = "Before each VM number increase, wait `scaleout_window_minutes` plus `scaleout_cooldown_minutes` counting from the last VM number increase."
  default     = 15
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

variable "virtual_network_name" {
  description = "Name of the Virtual Network."
  type        = string
}

variable "create_virtual_network" {
  description = "If true, create the Virtual Network, otherwise just use a pre-existing network."
  default     = true
  type        = bool
}

variable "address_space" {
  description = "The address space used by the Virtual Network. You can supply more than one address space."
  type        = list(string)
}

variable "network_security_groups" {
  description = "Map of Network Security Groups to create. Refer to the `vnet` module documentation for more information."
}

variable "allow_inbound_mgmt_ips" {
  description = <<-EOF
    List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access management interfaces of VM-Series.
    If you use Panorama, include its address in the list (as well as the secondary Panorama's).
  EOF
  default     = []
  type        = list(string)

  validation {
    condition     = length(var.allow_inbound_mgmt_ips) > 0
    error_message = "At least one address has to be specified."
  }
}

variable "allow_inbound_data_ips" {
  description = <<-EOF
    List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access public data interfaces of VM-Series.
    If the list is empty, the contents of `allow_inbound_mgmt_ips` are substituted instead.
  EOF
  default     = []
  type        = list(string)
}

variable "route_tables" {
  description = "Map of Route Tables to create. Refer to the `vnet` module documentation for more information."
}

variable "subnets" {
  description = "Map of Subnets to create. Refer to the `vnet` module documentation for more information."
}

variable "vnet_tags" {
  description = "Map of extra tags to assign specifically to the created virtual network, security groups, and route tables. The entries from `tags` are applied as well unless overriden."
  default     = {}
  type        = map(string)
}

variable "inbound_lb_name" {
  description = "Name of the public-facing load balancer."
  default     = "lb_public"
  type        = string
}

variable "outbound_lb_name" {
  description = "Name of the private load balancer."
  default     = "lb_private"
  type        = string
}

variable "olb_private_ip" {
  description = "The private IP address to assign to the outbound load balancer. This IP **must** fall in the `outbound_private` subnet CIDR."
  type        = string
}

variable "public_frontend_ips" {
  description = "Map of objects describing frontend IP configurations and rules for the inbound load balancer. Refer to the `loadbalancer` module documentation for more information."
}

variable "common_vmseries_sku" {
  description = "VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "bundle2"
  type        = string
}

variable "inbound_vmseries_version" {
  description = "Inbound VM-series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "10.1.0"
  type        = string
}

variable "inbound_vmseries_vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported."
  default     = "Standard_D3_v2"
  type        = string
}

variable "inbound_vmseries_tags" {
  description = "Map of tags to be associated with the inbound virtual machines, their interfaces and public IP addresses."
  default     = {}
  type        = map(string)
}

variable "outbound_vmseries_version" {
  description = "Outbound VM-series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "10.1.0"
  type        = string
}

variable "outbound_vmseries_vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported."
  default     = "Standard_D3_v2"
  type        = string
}

variable "outbound_vmseries_tags" {
  description = "Map of tags to be associated with the outbound virtual machines, their interfaces and public IP addresses."
  default     = {}
  type        = map(string)
}

variable "enable_zones" {
  description = "If true, Public IP addresses will have `Zone-Redundant` setting, otherwise `No-Zone`. The latter is intended for the regions that do not yet support Availability Zones."
  default     = true
  type        = bool
}

variable "name_scale_set" {
  description = "Name of the virtual machine scale set."
  default     = "VMSS"
  type        = string
}

variable "inbound_name_prefix" {
  type = string
}

variable "outbound_name_prefix" {
  type = string
}

variable "panorama_tags" {
  description = "Predefined tags neccessary for the Panorama `azure` plugin v2 to automatically de-license the VM-Series. Can be set to empty `{}` when version v2 de-licensing is not used."
  default = {
    PanoramaManaged = "yes"
  }
  type = map(string)
}

variable "tags" {
  description = "Azure tags to apply to the created cloud resources. A map, for example `{ team = \"NetAdmin\", costcenter = \"CIO42\" }`"
  default     = {}
  type        = map(string)
}

variable "avzones" {
  description = <<-EOF
  After provider version 3.x you need to specify in which availability zone(s) you want to place IP.
  ie: for zone-redundant with 3 availability zone in current region value will be:
  ```["1","2","3"]```
  Use command ```az vm list-skus --location REGION_NAME --zone --query '[0].locationInfo[0].zones'``` to see how many AZ is
  in current region.
  EOF
  default     = []
  type        = list(string)
}

variable "app_insights_settings" {
  description = "A map of the Application Insights related parameters. Full description available under [vmseries/README.md](../../modules/vmseries/README.md#input_app_insights_settings)"
  default     = null
  type        = map(any)
}
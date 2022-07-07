variable "location" {
  description = "Region where to deploy VM-Series and dependencies."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group where to place the resources created."
  type        = string
}

variable "name" {
  description = "VM-Series instance name."
  type        = string
}

variable "enable_zones" {
  description = "If false, the input `avzone` is ignored and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones."
  default     = true
  type        = bool
}

variable "avzone" {
  description = "The availability zone to use, for example \"1\", \"2\", \"3\". Ignored if `enable_zones` is false. Conflicts with `avset_id`, in which case use `avzone = null`."
  default     = "1"
  type        = string
}

variable "avset_id" {
  description = "The identifier of the Availability Set to use. When using this variable, set `avzone = null`."
  default     = null
  type        = string
}

variable "interfaces" {
  description = <<-EOF
  List of the network interface specifications.
  The first should be the management interface, which does not participate in data filtering.
  The remaining ones are the dataplane interfaces.
  Options for an interface object:
  - `name`                 - (required|string) Interface name.
  - `subnet_id`            - (required|string) Identifier of an existing subnet to create interface in.
  - `private_ip_address`   - (optional|string) Static private IP to asssign to the interface. If null, dynamic one is allocated.
  - `public_ip_address_id` - (optional|string) Identifier of an existing public IP to associate.
  - `create_public_ip`     - (optional|bool) If true, create a public IP for the interface and ignore the `public_ip_address_id`. Default is false.
  - `availability_zone`    - (optional|string) Availability zone to create public IP in. If not specified, set based on `avzone` and `enable_zones`.
  - `enable_ip_forwarding` - (optional|bool) If true, the network interface will not discard packets sent to an IP address other than the one assigned. If false, the network interface only accepts traffic destined to its IP address.
  - `enable_backend_pool`  - (optional|bool) If true, associate interface with backend pool specified with `lb_backend_pool_id`. Default is false.
  - `lb_backend_pool_id`   - (optional|string) Identifier of an existing backend pool to associate interface with. Required if `enable_backend_pool` is true.
  - `tags`                 - (optional|map) Tags to assign to the interface and public IP (if created). Overrides contents of `tags` variable.

  Example:

  ```
  [
    {
      name                 = "fw-mgmt"
      subnet_id            = azurerm_subnet.my_mgmt_subnet.id
      public_ip_address_id = azurerm_public_ip.my_mgmt_ip.id
    },
    {
      name                = "fw-public"
      subnet_id           = azurerm_subnet.my_pub_subnet.id
      lb_backend_pool_id  = module.inbound_lb.backend_pool_id
      enable_backend_pool = true
    },
  ]
  ```

  EOF
  type        = list(any)
}

variable "username" {
  description = "Initial administrative username to use for VM-Series. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-username-requirements-when-creating-a-vm)."
  type        = string
}

variable "password" {
  description = "Initial administrative password to use for VM-Series. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm)."
  type        = string
}

variable "managed_disk_type" {
  description = "Type of OS Managed Disk to create for the virtual machine. Possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`. The `Premium_LRS` works only for selected `vm_size` values, details in Azure docs."
  default     = "StandardSSD_LRS"
  type        = string
}

variable "os_disk_name" {
  description = "Optional name of the OS disk to create for the virtual machine. If empty, the name is auto-generated."
  default     = null
  type        = string
}

variable "vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported."
  default     = "Standard_D3_v2"
  type        = string
}

variable "custom_image_id" {
  description = "Absolute ID of your own Custom Image to be used for creating new VM-Series. If set, the `username`, `password`, `img_version`, `img_publisher`, `img_offer`, `img_sku` inputs are all ignored (these are used only for published images, not custom ones). The Custom Image is expected to contain PAN-OS software."
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
  description = "VM-series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "bundle2"
  type        = string
}

variable "img_version" {
  description = "VM-series PAN-OS version - list available for a default `img_offer` with `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all`"
  default     = "10.1.0"
  type        = string
}

variable "name_application_insights" {
  default     = null
  description = "Name of the Applications Insights instance to be created. Can be `null`, in which case a default name is auto-generated."
  type        = string
}

variable "tags" {
  description = "A map of tags to be associated with the resources created."
  default     = {}
  type        = map(any)
}

variable "identity_type" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine#identity_type)."
  default     = "SystemAssigned"
  type        = string
}

variable "identity_ids" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine#identity_ids)."
  default     = null
  type        = list(string)
}

variable "metrics_retention_in_days" {
  description = "Specifies the retention period in days. Possible values are 0, 30, 60, 90, 120, 180, 270, 365, 550 or 730. Defaults to 90. A special value 0 disables creation of Application Insights altogether."
  default     = null
  type        = number
}

variable "accelerated_networking" {
  description = "Enable Azure accelerated networking (SR-IOV) for all network interfaces except the primary one (it is the PAN-OS management interface, which [does not support](https://docs.paloaltonetworks.com/pan-os/9-0/pan-os-new-features/virtualization-features/support-for-azure-accelerated-networking-sriov) acceleration)."
  default     = true
  type        = bool
}

variable "bootstrap_options" {
  description = "Bootstrap options to pass to VM-Series instance."
  default     = ""
  type        = string
}

variable "diagnostics_storage_uri" {
  description = "The storage account's blob endpoint to hold diagnostic files."
  default     = null
  type        = string
}

variable "avzones" {
  description = <<-EOF
  After provider version 3.x you need to specify in which availability zone(s) you want to place IP.
  ie: for zone-redundant with 3 availability zone in current region value will be:
  ```["1","2","3"]```
  EOF
  default     = []
  type        = list(string)
}
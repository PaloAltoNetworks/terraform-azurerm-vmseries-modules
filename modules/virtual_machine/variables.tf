variable "location" {
  description = "Region where to deploy and dependencies."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group where to place the resources created."
  type        = string
}

variable "name" {
  description = "Virtual machine instance name."
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

variable "avzones" {
  description = <<-EOF
  After provider version 3.x you need to specify in which availability zone(s) you want to place IP.
  ie: for zone-redundant with 3 availability zone in current region value will be:
  ```["1","2","3"]```
  EOF
  default     = []
  type        = list(string)
}

variable "avset_id" {
  description = "The identifier of the Availability Set to use. When using this variable, set `avzone = null`."
  default     = null
  type        = string
}

variable "interfaces" {
  description = <<-EOF
  List of the network interface specifications.
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
      name                 = "mgmt"
      subnet_id            = azurerm_subnet.my_mgmt_subnet.id
      public_ip_address_id = azurerm_public_ip.my_mgmt_ip.id
    },
    {
      name                = "public"
      subnet_id           = azurerm_subnet.my_pub_subnet.id
      lb_backend_pool_id  = module.inbound_lb.backend_pool_id
      enable_backend_pool = true
    },
  ]
  ```

  EOF
}

variable "bootstrap_storage_account" {
  description = "Existing storage account object for bootstrapping and for holding small-sized boot diagnostics. Usually the object is passed from a bootstrap module's output."
  default     = null
  type        = any
}

variable "bootstrap_share_name" {
  description = "Azure File Share holding the bootstrap data. Should reside on `bootstrap_storage_account`. Bootstrapping is omitted if `bootstrap_share_name` is left at null."
  default     = null
  type        = string
}

variable "username" {
  description = "Initial administrative username to use for the virtual machine. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-username-requirements-when-creating-a-vm)."
  type        = string
}

variable "password" {
  description = "Initial administrative password to use for the virtual machine. If not defined the `ssh_key` variable must be specified. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm)."
  default     = null
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
  description = "Azure VM size (type) to be created."
  default     = "Standard_D3_v2"
  type        = string
}

variable "custom_image_id" {
  description = "Absolute ID of your own Custom Image to be used for creating a new virtual machine. If set, the `username`, `password`, `img_version`, `img_publisher`, `img_offer`, `img_sku` inputs are all ignored (these are used only for published images, not custom ones)."
  default     = null
  type        = string
}

variable "img_publisher" {
  description = "The Azure Publisher identifier for a image which should be deployed."
  default     = null
  type        = string
}

variable "img_offer" {
  description = "The Azure Offer identifier corresponding to a published image."
  default     = null
  type        = string
}

variable "img_sku" {
  description = "Virtual machine image SKU - list available with `az vm image list -o table --all --publisher foo`"
  default     = null
  type        = string
}

variable "img_version" {
  description = "Virtual machine image version - list available for a default `img_offer` with `az vm image list -o table --publisher foo --offer bar --all`"
  default     = "latest"
  type        = string
}

variable "enable_plan" {
  description = "Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku \"byol\", which means \"bring your own license\", still requires accepting on the Marketplace (as of 2021). Can be set to `false` when using a custom image."
  default     = false
  type        = bool
}

variable "vm_os_simple" {
  description = "Allows user to specify a simple name for the OS required and auto populate the publisher, offer, sku parameters"
  default     = "UbuntuServer"
  type        = string
}


variable "standard_os" {
  description = <<-EOF
  Definition of the standard OS with "SimpleName" = "publisher,offer,sku"
  EOF
  default = {
    "UbuntuServer"  = "Canonical,UbuntuServer,18.04-LTS"
    "RHEL"          = "RedHat,RHEL,8.2"
    "openSUSE-Leap" = "SUSE,openSUSE-Leap,15.1"
    "CentOS"        = "OpenLogic,CentOS,7.6"
    "Debian"        = "credativ,Debian,9"
    "CoreOS"        = "CoreOS,CoreOS,Stable"
    "SLES"          = "SUSE,SLES,12-SP2"
  }
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

variable "accelerated_networking" {
  description = "Enable Azure accelerated networking (SR-IOV) for all network interfaces"
  default     = true
  type        = bool
}

variable "custom_data" {
  description = "The custom data to supply to the machine. This can be used as a cloud-init for Linux systems."
  type        = string
  default     = null
}

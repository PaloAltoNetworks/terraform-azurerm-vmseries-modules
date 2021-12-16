variable "location" {
  description = "Region where to deploy and dependencies."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group where to place the resources created."
  type        = string
}

variable "name" {
  description = "Hostname of the virtual machine."
  default     = "fw00"
  type        = string
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
  The first should be the Management network interface, which does not participate in data filtering.
  The remaining ones are the dataplane interfaces.

  - `subnet_id`: Identifier of the existing subnet to use.
  - `lb_backend_pool_id`: Identifier of the existing backend pool of the load balancer to associate.
  - `enable_backend_pool`: If false, ignore `lb_backend_pool_id`. Default is false.
  - `public_ip_address_id`: Identifier of the existing public IP to associate.
  - `create_public_ip`: If true, create a public IP for the interface and ignore the `public_ip_address_id`. Default is false.

  Example:

  ```
  [
    {
      subnet_id            = azurerm_subnet.my_mgmt_subnet.id
      public_ip_address_id = azurerm_public_ip.my_mgmt_ip.id
    },
    {
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
  description = "Initial administrative password to use for the virtual machine. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm)."
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
  default     = null
  type        = string
}

variable "vm_os_simple" {
  description = "Allows user to specify a simple name for the OS required and auto populate the publisher, offer, sku parameters"
  default     = null
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

variable "enable_zones" {
  description = "If false, the input `avzone` is ignored and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones."
  default     = true
  type        = bool
}

# Location
variable "location" {
  description = "Region to deploy Panorama into."
  type        = string
}

variable "enable_zones" {
  description = "If false, the input `avzone` is ignored and all created public IPs default not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones."
  default     = true
  type        = bool
}

variable "avzone" {
  description = "The availability zone to use, for example \"1\", \"2\", \"3\". Ignored if `enable_zones` is false. Use `avzone = null` to disable the use of Availability Zones."
  default     = null
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

# Naming
variable "name" {
  description = "The Panorama common name."
  type        = string
}

variable "os_disk_name" {
  description = "The name of OS disk. The name is auto-generated when not provided."
  default     = null
  type        = string
}
variable "resource_group_name" {
  description = "The name of the existing resource group where to place all the resources created by this module."
  type        = string
}

# Instance settings
variable "panorama_size" {
  description = "Virtual Machine size."
  default     = "Standard_D5_v2"
}

variable "username" {
  description = "Initial administrative username to use for Panorama. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-username-requirements-when-creating-a-vm)."
  default     = "panadmin"
  type        = string
}

variable "password" {
  description = "Initial administrative password to use for Panorama. If not defined the `ssh_key` variable must be specified. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm)."
  default     = null
  type        = string
  sensitive   = true
}

variable "ssh_keys" {
  description = <<-EOF
  A list of initial administrative SSH public keys that allow key-pair authentication.
  
  This is a list of strings, so each item should be the actual public key value. If you would like to load them from files instead, following method is available:

  ```
  [
    file("/path/to/public/keys/key_1.pub"),
    file("/path/to/public/keys/key_2.pub")
  ]
  ```
  
  If the `password` variable is also set, VM-Series will accept both authentication methods.
  EOF
  default     = []
  type        = list(string)
}

variable "enable_plan" {
  description = "Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku \"byol\", which means \"bring your own license\", still requires accepting on the Marketplace (as of 2021). Can be set to `false` when using a custom image."
  default     = true
  type        = bool
}

variable "panorama_disk_type" {
  description = "Specifies the type of managed disk to create. Possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS or UltraSSD_LRS."
  default     = "StandardSSD_LRS"
  type        = string

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "UltraSSD_LRS"], var.panorama_disk_type)
    error_message = "Panorama disk type need to be one of list Standard_LR, StandardSSD_LRS, Premium_LRS, UltraSSD_LRS."
  }
}

variable "panorama_sku" {
  description = "Panorama SKU."
  default     = "byol"
  type        = string
}

variable "panorama_version" {
  description = "Panorama PAN-OS Software version. List published images with `az vm image list -o table --all --publisher paloaltonetworks --offer panorama`"
  default     = "10.0.3"
  type        = string
}

variable "panorama_publisher" {
  description = "Panorama Publisher."
  default     = "paloaltonetworks"
  type        = string
}

variable "panorama_offer" {
  description = "Panorama offer."
  default     = "panorama"
  type        = string
}

variable "custom_image_id" {
  description = "Absolute ID of your own Custom Image to be used for creating Panorama. If set, the `username`, `password`, `panorama_version`, `panorama_publisher`, `panorama_offer`, `panorama_sku` inputs are all ignored (these are used only for published images, not custom ones). The Custom Image is expected to contain PAN-OS software."
  default     = null
  type        = string
}

# Networking
variable "interfaces" {
  description = <<-EOF
  List of the network interface specifications.

  NOTICE. The ORDER in which you specify the interfaces DOES MATTER.
  Interfaces will be attached to VM in the order you define here, therefore the first should be the management interface.
  
  Options for an interface object:
  - `name`                     - (required|string) Interface name.
  - `subnet_id`                - (required|string) Identifier of an existing subnet to create interface in.
  - `create_public_ip`         - (optional|bool) If true, create a public IP for the interface and ignore the `public_ip_address_id`. Default is false.
  - `private_ip_address`       - (optional|string) Static private IP to asssign to the interface. If null, dynamic one is allocated.
  - `public_ip_name`           - (optional|string) Name of an existing public IP to associate to the interface, used only when `create_public_ip` is `false`.
  - `public_ip_resource_group` - (optional|string) Name of a Resource Group that contains public IP resource to associate to the interface. When not specified defaults to `var.resource_group_name`. Used only when `create_public_ip` is `false`.

  Example:

  ```
  [
    {
      name                 = "mgmt"
      subnet_id            = azurerm_subnet.my_mgmt_subnet.id
      public_ip_address_id = azurerm_public_ip.my_mgmt_ip.id
      create_public_ip     = true
    }
  ]
  ```
  EOF
  type        = list(any)
}

# Storage
variable "logging_disks" {
  description = <<-EOF
   A map of objects describing the additional disk configuration. The keys of the map are the names and values are { size, zone, lun }. 
   The size value is provided in GB. The recommended size for additional (optional) disks is at least 2TB (2048 GB). Example:

  ```
  {
    logs-1 = {
      size: "2048"
      zone: "1"
      lun: "1"
    }
    logs-2 = {
      size: "2048"
      zone: "2"
      lun: "2"
      disk_type: "StandardSSD_LRS"
    }
  }
  ```

  EOF
  default     = {}
  type        = map(any)
}


variable "boot_diagnostic_storage_uri" {
  description = "Existing diagnostic storage uri"
  default     = null
  type        = string
}

variable "tags" {
  description = "A map of tags to be associated with the resources created."
  default     = {}
  type        = map(any)
}

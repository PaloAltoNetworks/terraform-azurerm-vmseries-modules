variable "location" {
  description = "Region to deploy Panorama into. If not provided location will be taken from Resource Group."
  default     = ""
}

variable "resource_group_name" {
  type        = string
  description = "The existing resource group name for Panorama."
}

variable "avzone" {
  default     = null
  description = "Optional Availability Zone number."
}

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
  description = "Initial administrative password to use for Panorama. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm)."
  type        = string
}

variable "enable_plan" {
  description = "Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku \"byol\", which means \"bring your own license\", still requires accepting on the Marketplace (as of 2021). Can be set to `false` when using a custom image."
  default     = true
  type        = bool
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

variable "interface" {
  description = <<-EOF
  A array of map describing the intefaces configuration. Keys of the map are the names and values are { subnet_id, private_ip_address, public_ip, enable_ip_forwarding }. Example:
  ```
  [ // Only one interface in Panorama VM is supported 
    {
      name                 = "mgmt"
      subnet_id            = ""
      private_ip_address   = ""         // Optional: If not set, use dynamic allocation
      public_ip            = "true"     // (optional|bool, default: "false")
      public_ip_name       = ""         // (optional|string, default: "")
      enable_ip_forwarding = "false"    // (optional|bool, default: "false")
      primary_interface    = "true"
    }
  ]
  ```
  EOF
}

variable "logging_disks" {
  type        = map(any)
  default     = {}
  description = <<-EOF
   A map of objects describing the additional disk configuration. The keys of the map are the names and values are { size, zones, lun }. 
   The size value is provided in GB. The recommended size for additional(optional) disks should be at least 2TB (2048 GB). Example:
  ```
  {
    disk_name_1 = {
      size: "2048"
      zone: "1"
      lun: "1"
    }
    disk_name_2 = {
      size: "2048"
      zone: "2"
      lun: "2"
    }
  }
  ```
  EOF
}

variable "custom_image_id" {
  type    = string
  default = null
}

variable "boot_diagnostic_storage_uri" {
  description = "Existing diagnostic storage uri"
  default     = null
}

#  ---   #
# Naming #
#  ---   #

variable "panorama_name" {
  description = "The Panorama common name."
  default     = "panorama"
}

variable "os_disk_name" {
  description = "The suffix for disk name."
  default     = null
  type        = string
}

variable "tags" {
  description = "A map of tags to be associated with the resources created."
  default     = {}
  type        = map(any)
}

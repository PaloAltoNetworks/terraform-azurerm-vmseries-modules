variable "location" {
  description = "Region to deploy panorama into."
  default     = ""
}

variable "resource_group_name" {
  type        = string
  description = "The resource group name created for Panorama."
}

variable "avzone" {
  default     = null
  description = "Optional Availability Zone number."
}

variable "name_prefix" {
  description = "Prefix to add to all the object names here."
}

variable "panorama_size" {
  description = "Virtual Machine size."
  default     = "Standard_D5_v2"
}

variable "primary_interface" {
  description = "The key name from interfaces variable indicates primary interface."
  default     = "mgmt"
}

variable "username" {
  description = "Initial administrative username to use for Panorama."
  default     = "panadmin"
  type        = string
}

variable "password" {
  description = "Initial administrative password to use for Panorama."
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

variable "interfaces" {
  type        = map(any)
  description = <<-EOF
  A map of objects describing the intefaces configuration. Keys of the map are the names and values are { subnet_id, private_ip_address, public_ip, enable_ip_forwarding }. Example:
  ```
  {
    public = {
      subnet_id: module.vnet.vnet_subnets[0]
      private_ip_address: "10.0.0.6" // Optional: If not set, use dynamic allocation.
      public_ip: true // (optional|bool, default: "false")
      enable_ip_forwarding: "false" // (optional|bool, default: "false")
    }
    mgmt = {
      subnet_id: module.vnet.vnet_subnets[1]
      private_ip_address: "10.0.1.6" // Optional: If not set, use dynamic allocation.
      public_ip: false // (optional|bool, default: "false")
      enable_ip_forwarding: "false" // (optional|bool, default: "false")
    }
  }
  ```
  EOF
}

variable "logging_disks" {
  type        = map(any)
  default     = {}
  description = <<-EOF
  A map of objects describing the additional disks configuration. Keys of the map are the names and values are { size, zones, lun }. Example:
  ```
  {
    disk_name_1 = {
      size: "50"
      zone: "1"
      lun: "1"
    }
    disk_name_2 = {
      size: "50"
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

#  ---   #
# Naming #
#  ---   #

variable "sep" {
  default     = "-"
  description = "Separator used in the names of the generated resources. May be empty."
}

variable "name_panorama_pip" {
  description = "The name for public ip allows distinguish from other type of public ips."
  default     = "panorama-pip"
}

variable "panorama_name" {
  description = "The Panorama common name."
  default     = "panorama"
}

variable "tags" {
  description = "A map of tags to be associated with the resources created."
  default     = {}
  type        = map(any)
}

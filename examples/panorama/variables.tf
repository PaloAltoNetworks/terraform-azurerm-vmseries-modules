variable "location" {
  description = "Region to deploy Panorama into."
  default     = ""
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group to create."
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

variable "management_ips" {
  description = "A map where the keys are the IP addresses or ranges that are permitted to access the out-of-band management interfaces belonging to firewalls and Panorama devices. The map's values are priorities, integers in the range 102-60000 inclusive. All priorities should be unique."
  type        = map(number)
}

variable "panorama_name" {
  type    = string
  default = "panorama"
}

variable "panorama_size" {
  type    = string
  default = "Standard_D5_v2"
}

variable "custom_image_id" {
  type    = string
  default = null
}

variable "username" {
  description = "Initial administrative username to use for Panorama. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-username-requirements-when-creating-a-vm)."
  type        = string
  default     = "panadmin"
}

variable "panorama_sku" {
  type    = string
  default = "byol"
}

variable "panorama_version" {
  type    = string
  default = "10.0.3"
}

variable "subnet_names" {
  type    = list(string)
  default = ["subnet1"]
}

variable "subnet_prefixes" {
  type    = list(string)
  default = ["10.0.0.0/24"]
}

variable "panorama_private_ip_address" {
  description = "Optional static private IP address of Panorama, for example 192.168.11.22. If empty, Panorama uses dynamic assignment."
  type        = string
  default     = null
}

variable "vnet_name" {
  type = string
}

variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "tags" {
  type = map(string)
}

variable "firewall_mgmt_prefixes" {
  type    = list(string)
  default = ["10.0.0.0/24"]
}

variable "security_group_name" {
  type    = string
  default = "nsg-panorama"
}

variable "avzone" {
  description = "The availability zone to use, for example \"1\", \"2\", \"3\". Ignored if `enable_zones` is false. Use `avzone = null` to disable the use of Availability Zones."
  type        = string
  default     = null
}

variable "enable_zones" {
  description = "If false, the input `avzone` is ignored and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones."
  default     = true
  type        = bool
}

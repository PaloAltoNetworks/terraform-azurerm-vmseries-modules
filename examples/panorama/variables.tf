variable "location" {
  description = "Region to deploy Panorama into. If not provided location will be taken from Resource Group."
  default     = ""
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group to use."
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

variable "files" {
  description = "Map of all files to copy to bucket. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\\`. For example `{\"dir/my.txt\" = \"config/init-cfg.txt\"}`"
  default     = {}
  type        = map(string)
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
  type    = list
  default = ["subnet1"]
}

variable "subnet_prefixes" {
  type    = list
  default = ["10.0.0.0/24"]
}

variable "vnet_name" {
  type = string
}

variable "address_space" {
  type    = list
  default = ["10.0.0.0/16"]
}

variable "tags" {
  type = map(any)
}

variable "firewall_mgmt_prefixes" {
  type    = list
  default = ["10.0.0.0/24"]
}

variable "security_group_name" {
  type    = string
  default = "nsg-panorama"
}

variable "avzone" {
  type    = string
  default = null
}

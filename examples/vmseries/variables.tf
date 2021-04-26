variable "location" {
  description = "The Azure region to use."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group to create."
  type        = string
}

variable "username" {
  description = "Initial administrative username. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-username-requirements-when-creating-a-vm)."
  type        = string
}

variable "allow_inbound_mgmt_ips" {
  description = "List of IP CIDR ranges (like `[\"23.23.23.23\"]`) that are allowed to access management interfaces of VM-Series."
  type        = list(string)
}

variable "common_vmseries_sku" {
  description = "VM-series SKU, for example `bundle1` or `bundle2`. Do not use byol for this example as there is no way to supply `authcodes`."
  type        = string
}

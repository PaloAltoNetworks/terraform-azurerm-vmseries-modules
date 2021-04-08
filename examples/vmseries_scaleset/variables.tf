variable "resource_group_name" {
  description = "Name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "The Azure region to use."
  default     = "Australia Central"
  type        = string
}

variable "name_prefix" {
  description = "A prefix for all naming conventions - used globally"
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

variable "files" {
  description = "Map of all files to copy to bucket. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\\`. For example `{\"dir/my.txt\" = \"config/init-cfg.txt\"}`"
  default     = {}
  type        = map(string)
}

variable "frontend_ips" {
  description = "A map of objects describing LB Frontend IP configurations and rules. See the module's documentation for details."
}

variable "vmseries_count" {
  description = "Total number of VM series to deploy per direction (inbound/outbound)."
  default     = 1
}

variable "virtual_network_name" {
  description = "Name of the Virtual Network to create."
  type = string
}

variable "address_space" {
  description = "The address space used by the virtual network. You can supply more than one address space."
  type        = list(string)
}

variable "network_security_groups" {
  description = "A map of Network Security Groups objects to create."
  type        = map
}

variable "route_tables" {
  description = "A map of objects describing a Route Table."
  type        = map
}

variable "subnets" {
  description = "A map of subnet objects to create within a Virtual Network."
  type        = map
}

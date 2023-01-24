variable "resource_group_name" {
  description = "Name of the Resource Group to create."
  type        = string
}

variable "location" {
  description = "Region to deploy the bootstrap resources into."
  type        = string
}

variable "storage_account_name" {
  description = <<-EOF
  Name of the Storage Account to create.
  The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length and may include only numbers and lowercase letters.
  EOF
  type        = string
}

variable "inbound_storage_share_name" {
  description = "Name of Storage Share that will host files for bootstrapping a firewall protecting inbound traffic."
  type        = string
}

variable "obew_storage_share_name" {
  description = "Name of Storage Share that will host files for bootstrapping a firewall protecting OBEW traffic."
  type        = string
}

variable "inbound_files" {
  description = <<-EOF
  Map of all files to copy to a File Share. This represents files for inbound firewall.
  
  The keys are local paths, values - remote paths. Always use slash `/` as directory separator (unix-like).
  EOF
  default     = {}
  type        = map(string)
}

variable "obew_files" {
  description = <<-EOF
  Map of all files to copy to a File Share. This represents files for OBEW firewall.

  The keys are local paths, values - remote paths. Always use slash `/` as directory separator (unix-like).
  EOF
  default     = {}
  type        = map(string)
}

variable "retention_policy_days" {
  description = "Log retention policy in days"
  type        = number
}

variable "storage_allow_inbound_public_ips" {
  description = <<-EOF
    List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access the storage.
    Only public IPs are allowed - RFC1918 address space is not permitted.
    Remember to include the IP address you are running terraform from.
  EOF
  type        = list(string)
  default     = null
}

variable "storage_acl" {
  description = "If `true`, storage account network rules will be activated with Deny default statement."
  type        = bool
}
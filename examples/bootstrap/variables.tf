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

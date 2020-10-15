variable storage_account_name {
  type = string
}

variable resource_group_name {
  description = "Name of the Resource Group where bootstrap resources will be deployed"
  type        = string
}

variable location {
  type = string
}

variable storage_account_replication_type {
  description = "Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
  type        = string
  default     = "LRS"
}

variable config_dirs {
  description = "List of directories required to bootstrap firewalls"
  type        = list(string)
  default     = ["config", "license", "content", "software"]
}

variable config_files {
  description = "List of config files uploaded to storage and required for vmseries firewalls to bootstrap"
  default = {
    "authcodes" = {
      path = "license"
    }
    "init-cfg.txt" = {
      path = "config"
    }
  }
}

variable file_share_name {
  description = "Name of the file share inside storage account"
  type        = string
  default     = "bootstrap"
}

variable bootstrap_files_dir {
  description = "Directory where bootstrap files are kept on the local filesystem"
  type        = string
}

variable "root_directory" {
  description = "Name of the root storage share directory in the bucket"
  type        = string
  default     = "firewalls"
}

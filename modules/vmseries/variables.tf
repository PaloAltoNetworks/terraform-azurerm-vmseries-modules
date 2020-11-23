variable resource_group {
    type = string
}

variable region {
    type = string
}

variable firewall_vm_size {
    description = "VM size for vmseries firewalls"
    type = string
    default = "Standard_A4_v2"
}



# Variables related to Availability Set
variable avsetname {
    description = "Name of the availability set for vmseries firewalls"
    type = string
}

//variable avset_managed {
//    description = "Specifies whether the availability set is managed or not. Possible values are true (to specify aligned) or false (to specify classic). Default is true."
//    type = bool
//    default = false // According to "Azure Transit VNet (Common FW)", page 23
//}
//
//variable avset_update_count {
//    description = "Specifies the number of update domains that are used."
//    type = number
//    default = 5
//}
//
//variable avset_fault_count {
//    description = "Specifies the number of fault domains that are used."
//    type = number
//    default = 3
//}



#####

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  default     = "azneuresgpp123401"
}

//variable "location" {
//  description = "Location name of the Azure region"
//  default     = "NorthEurope"
//}


variable "platform_update_domain_count" {
  description = "(Optional) Specifies the number of update domains that are used"
  default     = 5
}

variable "platform_fault_domain_count" {
  description = "(Optional) Specifies the number of fault domains that are used."
  default     = 3
}

variable "managed" {
  default = true
}

variable "firewalls" {
  default = []
}

//variable "network_security_group_name" {
//}

variable "private_ip_address_allocation" {
  default = "Dynamic"
}

//variable "private_ip_address" {
//  default =
//}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  default     = "terraform_compute"
}

variable "fw_size" {
  default = "Standard_D4_v2"
}

variable "vm_publisher" {
  default = "paloaltonetworks"
}

variable "fw_sku" {
  default = "byol"
}

variable "vm_series" {
  default = "vmseries1"
}

variable "fw_version" {
  # Latest / 8.1.0 / 8.0.0 / 7.1.1
  default = "9.1.0"
}

variable "managed_disk_prefix" {
  description = "Prefix to be used for managed disks"
  default     = "-disk"
}

variable "os_disk_type" {
  description = "Specify the disk type"
  default     = "Standard_LRS"
}

variable "admin_username" {
  default = "fwadmin"
}

variable "admin_password" {
  default = "Paloalto1234!"
}

variable "tags" {
  description = "A map of tags to be associated with the resources created"
  type        = map
  default = {
    Owner = "PS"
    Org   = "PANW"
  }
}

variable "bootstrap_storage_account" {
  description = "Storage account name where the bootstrap bucket is stroed"
  default     = ""
}

variable "bootstrap_storage_share" {
  description = "Storage share name where the bootstrap bucket is stroed"
  default     = ""
}

variable "bootstrap_storage_account_access_key" {
  description = "Access key to access the storage account where the bootstrap bucket is stored"
  default     = ""
}

variable "primary_blob_endpoint" {
  default = ""
}

variable "subnet" {}

variable "avsetid" {
  default = ""
}

variable "nsg_id" {
  default = ""
}

variable "enable_accelerated_networking" {
  default = "true"
}

variable "rg_nsg" {
  default = "test"
}

//variable "interface_id" {}


##### FIX NEEDED##########
//variable "nsg" {
//  default = [
//      {
//        name = "allow_all_x"
//        resource_group_name = "A1"
//        rules = [
//          {
//            name = "Deafult-Allow-Any_x"
//            priority = 100
//            direction = "Inbound"
//            access = "Allow"
//            protocol = "*"
//            source_port_range = "*"
//            destination_port_range = "*"
//            source_address_prefix = "*"
//            destination_address_prefix = "*"
//          }]
//      },
//      {
//        name = "mgmt_x"
//        rules = [
//          {
//            name = "https_x"
//            priority = 200
//            direction = "Inbound"
//            access = "Allow"
//            protocol = "Tcp"
//            source_port_range = "*"
//            destination_port_range = "443"
//            source_address_prefix = "*"
//            destination_address_prefix = "*"
//          },
//          {
//            name = "ssh_x"
//            priority = 100
//            direction = "Inbound"
//            access = "Allow"
//            protocol = "Tcp"
//            source_port_range = "*"
//            destination_port_range = "22"
//            source_address_prefix = "*"
//            destination_address_prefix = "*"
//          }]
//      }]
//  }
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

variable "network_security_groups" {
  description = <<-EOF
  Map of Network Security Groups to create. The key of each entry acts as the Network Security Group name.
  List of available attributes of each Network Security Group entry:
  - `location` : (Optional) Specifies the Azure location where to deploy the resource.
  - `rules`: A list of objects representing a Network Security Rule. The key of each entry acts as the name of the rule and
      needs to be unique across all rules in the Network Security Group.
      List of attributes available to define a Network Security Rule:
      - `priority` : Numeric priority of the rule. The value can be between 100 and 4096 and must be unique for each rule in the collection.
      The lower the priority number, the higher the priority of the rule.
      - `direction` : The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are `Inbound` and `Outbound`.
      - `access` : Specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`.
      - `protocol` : Network protocol this rule applies to. Possible values include `Tcp`, `Udp`, `Icmp`, or `*` (which matches all).
      - `source_port_range` : List of source ports or port ranges.
      - `destination_port_range` : Destination Port or Range. Integer or range between `0` and `65535` or `*` to match any.
      - `source_address_prefix` : List of source address prefixes. Tags may not be used.
      - `destination_address_prefix` : CIDR or destination IP range or `*` to match any IP.

  Example:
  ```
  {
    "network_security_group_1" = {
      location = "Australia Central"
      rules = {
        "AllOutbound" = {
          priority                   = 100
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        "AllowSSH" = {
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }
    },
    "network_security_group_2" = {
      rules = {}
    }
  }
  ```
  EOF
}

variable "allow_inbound_mgmt_ips" {
  description = <<-EOF
    List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access management interfaces of VM-Series.
    If you use Panorama, include its address in the list (as well as the secondary Panorama's).
  EOF
  type        = list(string)
}

variable "subnets" {
  description = <<-EOF
  Map of subnet objects to create within a virtual network. The key of each entry acts as the subnet name.
  List of available attributes of each subnet entry:
  - `address_prefixes` : The address prefix to use for the subnet.
  - `network_security_group_id` : The Network Security Group identifier to associate with the subnet.
  - `route_table_id` : The Route Table identifier to associate with the subnet.
  - `tags` : (Optional) Map of tags to assign to the resource.

  Example:
  ```
  {
    "management" = {
      address_prefixes       = ["10.100.0.0/24"]
      network_security_group = "network_security_group_1"
      route_table            = "route_table_1"
    },
    "private" = {
      address_prefixes       = ["10.100.1.0/24"]
      network_security_group = "network_security_group_2"
      route_table            = "route_table_2"
    },
    "public" = {
      address_prefixes       = ["10.100.2.0/24"]
      network_security_group = "network_security_group_3"
      route_table            = "route_table_3"
    },
  }
  ```
  EOF
}

variable "avzones" {
  description = <<-EOF
  For better understanding this variable check description in module: ../modules/panorama/variables.tf
  You can use command in terminal ```az vm list-skus --location REGION_NAME --zone --query '[0].locationInfo[0].zones'```
  to check how many zones are available in your region.
  EOF
  default     = []
  type        = list(string)
}
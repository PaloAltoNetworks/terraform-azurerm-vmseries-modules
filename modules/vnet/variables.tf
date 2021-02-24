variable "virtual_network_name" {
  description = "The name of the virtual network to create."
  type        = string
}

variable "location" {
  description = "Location of the resources that will be deployed. If not specified, will use the location obtained from the Resource Group Data Source."
  type        = string
  default     = ""
}

variable "resource_group_name" {
  description = "Name of the Resource Group to use."
  type        = string
}

variable "address_space" {
  description = "Address space for VNet."
  type        = list(string)
}

variable "subnets" {
  description = <<-EOF
  A map of objects describing the subnets to create within a Virtual Network.
  List of arguments available to specify a subnet:
  - `name`: The name of the subnet.
  - `resource_group_name` : Name of an existing resource group in which to create the subnet,
  if not specified, will use the default Resource Group from the Resource Group Data Source.
  - `virtual_network_name` : The name of the virtual network to which to attach the subnet,
  if not specified, will use the virtual network created in the module.
  - `address_prefixes` : The address prefix to use for the subnet.
  - `tags` : (Optional) A mapping of tags to assign to the resource.
  
  Example:
  ```
  {
    "subnet_1" = {
      name                 = "mgmt"
      resource_group_name  = "some-rg"
      virtual_network_name = "some-vnet"
      address_prefixes     = "10.100.0.0/24"
      tags                 = { "foo" = "bar" }
    }
    "subnet_2" = {
      name                 = "private"
      virtual_network_name = "some-vnet"
      address_prefixes     = "10.100.1.0/24"
      tags                 = { "foo" = "bar" }
    }
    "subnet_3" = {
      name                 = "public"
      address_prefixes     = "10.100.2.0/24"
    }
  }
  ```
  EOF
}

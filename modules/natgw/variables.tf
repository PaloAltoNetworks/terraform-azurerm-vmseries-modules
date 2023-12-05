variable "name" {
  description = "Name of a NAT Gateway."
  type        = string
}

variable "resource_group_name" {
  description = "Name of a Resource Group hosting the NAT Gateway (either the existing one or the one that will be created)."
  type        = string
}

variable "location" {
  description = "Azure region. Only for newly created resources."
  type        = string
}

variable "tags" {
  description = "A map of tags that will be assigned to resources created by this module. Only for newly created resources."
  default     = {}
  type        = map(string)
}

variable "create_natgw" {
  description = <<-EOF
  Triggers creation of a NAT Gateway when set to `true`.
  
  Set it to `false` to source an existing resource. In this 'mode' the module will only bind an existing NAT Gateway to specified
  subnets.
  EOF
  default     = true
  type        = bool
}

variable "zone" {
  description = <<-EOF
  Controls whether the NAT Gateway will be bound to a specific zone or not. This is a string with the zone number or `null`. Only
  for newly created resources.

  NAT Gateway is not zone-redundant. It is a zonal resource. It means that it's always deployed in a zone. It's up to the user to
  decide if a zone will be specified during resource deployment or if Azure will take that decision for the user. Keep in mind
  that regardless of the fact that NAT Gateway is placed in a specific zone it can serve traffic for resources in all zones. But
  if that zone becomes unavailable, resources in other zones will lose internet connectivity.

  For design considerations, limitation and examples of zone-resiliency architecture please refer to [Microsoft documentation](https://learn.microsoft.com/en-us/azure/virtual-network/nat-gateway/nat-availability-zones).
  EOF
  default     = null
  type        = string
  validation {
    condition     = (var.zone == null || can(regex("^[1-3]$", var.zone)))
    error_message = "The `zone` variable should have value of either: \"1\", \"2\" or \"3\"."
  }
}

variable "idle_timeout" {
  description = "Connection IDLE timeout in minutes (up to 120, by default 4). Only for newly created resources."
  default     = 4
  type        = number
  validation {
    condition     = (var.idle_timeout >= 1 && var.idle_timeout <= 120)
    error_message = "The `idle_timeout` variable should be a number between 1 and 120."
  }
}

variable "subnet_ids" {
  description = <<-EOF
  A map of subnet IDs what will be bound with this NAT Gateway.
  
  Value is the subnet ID, key value does not matter but should be unique, typically it can be a subnet name.
  EOF
  type        = map(string)
}

variable "public_ip" {
  description = <<-EOF
  A map defining a Public IP resource.

  List of available properties:

  - `create`              - (`bool`, required) controls whether a Public IP is created, sourced, or not used at all.
  - `name`                - (`string`, required) name of a created or sourced Public IP.
  - `resource_group_name` - (`string`, optional) name of a resource group hosting the sourced Public IP resource, ignored when
                            `create = true`.

  The module operates in 3 modes, depending on combination of `create` and `name` properties:

  `create` | `name` | operation
  --- | --- | ---
  `true` | `!null` | a Public IP resource is created in a resource group of the NAT Gateway
  `false` | `!null` | a Public IP resource is sourced from a resource group of the NAT Gateway, the resource group can be
                      overridden with `resource_group_name` property
  `false` | `null` | a Public IP resource will not be created or sourced at all
  
  Example:

  ```hcl
  # create a new Public IP
  public_ip = {
    create = true
    name = "new-public-ip-name"
  }

  # source an existing Public IP from an external resource group
  public_ip = {
    create              = false
    name                = "existing-public-ip-name"
    resource_group_name = "external-rg-name"
  }
  ```
  EOF
  default     = null
  type = object({
    create              = bool
    name                = string
    resource_group_name = optional(string)
  })
}

variable "public_ip_prefix" {
  description = <<-EOF
  A map defining a Public IP Prefix resource.
  
  List of available properties:

  - `create`              - (`bool`, required) controls whether a Public IP Prefix is created, sourced, or not used at all.
  - `name`                - (`string`, required) name of a created or sourced Public IP Prefix.
  - `resource_group_name` - (`string`, optional) name of a resource group hosting the sourced Public IP Prefix resource, ignored
                            when `create = true`.
  - `length`              - (`number`, optional, defaults to `28`) number of bits of the Public IP Prefix, this value can be
                            between `0` and `31` but can be limited on subscription level (Azure default is `/28`).

  The module operates in 3 modes, depending on combination of `create` and `name` properties:

  `create` | `name` | operation
  --- | --- | ---
  `true` | `!null` | a Public IP Prefix resource is created in a resource group of the NAT Gateway
  `false` | `!null` | a Public IP Prefix resource is sourced from a resource group of the NAT Gateway, the resource group can be
                      overridden with `resource_group_name` property
  `false` | `null` | a Public IP Prefix resource will not be created or sourced at all

  Example:

  ```hcl
  # create a new Public IP Prefix, default prefix length is `/28`
  public_ip_prefix = {
    create = true
    name   = "new-public-ip-prefix-name"
  }

  # source an existing Public IP Prefix from an external resource group
  public_ip = {
    create              = false
    name                = "existing-public-ip-prefix-name"
    resource_group_name = "external-rg-name"
  }
  ```
  EOF
  default     = null
  type = object({
    create              = bool
    name                = string
    resource_group_name = optional(string)
    length              = optional(number, 28)
  })
  validation {
    condition = (var.public_ip_prefix == null ||
    (try(var.public_ip_prefix.length, -1) >= 0 && try(var.public_ip_prefix.length, 32) <= 31))
    error_message = "The `length` property should be a number between 0 and 31."
  }
}

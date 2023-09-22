variable "resource_type" {
  description = "A type of resource for which the name template will be created. This should follow the abbreviations resource naming standard."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used in names for the resources."
  type        = string
}

variable "name_template" {
  description = <<-EOF
  A name template definition.

  Consist of two elements:

  - `parts` - a list of elements that will form the template name
  - `delimiter` - a string that will be used to separate the elements.

  There are couple of rules to be followed:

  - the order **DOES** matter
  - `parts` is a list of single element maps
  - keys in `parts` elements will be dropped, they are only informational, only values will be used
  - value for the `prefix` key will be replaced with the `var.name_prefix` value
  - a value of `__default__` will be replaced with an abbreviation defined in the `var.abbrevations` and matching `var.resource_type`.
  - since this module generates template name do **REMEMBER** to include a part with `%s` value 

  Example:

  ```
  default = {
    default = {
      delimiter = "-"
      parts = [
        { prefix = null },
        { bu = "rnd" },
        { env = "prd" },
        { name = "%s" },
        { abbreviation = "__default__" },
      ]
    }
    storage = {
      delimiter = ""
      parts = [
        { prefix = null },
        { org = "palo" },
        { env = "prd" },
        { name = "%s" },
      ]
    }
  }
  ```

  EOF
  type = object({
    delimiter = string
    parts     = list(map(string))
  })
}

variable "abbreviations" {
  description = <<-EOF
  Map of abbreviations used for resources (placed in place of "__default__").

  These abbreviations are based on [Microsoft suggestions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations).
  EOF
  type        = map(string)
  default = {
    # network
    vnet                    = "vnet"
    subnet                  = "snet"
    service_endpoint        = "se"
    vnet_peering            = "peer"
    virtual_network_gateway = "vgw"
    nsg                     = "nsg"
    nsg_rule                = "nsgsr"
    route_table             = "rt"
    udr                     = "udr"
    public_ip               = "pip"
    public_ip_prefix        = "ippre"
    # load balancing
    nat_gw         = "ng"
    load_balancer  = "lb"
    application_gw = "agw"
    # storage
    storage_account = "st"
    file_share      = "share"
    # firewall
    application_insights      = "appi"
    log_analytics_workspace   = "log"
    network_interface         = "nic"
    availability_set          = "avail"
    os_disk                   = "osdisk"
    data_disk                 = "disk"
    virtual_machine           = "vm"
    virtual_machine_scale_set = "vmss"
    # other
    resource_group   = "rg"
    bastion          = "bas"
    managed_identity = "id"
  }
}

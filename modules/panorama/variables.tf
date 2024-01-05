variable "name" {
  description = "The name of the Azure Virtual Machine."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "The name of the Azure region to deploy the resources in."
  type        = string
}

variable "tags" {
  description = "The map of tags to assign to all created resources."
  default     = {}
  type        = map(any)
}

variable "authentication" {
  description = <<-EOF
  A map defining authentication settings (including username and password).

  Following properties are available:

  - `username`                        - (`string`, optional, defaults to `panadmin`) the initial administrative Panorama username.
  - `password`                        - (`string`, optional, defaults to `null`) the initial administrative Panorama password.
  - `disable_password_authentication` - (`bool`, optional, defaults to `true`) disables password-based authentication.
  - `ssh_keys`                        - (`list`, optional, defaults to `[]`) a list of initial administrative SSH public keys.

  **Important!** \
  The `password` property is required when `ssh_keys` is not specified.

  **Important!** \
  `ssh_keys` property is a list of strings, so each item should be the actual public key value.
  If you would like to load them from files use the `file` function, for example: `[ file("/path/to/public/keys/key_1.pub") ]`.

  EOF
  type = object({
    username                        = optional(string, "panadmin")
    password                        = optional(string)
    disable_password_authentication = optional(bool, true)
    ssh_keys                        = optional(list(string), [])
  })
  validation {
    condition     = var.authentication.password != null || length(var.authentication.ssh_keys) > 0
    error_message = "Either `var.authentication.password`, `var.authentication.ssh_key` or both must be set in order to have access to the device."
  }
}

variable "image" {
  description = <<-EOF
  Basic Azure VM configuration.

  Following properties are available:

  - `version`                 - (`string`, optional, defaults to `null`) Panorama PAN-OS version; list available with 
                                `az vm image list -o table --publisher paloaltonetworks --offer panorama --all` command.
  - `publisher`               - (`string`, optional, defaults to `paloaltonetworks`) the Azure Publisher identifier for an image
                                which should be deployed.
  - `offer`                   - (`string`, optional, defaults to `panorama`) the Azure Offer identifier corresponding to a
                                published image.
  - `sku`                     - (`string`, optional, defaults to `byol`) Panorama SKU; list available with
                                `az vm image list -o table --all --publisher paloaltonetworks` command.
  - `enable_marketplace_plan` - (`bool`, optional, defaults to `true`) when set to `true` accepts the license for an offer/plan
                                on Azure Marketplace.
  - `custom_id`               - (`string`, optional, defaults to `null`) absolute ID of your own custom PAN-OS image to be used
                                for creating new Virtual Machines.

  **Important!** \
  The `custom_id` and `version` properties are mutually exclusive.
  
  EOF
  type = object({
    version                 = optional(string)
    publisher               = optional(string, "paloaltonetworks")
    offer                   = optional(string, "panorama")
    sku                     = optional(string, "byol")
    enable_marketplace_plan = optional(bool, true)
    custom_id               = optional(string)
  })
  validation {
    condition = (var.image.custom_id != null && var.image.version == null
    ) || (var.image.custom_id == null && var.image.version != null)
    error_message = "Either `custom_id` or `version` has to be defined."
  }
}

variable "virtual_machine" {
  description = <<-EOF
  Firewall parameters configuration.

  This map contains basic, as well as some optional Firewall parameters. Both types contain sane defaults.
  Nevertheless they should be at least reviewed to meet deployment requirements.

  List of either required or important properties:

  - `size`      - (`string`, optional, defaults to `Standard_D5_v2`) Azure VM size (type). Consult the *Panorama Deployment
                  Guide* as only a few selected sizes are supported.
  - `zone`      - (`number`, required) Availability Zone to place the VM in, `null` value means a non-zonal deployment.
  - `disk_type` - (`string`, optional, defaults to `StandardSSD_LRS`) type of Managed Disk which should be created, possible
                  values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS` (works only for selected `size` values).
  - `disk_name` - (`string`, optional, defaults to VM name + `-disk` suffix) name od the OS disk.

  List of other, optional properties: 

  - `avset_key`                    - (`string`, optional, default to `null`) identifier of the Availability Set to use.
  - `disk_encryption_set_id`       - (`string`, optional, defaults to `null`) the ID of the Disk Encryption Set which should be
                                     used to encrypt this VM's disk.
  - `allow_extension_operations`   - (`bool`, optional, defaults to `false`) should Extension Operations be allowed on this VM.
  - `encryption_at_host_enabled`   - (`bool`, optional, defaults to `false`) should all the disks be encrypted by enabling
                                     Encryption at Host.
  - `diagnostics_storage_uri`      - (`string`, optional, defaults to `null`) storage account's blob endpoint to hold
                                     diagnostic files.
  - `identity_type`                - (`string`, optional, defaults to `SystemAssigned`) type of Managed Service Identity that
                                     should be configured on this VM. Can be one of "SystemAssigned", "UserAssigned" or
                                     "SystemAssigned, UserAssigned".
  - `identity_ids`                 - (`list`, optional, defaults to `[]`) a list of User Assigned Managed Identity IDs to be
                                     assigned to this VM. Required only if `identity_type` is not "SystemAssigned".

  EOF
  type = object({
    size                       = optional(string, "Standard_D5_v2")
    zone                       = string
    disk_type                  = optional(string, "StandardSSD_LRS")
    disk_name                  = string
    avset_id                   = optional(string)
    allow_extension_operations = optional(bool, false)
    encryption_at_host_enabled = optional(bool, false)
    disk_encryption_set_id     = optional(string)
    diagnostics_storage_uri    = optional(string)
    identity_type              = optional(string, "SystemAssigned")
    identity_ids               = optional(list(string), [])
  })
  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.virtual_machine.disk_type)
    error_message = "The `disk_type` property can be one of: `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`."
  }
  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.virtual_machine.identity_type)
    error_message = "The `identity_type` property can be one of \"SystemAssigned\", \"UserAssigned\" or \"SystemAssigned, UserAssigned\"."
  }
  validation {
    condition     = var.virtual_machine.identity_type == "SystemAssigned" ? length(var.virtual_machine.identity_ids) == 0 : length(var.virtual_machine.identity_ids) >= 0
    error_message = "The `identity_ids` property is required when `identity_type` is not \"SystemAssigned\"."
  }
}

variable "interfaces" {
  description = <<-EOF
  List of the network interface specifications.

  **Note!**
  The ORDER in which you specify the interfaces DOES MATTER.

  Interfaces will be attached to VM in the order you define here, therefore:

  - The first should be the management interface, which does not participate in data filtering.
  - The remaining ones are the dataplane interfaces.
  
  Following configuration options are available:

  - `name`                          - (`string`, required) the interface name.
  - `subnet_id`                     - (`string`, required) ID of an existing subnet to create the interface in.
  - `private_ip_address`            - (`string`, optional, defaults to `null`) static private IP to assign to the interface. When
                                      skipped Azure will assign one dynamically. Keep in mind that a dynamic IP is guarantied not
                                      to change as long as the VM is running. Any stop/deallocate/restart operation might cause
                                      the IP to change.
  - `create_public_ip`              - (`bool`, optional, defaults to `false`) if `true`, creates a public IP for the interface.
  - `public_ip_name`                - (`string`, optional, defaults to `null`) name of the public IP to associate with the
                                      interface. When `create_public_ip` is set to `true` this will become a name of a newly
                                      created Public IP interface. Otherwise this is a name of an existing interfaces that will
                                      be sourced and attached to the interface.
  - `public_ip_resource_group_name` - (`string`, optional, defaults to `var.resource_group_name`) name of a Resource Group that
                                      contains public IP that that will be associated with the interface. Used only when 
                                      `create_public_ip` is `false`.

  Example:

  ```hcl
  [
    # management interface with a new public IP
    {
      name             = "pano-mgmt"
      subnet_id        = azurerm_subnet.my_mgmt_subnet.id
      public_ip_name   = "pano-mgmt-pip"
      create_public_ip = true
    },
    # public interface reusing an existing public IP resource
    {
      name             = "pano-public"
      subnet_id        = azurerm_subnet.my_pub_subnet.id
      create_public_ip = false
      public_ip_name   = "pano-public-pip"
    },
  ]
  ```
  
  EOF
  type = list(object({
    name                          = string
    subnet_id                     = string
    private_ip_address            = optional(string)
    create_public_ip              = optional(bool, false)
    public_ip_name                = optional(string)
    public_ip_resource_group_name = optional(string)
  }))
  validation {
    condition = alltrue([
      for v in var.interfaces : v.public_ip_name != null
      if v.create_public_ip
    ])
    error_message = "The `public_ip_name` property is required when `create_public_ip` is `true`."
  }
}

# Storage
variable "logging_disks" {
  description = <<-EOF
   A map of objects describing the additional disks configuration.
   
  Following configuration options are available:
  
  - `name`      - (`string`, required) the Managed Disk name.
  - `size`      - (`string`, optional, defaults to "2048") size of the disk in GB. The recommended size for additional disks
                  is at least 2TB (2048 GB).
  - `lun`       - (`string`, required) the Logical Unit Number of the Data Disk, which needs to be unique within the VM.
  - `disk_type` - (`string`, optional, defaults to "StandardSSD_LRS") type of Managed Disk which should be created, possible
                  values are `Standard_LRS`, `StandardSSD_LRS`, `Premium_LRS` or `UltraSSD_LRS`.
    
  Example:

  ```hcl
  {
    logs-1 = {
      size: "2048"
      zone: "1"
      lun: "1"
    }
    logs-2 = {
      size: "2048"
      zone: "2"
      lun: "2"
      disk_type: "StandardSSD_LRS"
    }
  }
  ```
  
  EOF
  default     = {}
  nullable    = false
  type = map(object({
    name      = string
    size      = optional(string, "2048")
    lun       = string
    disk_type = optional(string, "StandardSSD_LRS")
  }))
  validation {
    condition     = alltrue([for _, v in var.logging_disks : contains(range(2048, 24577, 2048), parseint(v.size, 10))])
    error_message = "The `size` property value must be a multiple of `2048` but not higher than `24576` (24 TB)."
  }
  validation {
    condition = alltrue([
      for _, v in var.logging_disks : (parseint(v.lun, 10) >= 0 && parseint(v.lun, 10) <= 63) if v.lun != null
    ])
    error_message = "The `lun` property value must be a number between `0` and `63`."
  }
  validation {
    condition = alltrue([
      for _, v in var.logging_disks : contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "UltraSSD_LRS"], v.disk_type)
    ])
    error_message = "The `disk_type` property can be one of: `Standard_LRS`, `StandardSSD_LRS`, `Premium_LRS` or `UltraSSD_LRS`."
  }
}

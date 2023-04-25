variable "location" {
  description = "Region where to deploy VM-Series and dependencies."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group where to place the resources created."
  type        = string
}

variable "name" {
  description = "VM-Series instance name."
  type        = string
}

variable "enable_zones" {
  description = "If false, the input `avzone` is ignored and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones."
  default     = true
  type        = bool
}

variable "avzone" {
  description = "The availability zone to use, for example \"1\", \"2\", \"3\". Ignored if `enable_zones` is false. Conflicts with `avset_id`, in which case use `avzone = null`."
  default     = "1"
  type        = string
}

variable "avzones" {
  description = <<-EOF
  After provider version 3.x you need to specify in which availability zone(s) you want to place IP.
  ie: for zone-redundant with 3 availability zone in current region value will be:
  ```["1","2","3"]```
  EOF
  default     = []
  type        = list(string)
}

variable "avset_id" {
  description = "The identifier of the Availability Set to use. When using this variable, set `avzone = null`."
  default     = null
  type        = string
}

variable "interfaces" {
  description = <<-EOF
  List of the network interface specifications.

  NOTICE. The ORDER in which you specify the interfaces DOES MATTER.
  Interfaces will be attached to VM in the order you define here, therefore:
  * The first should be the management interface, which does not participate in data filtering.
  * The remaining ones are the dataplane interfaces.
  
  Options for an interface object:
  - `name`                     - (required|string) Interface name.
  - `subnet_id`                - (required|string) Identifier of an existing subnet to create interface in.
  - `create_public_ip`         - (optional|bool) If true, create a public IP for the interface and ignore the `public_ip_address_id`. Default is false.
  - `private_ip_address`       - (optional|string) Static private IP to asssign to the interface. If null, dynamic one is allocated.
  - `public_ip_name`           - (optional|string) Name of an existing public IP to associate to the interface, used only when `create_public_ip` is `false`.
  - `public_ip_resource_group` - (optional|string) Name of a Resource Group that contains public IP resource to associate to the interface. When not specified defaults to `var.resource_group_name`. Used only when `create_public_ip` is `false`.
  - `availability_zone`        - (optional|string) Availability zone to create public IP in. If not specified, set based on `avzone` and `enable_zones`.
  - `enable_ip_forwarding`     - (optional|bool) If true, the network interface will not discard packets sent to an IP address other than the one assigned. If false, the network interface only accepts traffic destined to its IP address.
  - `enable_backend_pool`      - (optional|bool) If true, associate interface with backend pool specified with `lb_backend_pool_id`. Default is false.
  - `lb_backend_pool_id`       - (optional|string) Identifier of an existing backend pool to associate interface with. Required if `enable_backend_pool` is true.
  - `tags`                     - (optional|map) Tags to assign to the interface and public IP (if created). Overrides contents of `tags` variable.

  Example:

  ```
  [
    {
      name                 = "fw-mgmt"
      subnet_id            = azurerm_subnet.my_mgmt_subnet.id
      public_ip_address_id = azurerm_public_ip.my_mgmt_ip.id
      create_public_ip     = true
    },
    {
      name                = "fw-public"
      subnet_id           = azurerm_subnet.my_pub_subnet.id
      lb_backend_pool_id  = module.inbound_lb.backend_pool_id
      enable_backend_pool = true
      create_public_ip    = false
      public_ip_name      = "fw-public-ip"
    },
  ]
  ```

  EOF
  type        = list(any)
}

variable "username" {
  description = "Initial administrative username to use for VM-Series. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-username-requirements-when-creating-a-vm)."
  type        = string
}

variable "password" {
  description = "Initial administrative password to use for VM-Series. If not defined the `ssh_key` variable must be specified. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm)."
  default     = null
  type        = string
  sensitive   = true
}

variable "ssh_keys" {
  description = <<-EOF
  A list of initial administrative SSH public keys that allow key-pair authentication.
  
  This is a list of strings, so each item should be the actual public key value. If you would like to load them from files instead, following method is available:

  ```
  [
    file("/path/to/public/keys/key_1.pub"),
    file("/path/to/public/keys/key_2.pub")
  ]
  ```
  
  If the `password` variable is also set, VM-Series will accept both authentication methods.
  EOF
  default     = []
  type        = list(string)
}

variable "managed_disk_type" {
  description = "Type of OS Managed Disk to create for the virtual machine. Possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`. The `Premium_LRS` works only for selected `vm_size` values, details in Azure docs."
  default     = "StandardSSD_LRS"
  type        = string
}

variable "os_disk_name" {
  description = "Optional name of the OS disk to create for the virtual machine. If empty, the name is auto-generated."
  default     = null
  type        = string
}

variable "vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported."
  default     = "Standard_D3_v2"
  type        = string
}

variable "custom_image_id" {
  description = "Absolute ID of your own Custom Image to be used for creating new VM-Series. If set, the `username`, `password`, `img_version`, `img_publisher`, `img_offer`, `img_sku` inputs are all ignored (these are used only for published images, not custom ones). The Custom Image is expected to contain PAN-OS software."
  default     = null
  type        = string
}

variable "enable_plan" {
  description = "Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku \"byol\", which means \"bring your own license\", still requires accepting on the Marketplace (as of 2021). Can be set to `false` when using a custom image."
  default     = true
  type        = bool
}

variable "img_publisher" {
  description = "The Azure Publisher identifier for a image which should be deployed."
  default     = "paloaltonetworks"
}

variable "img_offer" {
  description = "The Azure Offer identifier corresponding to a published image. For `img_version` 9.1.1 or above, use \"vmseries-flex\"; for 9.1.0 or below use \"vmseries1\"."
  default     = "vmseries-flex"
}

variable "img_sku" {
  description = "VM-series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "byol"
  type        = string
}

variable "img_version" {
  description = "VM-series PAN-OS version - list available for a default `img_offer` with `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all`"
  default     = "10.1.0"
  type        = string
}

variable "tags" {
  description = "A map of tags to be associated with the resources created."
  default     = {}
  type        = map(any)
}

variable "identity_type" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine#identity_type)."
  default     = "SystemAssigned"
  type        = string
}

variable "identity_ids" {
  description = "See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine#identity_ids)."
  default     = null
  type        = list(string)
}

variable "accelerated_networking" {
  description = "Enable Azure accelerated networking (SR-IOV) for all network interfaces except the primary one (it is the PAN-OS management interface, which [does not support](https://docs.paloaltonetworks.com/pan-os/9-0/pan-os-new-features/virtualization-features/support-for-azure-accelerated-networking-sriov) acceleration)."
  default     = true
  type        = bool
}

variable "bootstrap_options" {
  description = <<-EOF
  Bootstrap options to pass to VM-Series instance.

  Proper syntax is a string of semicolon separated properties.
  Example:
    bootstrap_options = "type=dhcp-client;panorama-server=1.2.3.4"

  A list of available properties: storage-account, access-key, file-share, share-directory, type, ip-address, default-gateway, netmask, ipv6-address, ipv6-default-gateway, hostname, panorama-server, panorama-server-2, tplname, dgname, dns-primary, dns-secondary, vm-auth-key, op-command-modes, op-cmd-dpdk-pkt-io, plugin-op-commands, dhcp-send-hostname, dhcp-send-client-id, dhcp-accept-server-hostname, dhcp-accept-server-domain, auth-key, vm-series-auto-registration-pin-value, vm-series-auto-registration-pin-id.

  For more details on bootstrapping see documentation: https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/init-cfgtxt-file-components
  EOF
  default     = ""
  type        = string
  sensitive   = true
}

variable "diagnostics_storage_uri" {
  description = "The storage account's blob endpoint to hold diagnostic files."
  default     = null
  type        = string
}

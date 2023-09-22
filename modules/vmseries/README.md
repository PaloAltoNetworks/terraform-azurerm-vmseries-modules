<!-- BEGIN_TF_DOCS -->


## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`location`](#location) | `string` | Region where to deploy VM-Series and dependencies.
[`resource_group_name`](#resource_group_name) | `string` | Name of the existing resource group where to place the resources created.
[`name`](#name) | `string` | VM-Series instance name.
[`interfaces`](#interfaces) | `list(any)` | List of the network interface specifications.
[`username`](#username) | `string` | Initial administrative username to use for VM-Series.

## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`enable_zones`](#enable_zones) | `bool` | If false, the input `avzone` is ignored and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting).
[`avzone`](#avzone) | `string` | The availability zone to use, for example "1", "2", "3".
[`avzones`](#avzones) | `list(string)` | After provider version 3.
[`avset_id`](#avset_id) | `string` | The identifier of the Availability Set to use.
[`password`](#password) | `string` | Initial administrative password to use for VM-Series.
[`ssh_keys`](#ssh_keys) | `list(string)` | A list of initial administrative SSH public keys that allow key-pair authentication.
[`managed_disk_type`](#managed_disk_type) | `string` | Type of OS Managed Disk to create for the virtual machine.
[`os_disk_name`](#os_disk_name) | `string` | Optional name of the OS disk to create for the virtual machine.
[`vm_size`](#vm_size) | `string` | Azure VM size (type) to be created.
[`custom_image_id`](#custom_image_id) | `string` | Absolute ID of your own Custom Image to be used for creating new VM-Series.
[`enable_plan`](#enable_plan) | `bool` | Enable usage of the Offer/Plan on Azure Marketplace.
[`img_publisher`](#img_publisher) | `string` | The Azure Publisher identifier for a image which should be deployed.
[`img_offer`](#img_offer) | `string` | The Azure Offer identifier corresponding to a published image.
[`img_sku`](#img_sku) | `string` | VM-series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`.
[`img_version`](#img_version) | `string` | VM-series PAN-OS version - list available for a default `img_offer` with `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all`.
[`tags`](#tags) | `map(any)` | A map of tags to be associated with the resources created.
[`identity_type`](#identity_type) | `string` | See the [provider documentation](https://registry.
[`identity_ids`](#identity_ids) | `list(string)` | See the [provider documentation](https://registry.
[`accelerated_networking`](#accelerated_networking) | `bool` | Enable Azure accelerated networking (SR-IOV) for all network interfaces except the primary one (it is the PAN-OS management interface, which [does not support](https://docs.
[`bootstrap_options`](#bootstrap_options) | `string` | Bootstrap options to pass to VM-Series instance.
[`diagnostics_storage_uri`](#diagnostics_storage_uri) | `string` | The storage account's blob endpoint to hold diagnostic files.

## Module's Outputs

Name |  Description
--- | ---
[`mgmt_ip_address`](#mgmt_ip_address) | VM-Series management IP address
[`interfaces`](#interfaces) | Map of VM-Series network interfaces
[`principal_id`](#principal_id) | The oid of Azure Service Principal of the created VM-Series

## Module's Nameplate

Requirements needed by this module:

- `terraform`, version: >= 1.2, < 2.0
- `azurerm`, version: ~> 3.25

Providers used in this module:

- `azurerm`, version: ~> 3.25

Modules used in this module:
Name | Version | Source | Description
--- | --- | --- | ---

Resources used in this module:

- `network_interface` (managed)
- `network_interface_backend_address_pool_association` (managed)
- `public_ip` (managed)
- `virtual_machine` (managed)
- `public_ip` (data)

## Inputs/Outpus details

### Required Inputs


#### location

Region where to deploy VM-Series and dependencies.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>

#### resource_group_name

Name of the existing resource group where to place the resources created.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>

#### name

VM-Series instance name.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>





#### interfaces

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



Type: `list(any)`

<sup>[back to list](#modules-required-inputs)</sup>

#### username

Initial administrative username to use for VM-Series. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-username-requirements-when-creating-a-vm).

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>



















### Optional Inputs





#### enable_zones

If false, the input `avzone` is ignored and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones.

Type: `bool`

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>

#### avzone

The availability zone to use, for example "1", "2", "3". Ignored if `enable_zones` is false. Conflicts with `avset_id`, in which case use `avzone = null`.

Type: `string`

Default value: `1`

<sup>[back to list](#modules-optional-inputs)</sup>

#### avzones

After provider version 3.x you need to specify in which availability zone(s) you want to place IP.
ie: for zone-redundant with 3 availability zone in current region value will be:
```["1","2","3"]```


Type: `list(string)`

Default value: `[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### avset_id

The identifier of the Availability Set to use. When using this variable, set `avzone = null`.

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>



#### password

Initial administrative password to use for VM-Series. If not defined the `ssh_key` variable must be specified. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm).

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### ssh_keys

A list of initial administrative SSH public keys that allow key-pair authentication.
  
This is a list of strings, so each item should be the actual public key value. If you would like to load them from files instead, following method is available:

```
[
  file("/path/to/public/keys/key_1.pub"),
  file("/path/to/public/keys/key_2.pub")
]
```
  
If the `password` variable is also set, VM-Series will accept both authentication methods.


Type: `list(string)`

Default value: `[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### managed_disk_type

Type of OS Managed Disk to create for the virtual machine. Possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`. The `Premium_LRS` works only for selected `vm_size` values, details in Azure docs.

Type: `string`

Default value: `StandardSSD_LRS`

<sup>[back to list](#modules-optional-inputs)</sup>

#### os_disk_name

Optional name of the OS disk to create for the virtual machine. If empty, the name is auto-generated.

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### vm_size

Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported.

Type: `string`

Default value: `Standard_D3_v2`

<sup>[back to list](#modules-optional-inputs)</sup>

#### custom_image_id

Absolute ID of your own Custom Image to be used for creating new VM-Series. If set, the `username`, `password`, `img_version`, `img_publisher`, `img_offer`, `img_sku` inputs are all ignored (these are used only for published images, not custom ones). The Custom Image is expected to contain PAN-OS software.

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### enable_plan

Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku "byol", which means "bring your own license", still requires accepting on the Marketplace (as of 2021). Can be set to `false` when using a custom image.

Type: `bool`

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>

#### img_publisher

The Azure Publisher identifier for a image which should be deployed.

Type: `string`

Default value: `paloaltonetworks`

<sup>[back to list](#modules-optional-inputs)</sup>

#### img_offer

The Azure Offer identifier corresponding to a published image. For `img_version` 9.1.1 or above, use "vmseries-flex"; for 9.1.0 or below use "vmseries1".

Type: `string`

Default value: `vmseries-flex`

<sup>[back to list](#modules-optional-inputs)</sup>

#### img_sku

VM-series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`

Type: `string`

Default value: `byol`

<sup>[back to list](#modules-optional-inputs)</sup>

#### img_version

VM-series PAN-OS version - list available for a default `img_offer` with `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all`

Type: `string`

Default value: `10.1.0`

<sup>[back to list](#modules-optional-inputs)</sup>

#### tags

A map of tags to be associated with the resources created.

Type: `map(any)`

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### identity_type

See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine#identity_type).

Type: `string`

Default value: `SystemAssigned`

<sup>[back to list](#modules-optional-inputs)</sup>

#### identity_ids

See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine#identity_ids).

Type: `list(string)`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### accelerated_networking

Enable Azure accelerated networking (SR-IOV) for all network interfaces except the primary one (it is the PAN-OS management interface, which [does not support](https://docs.paloaltonetworks.com/pan-os/9-0/pan-os-new-features/virtualization-features/support-for-azure-accelerated-networking-sriov) acceleration).

Type: `bool`

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>

#### bootstrap_options

Bootstrap options to pass to VM-Series instance.

Proper syntax is a string of semicolon separated properties.
Example:
  bootstrap_options = "type=dhcp-client;panorama-server=1.2.3.4"

A list of available properties: storage-account, access-key, file-share, share-directory, type, ip-address, default-gateway, netmask, ipv6-address, ipv6-default-gateway, hostname, panorama-server, panorama-server-2, tplname, dgname, dns-primary, dns-secondary, vm-auth-key, op-command-modes, op-cmd-dpdk-pkt-io, plugin-op-commands, dhcp-send-hostname, dhcp-send-client-id, dhcp-accept-server-hostname, dhcp-accept-server-domain, auth-key, vm-series-auto-registration-pin-value, vm-series-auto-registration-pin-id.

For more details on bootstrapping see documentation: https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/init-cfgtxt-file-components


Type: `string`

Default value: ``

<sup>[back to list](#modules-optional-inputs)</sup>

#### diagnostics_storage_uri

The storage account's blob endpoint to hold diagnostic files.

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>


### Outputs


#### `mgmt_ip_address`

VM-Series management IP address. If `create_public_ip` was `true`, it is a public IP address, otherwise a private IP address.

<sup>[back to list](#modules-outputs)</sup>
#### `interfaces`

Map of VM-Series network interfaces. Keys are equal to var.interfaces `name` properties.

<sup>[back to list](#modules-outputs)</sup>
#### `principal_id`

The oid of Azure Service Principal of the created VM-Series. Usable only if `identity_type` contains SystemAssigned.

<sup>[back to list](#modules-outputs)</sup>
<!-- END_TF_DOCS -->
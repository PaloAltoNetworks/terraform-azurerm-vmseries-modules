<!-- BEGIN_TF_DOCS -->


## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`location`](#location) | `string` | Region to deploy Panorama into.
[`name`](#name) | `string` | The Panorama common name.
[`resource_group_name`](#resource_group_name) | `string` | The name of the existing resource group where to place all the resources created by this module.
[`interfaces`](#interfaces) | `list(any)` | List of the network interface specifications.

## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`enable_zones`](#enable_zones) | `bool` | If false, the input `avzone` is ignored and all created public IPs default not to use Availability Zones (the `No-Zone` setting).
[`avzone`](#avzone) | `any` | The availability zone to use, for example "1", "2", "3".
[`avzones`](#avzones) | `list(string)` | After provider version 3.
[`os_disk_name`](#os_disk_name) | `string` | The name of OS disk.
[`panorama_size`](#panorama_size) | `string` | Virtual Machine size.
[`username`](#username) | `string` | Initial administrative username to use for Panorama.
[`password`](#password) | `string` | Initial administrative password to use for Panorama.
[`ssh_keys`](#ssh_keys) | `list(string)` | A list of initial administrative SSH public keys that allow key-pair authentication.
[`enable_plan`](#enable_plan) | `bool` | Enable usage of the Offer/Plan on Azure Marketplace.
[`panorama_disk_type`](#panorama_disk_type) | `string` | Specifies the type of managed disk to create.
[`panorama_sku`](#panorama_sku) | `string` | Panorama SKU.
[`panorama_version`](#panorama_version) | `string` | Panorama PAN-OS Software version.
[`panorama_publisher`](#panorama_publisher) | `string` | Panorama Publisher.
[`panorama_offer`](#panorama_offer) | `string` | Panorama offer.
[`custom_image_id`](#custom_image_id) | `string` | Absolute ID of your own Custom Image to be used for creating Panorama.
[`logging_disks`](#logging_disks) | `map(any)` |  A map of objects describing the additional disk configuration.
[`boot_diagnostic_storage_uri`](#boot_diagnostic_storage_uri) | `string` | Existing diagnostic storage uri.
[`tags`](#tags) | `map(any)` | A map of tags to be associated with the resources created.

## Module's Outputs

Name |  Description
--- | ---
[`mgmt_ip_address`](#mgmt_ip_address) | Panorama management IP address
[`interfaces`](#interfaces) | Map of VM-Series network interfaces

## Module's Nameplate

Requirements needed by this module:

- `terraform`, version: >= 1.2, < 2.0
- `azurerm`, version: ~> 3.25
- `random`, version: ~> 3.1

Providers used in this module:

- `azurerm`, version: ~> 3.25

Modules used in this module:
Name | Version | Source | Description
--- | --- | --- | ---

Resources used in this module:

- `managed_disk` (managed)
- `network_interface` (managed)
- `public_ip` (managed)
- `virtual_machine` (managed)
- `virtual_machine_data_disk_attachment` (managed)
- `public_ip` (data)

## Inputs/Outpus details

### Required Inputs


#### location

Region to deploy Panorama into.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>




#### name

The Panorama common name.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>


#### resource_group_name

The name of the existing resource group where to place all the resources created by this module.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>












#### interfaces

List of the network interface specifications.

NOTICE. The ORDER in which you specify the interfaces DOES MATTER.
Interfaces will be attached to VM in the order you define here, therefore the first should be the management interface.
  
Options for an interface object:
- `name`                     - (required|string) Interface name.
- `subnet_id`                - (required|string) Identifier of an existing subnet to create interface in.
- `create_public_ip`         - (optional|bool) If true, create a public IP for the interface and ignore the `public_ip_address_id`. Default is false.
- `private_ip_address`       - (optional|string) Static private IP to asssign to the interface. If null, dynamic one is allocated.
- `public_ip_name`           - (optional|string) Name of an existing public IP to associate to the interface, used only when `create_public_ip` is `false`.
- `public_ip_resource_group` - (optional|string) Name of a Resource Group that contains public IP resource to associate to the interface. When not specified defaults to `var.resource_group_name`. Used only when `create_public_ip` is `false`.

Example:

```
[
  {
    name                 = "mgmt"
    subnet_id            = azurerm_subnet.my_mgmt_subnet.id
    public_ip_address_id = azurerm_public_ip.my_mgmt_ip.id
    create_public_ip     = true
  }
]
```


Type: `list(any)`

<sup>[back to list](#modules-required-inputs)</sup>





### Optional Inputs



#### enable_zones

If false, the input `avzone` is ignored and all created public IPs default not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones.

Type: `bool`

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>

#### avzone

The availability zone to use, for example "1", "2", "3". Ignored if `enable_zones` is false. Use `avzone = null` to disable the use of Availability Zones.

Type: `any`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### avzones

After provider version 3.x you need to specify in which availability zone(s) you want to place IP.
ie: for zone-redundant with 3 availability zone in current region value will be:
```["1","2","3"]```


Type: `list(string)`

Default value: `[]`

<sup>[back to list](#modules-optional-inputs)</sup>


#### os_disk_name

The name of OS disk. The name is auto-generated when not provided.

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>


#### panorama_size

Virtual Machine size.

Type: `string`

Default value: `Standard_D5_v2`

<sup>[back to list](#modules-optional-inputs)</sup>

#### username

Initial administrative username to use for Panorama. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-username-requirements-when-creating-a-vm).

Type: `string`

Default value: `panadmin`

<sup>[back to list](#modules-optional-inputs)</sup>

#### password

Initial administrative password to use for Panorama. If not defined the `ssh_key` variable must be specified. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm).

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

#### enable_plan

Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku "byol", which means "bring your own license", still requires accepting on the Marketplace (as of 2021). Can be set to `false` when using a custom image.

Type: `bool`

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>

#### panorama_disk_type

Specifies the type of managed disk to create. Possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS or UltraSSD_LRS.

Type: `string`

Default value: `StandardSSD_LRS`

<sup>[back to list](#modules-optional-inputs)</sup>

#### panorama_sku

Panorama SKU.

Type: `string`

Default value: `byol`

<sup>[back to list](#modules-optional-inputs)</sup>

#### panorama_version

Panorama PAN-OS Software version. List published images with `az vm image list -o table --all --publisher paloaltonetworks --offer panorama`

Type: `string`

Default value: `10.0.3`

<sup>[back to list](#modules-optional-inputs)</sup>

#### panorama_publisher

Panorama Publisher.

Type: `string`

Default value: `paloaltonetworks`

<sup>[back to list](#modules-optional-inputs)</sup>

#### panorama_offer

Panorama offer.

Type: `string`

Default value: `panorama`

<sup>[back to list](#modules-optional-inputs)</sup>

#### custom_image_id

Absolute ID of your own Custom Image to be used for creating Panorama. If set, the `username`, `password`, `panorama_version`, `panorama_publisher`, `panorama_offer`, `panorama_sku` inputs are all ignored (these are used only for published images, not custom ones). The Custom Image is expected to contain PAN-OS software.

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>


#### logging_disks

 A map of objects describing the additional disk configuration. The keys of the map are the names and values are { size, zone, lun }. 
 The size value is provided in GB. The recommended size for additional (optional) disks is at least 2TB (2048 GB). Example:

```
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



Type: `map(any)`

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### boot_diagnostic_storage_uri

Existing diagnostic storage uri

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### tags

A map of tags to be associated with the resources created.

Type: `map(any)`

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>


### Outputs


#### `mgmt_ip_address`

Panorama management IP address. If `public_ip` was `true`, it is a public IP address, otherwise a private IP address.

<sup>[back to list](#modules-outputs)</sup>
#### `interfaces`

Map of VM-Series network interfaces. Keys are equal to var.interfaces `name` properties.

<sup>[back to list](#modules-outputs)</sup>
<!-- END_TF_DOCS -->
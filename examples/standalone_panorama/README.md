<!-- BEGIN_TF_DOCS -->


## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`location`](#location) | `string` | The Azure region to use.
[`resource_group_name`](#resource_group_name) | `string` | Name of the Resource Group to .
[`vnets`](#vnets) | `any` | A map defining VNETs.
[`panorama_version`](#panorama_version) | `string` | Panorama PanOS version.

## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`tags`](#tags) | `map(string)` | Map of tags to assign to the created resources.
[`name_prefix`](#name_prefix) | `string` | A prefix that will be added to all created resources.
[`create_resource_group`](#create_resource_group) | `bool` | When set to `true` it will cause a Resource Group creation.
[`enable_zones`](#enable_zones) | `bool` | If `true`, enable zone support for resources.
[`vmseries_username`](#vmseries_username) | `string` | Initial administrative username to use for all systems.
[`vmseries_password`](#vmseries_password) | `string` | Initial administrative password to use for all systems.
[`panorama_sku`](#panorama_sku) | `string` | Panorama SKU, basically a type of licensing used in Azure.
[`panorama_size`](#panorama_size) | `string` | A size of a VM that will run Panorama.
[`panoramas`](#panoramas) | `any` | A map containing Panorama definitions.

## Module's Outputs

Name |  Description
--- | ---
[`username`](#username) | Initial administrative username to use for VM-Series
[`password`](#password) | Initial administrative password to use for VM-Series
[`panorama_mgmt_ips`](#panorama_mgmt_ips) | 

## Module's Nameplate

Requirements needed by this module:

- `terraform`, version: >= 1.2, < 2.0

Providers used in this module:

- `random`
- `azurerm`

Modules used in this module:
Name | Version | Source | Description
--- | --- | --- | ---
`vnet` | - | ../../modules/vnet | Manage the network required for the topology.
`panorama` | - | ../../modules/panorama | 

Resources used in this module:

- `resource_group` (managed)
- `password` (managed)
- `resource_group` (data)

## Inputs/Outpus details

### Required Inputs



#### location

The Azure region to use.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>



#### resource_group_name

Name of the Resource Group to .

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>


#### vnets

A map defining VNETs. A key is the VNET name, value is a set of properties like described below.
  
For detailed documentation on each property refer to [module documentation](../../modules/vnet/README.md)

- `name` : a name of a Virtual Network
- `create_virtual_network` : (default: `true`) when set to `true` will create a VNET, `false` will source an existing VNET
- `address_space` : a list of CIDRs for VNET
- `resource_group_name` :  (default: current RG) a name of a Resource Group in which the VNET will reside

- `create_subnets` : (default: `true`) if true, create the Subnets inside the Virtual Network, otherwise use pre-existing subnets
- `subnets` : map of Subnets to create

- `network_security_groups` : map of Network Security Groups to create
- `route_tables` : map of Route Tables to create.


Type: `any`

<sup>[back to list](#modules-required-inputs)</sup>



#### panorama_version

Panorama PanOS version. It's also possible to specify the Pan-OS version per Panorama (in case you would like to deploy more than one), see `var.panoramas` variable.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>





### Optional Inputs


#### tags

Map of tags to assign to the created resources.

Type: `map(string)`

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>


#### name_prefix

A prefix that will be added to all created resources.
There is no default delimiter applied between the prefix and the resource name. Please include the delimiter in the actual prefix.

Example:
```
name_prefix = "test-"
```
  
NOTICE. This prefix is not applied to existing resources. If you plan to reuse i.e. a VNET please specify it's full name, even if it is also prefixed with the same value as the one in this property.


Type: `string`

Default value: ``

<sup>[back to list](#modules-optional-inputs)</sup>

#### create_resource_group

When set to `true` it will cause a Resource Group creation. Name of the newly specified RG is controlled by `resource_group_name`.
When set to `false` the `resource_group_name` parameter is used to specify a name of an existing Resource Group.


Type: `bool`

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>


#### enable_zones

If `true`, enable zone support for resources.

Type: `bool`

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>


#### vmseries_username

Initial administrative username to use for all systems.

Type: `string`

Default value: `panadmin`

<sup>[back to list](#modules-optional-inputs)</sup>

#### vmseries_password

Initial administrative password to use for all systems. Set to null for an auto-generated password.

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>


#### panorama_sku

Panorama SKU, basically a type of licensing used in Azure.

Type: `string`

Default value: `byol`

<sup>[back to list](#modules-optional-inputs)</sup>

#### panorama_size

A size of a VM that will run Panorama. It's also possible to specify the the VM size per Panorama, see `var.panoramas` variable.

Type: `string`

Default value: `Standard_D5_v2`

<sup>[back to list](#modules-optional-inputs)</sup>

#### panoramas

A map containing Panorama definitions.
  
All definitions share a VM size, SKU and PanOS version (`panorama_size`, `panorama_sku`, `panorama_version` respectively). Defining more than one Panorama makes sense when creating for example HA pairs. 

Following properties are available:

- `name` : a name of a Panorama VM
- `size` : size of the Panorama virtual machine, when specified overrides `var.panorama_size`.
- `version` : PanOS version, when specified overrides `var.panorama_version`.
- `vnet_key`: a VNET used to host Panorama VM, this is a key from a VNET definition stored in `vnets` variable
- `subnet_key`: a Subnet inside a VNET used to host Panorama VM, this is a key from a Subnet definition stored inside a VNET definition references by the `vnet_key` property
- `avzone`: when `enable_zones` is `true` this specifies the zone in which Panorama will be deployed
- `avzones`: when `enable_zones` is `true` these are availability zones used by Panorama's public IPs
- `custom_image_id`: a custom build of Panorama to use, overrides the stock image version.

- `interfaces` : configuration of all NICs assigned to a VM. A list of maps, each map is a NIC definition. Notice that the order DOES matter. NICs are attached to VMs in Azure in the order they are defined in this list, therefore the management interface has to be defined first. Following properties are available:
  - `name`: string that will form the NIC name
  - `subnet_key` : (string) a key of a subnet as defined in `var.vnets`
  - `create_pip` : (boolean) flag to create Public IP for an interface, defaults to `false`
  - `public_ip_name` : (string) when `create_pip` is set to `false` a name of a Public IP resource that should be associated with this Network Interface
  - `public_ip_resource_group` : (string) when associating an existing Public IP resource, name of the Resource Group the IP is placed in, defaults to the `var.resource_group_name`
  - `private_ip_address` : (string) a static IP address that should be assigned to an interface, defaults to `null` (in that case DHCP is used)

- `logging_disks` : a map containing configuration of additional disks that should be attached to a Panorama appliance. Following properties are available:
  - `size` : size of a disk, 2TB by default
  - `lun` : slot to which the disk should be attached
  - `disk_type` : type of a disk, determines throughput, `Standard_LRS` by default.

Example:

```
  {
    "pn-1" = {
      name     = "panorama01"
      vnet_key = "vnet"
      interfaces = [
        {
          name               = "management"
          subnet_key         = "panorama"
          private_ip_address = "10.1.0.10"
          create_pip         = true
        },
      ]
    }
  }
```


Type: `any`

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>


### Outputs


#### `username`

Initial administrative username to use for VM-Series.

<sup>[back to list](#modules-outputs)</sup>
#### `password`

Initial administrative password to use for VM-Series.

<sup>[back to list](#modules-outputs)</sup>
#### `panorama_mgmt_ips`



<sup>[back to list](#modules-outputs)</sup>
<!-- END_TF_DOCS -->
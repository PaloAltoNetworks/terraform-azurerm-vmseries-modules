<!-- BEGIN_TF_DOCS -->


## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`name`](#name) | `string` | Name of a NAT Gateway.
[`resource_group_name`](#resource_group_name) | `string` | Name of a Resource Group hosting the NAT Gateway (either the existing one or the one that will be created).
[`location`](#location) | `string` | Azure region.
[`subnet_ids`](#subnet_ids) | `map(string)` | A map of subnet IDs what will be bound with this NAT Gateway.

## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`create_natgw`](#create_natgw) | `bool` | Triggers creation of a NAT Gateway when set to `true`.
[`tags`](#tags) | `map(string)` | A map of tags that will be assigned to resources created by this module.
[`zone`](#zone) | `string` | Controls if the NAT Gateway will be bound to a specific zone or not.
[`idle_timeout`](#idle_timeout) | `number` | Connection IDLE timeout in minutes.
[`create_pip`](#create_pip) | `bool` | Set `true` to create a Public IP resource that will be connected to newly created NAT Gateway.
[`existing_pip_name`](#existing_pip_name) | `string` | Name of an existing Public IP resource to associate with the NAT Gateway.
[`existing_pip_resource_group_name`](#existing_pip_resource_group_name) | `string` | Name of a resource group hosting the Public IP resource specified in `existing_pip_name`.
[`create_pip_prefix`](#create_pip_prefix) | `bool` | Set `true` to create a Public IP Prefix resource that will be connected to newly created NAT Gateway.
[`pip_prefix_length`](#pip_prefix_length) | `number` | Number of bits of the Public IP Prefix.
[`existing_pip_prefix_name`](#existing_pip_prefix_name) | `string` | Name of an existing Public IP Prefix resource to associate with the NAT Gateway.
[`existing_pip_prefix_resource_group_name`](#existing_pip_prefix_resource_group_name) | `string` | Name of a resource group hosting the Public IP Prefix resource specified in `existing_pip_name`.

## Module's Outputs

Name |  Description
--- | ---
[`natgw_pip`](#natgw_pip) | 
[`natgw_pip_prefix`](#natgw_pip_prefix) | 

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

- `nat_gateway` (managed)
- `nat_gateway_public_ip_association` (managed)
- `nat_gateway_public_ip_prefix_association` (managed)
- `public_ip` (managed)
- `public_ip_prefix` (managed)
- `subnet_nat_gateway_association` (managed)
- `nat_gateway` (data)
- `public_ip` (data)
- `public_ip_prefix` (data)

## Inputs/Outpus details

### Required Inputs


#### name

Name of a NAT Gateway.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>


#### resource_group_name

Name of a Resource Group hosting the NAT Gateway (either the existing one or the one that will be created).

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>

#### location

Azure region. Only for newly created resources.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>




#### subnet_ids

A map of subnet IDs what will be bound with this NAT Gateway. Value is the subnet ID, key value does not matter but should be unique, typically it can be a subnet name.

Type: `map(string)`

<sup>[back to list](#modules-required-inputs)</sup>









### Optional Inputs



#### create_natgw

Triggers creation of a NAT Gateway when set to `true`.
  
Set it to `false` to source an existing resource. In this 'mode' the module will only bind an existing NAT Gateway to specified subnets.


Type: `bool`

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>



#### tags

A map of tags that will be assigned to resources created by this module. Only for newly created resources.

Type: `map(string)`

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### zone

Controls if the NAT Gateway will be bound to a specific zone or not. This is a string with the zone number or `null`. Only for newly created resources.

NAT Gateway is not zone-redundant. It is a zonal resource. It means that it's always deployed in a zone. It's up to the user to decide if a zone will be specified during resource deployment or if Azure will take that decision for the user. 
Keep in mind that regardless of the fact that NAT Gateway is placed in a specific zone it can serve traffic for resources in all zones. But if that zone becomes unavailable resources in other zones will loose internet connectivity. 

For design considerations, limitation and examples of zone-resiliency architecture please refer to [Microsoft documentation](https://learn.microsoft.com/en-us/azure/virtual-network/nat-gateway/nat-availability-zones).


Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### idle_timeout

Connection IDLE timeout in minutes. Only for newly created resources.

Type: `number`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>


#### create_pip

Set `true` to create a Public IP resource that will be connected to newly created NAT Gateway. Not used when NAT Gateway is only sourced.

Setting this property to `false` has two meanings:
* when `existing_pip_name` is `null` simply no Public IP will be created
* when `existing_pip_name` is set to a name of an exiting Public IP resource it will be sourced and associated to this NAT Gateway.


Type: `bool`

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>

#### existing_pip_name

Name of an existing Public IP resource to associate with the NAT Gateway. Only for newly created resources.

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### existing_pip_resource_group_name

Name of a resource group hosting the Public IP resource specified in `existing_pip_name`. When omitted Resource Group specified in `resource_group_name` will be used.

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### create_pip_prefix

Set `true` to create a Public IP Prefix resource that will be connected to newly created NAT Gateway. Not used when NAT Gateway is only sourced.

Setting this property to `false` has two meanings:
* when `existing_pip_prefix_name` is `null` simply no Public IP Prefix will be created
* when `existing_pip_prefix_name` is set to a name of an exiting Public IP Prefix resource it will be sourced and associated to this NAT Gateway.


Type: `bool`

Default value: `false`

<sup>[back to list](#modules-optional-inputs)</sup>

#### pip_prefix_length

Number of bits of the Public IP Prefix. This basically specifies how many IP addresses are reserved. Azure default is `/28`.

This value can be between `0` and `31` but can be limited by limits set on Subscription level.


Type: `number`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### existing_pip_prefix_name

Name of an existing Public IP Prefix resource to associate with the NAT Gateway. Only for newly created resources.

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### existing_pip_prefix_resource_group_name

Name of a resource group hosting the Public IP Prefix resource specified in `existing_pip_name`. When omitted Resource Group specified in `resource_group_name` will be used.

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>


### Outputs


#### `natgw_pip`



<sup>[back to list](#modules-outputs)</sup>
#### `natgw_pip_prefix`



<sup>[back to list](#modules-outputs)</sup>
<!-- END_TF_DOCS -->
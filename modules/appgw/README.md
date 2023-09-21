<!-- BEGIN_TF_DOCS -->


## Module's Required Inputs


- [`resource_group_name`](#resource_group_name)
- [`location`](#location)
- [`name`](#name)
- [`subnet_id`](#subnet_id)
- [`rules`](#rules)


### resource_group_name

Name of an existing resource group.

Type: `string`

### location

Location to place the Application Gateway in.

Type: `string`


### name

Name of the Application Gateway.

Type: `string`








### subnet_id

An ID of a subnet that will host the Application Gateway. Keep in mind that this subnet can contain only AppGWs and only of the same type.

Type: `string`


### rules

A map of rules for the Application Gateway. A rule combines listener, http settings and health check configuration. 
A key is an application name that is used to prefix all components inside Application Gateway that are created for this application. 

Details on configuration can be found [here](#rules-property-explained).


Type: `any`








## Module's Optional Inputs


- [`zones`](#zones)
- [`domain_name_label`](#domain_name_label)
- [`managed_identities`](#managed_identities)
- [`waf_enabled`](#waf_enabled)
- [`capacity`](#capacity)
- [`capacity_min`](#capacity_min)
- [`capacity_max`](#capacity_max)
- [`enable_http2`](#enable_http2)
- [`vmseries_ips`](#vmseries_ips)
- [`ssl_policy_type`](#ssl_policy_type)
- [`ssl_policy_name`](#ssl_policy_name)
- [`ssl_policy_min_protocol_version`](#ssl_policy_min_protocol_version)
- [`ssl_policy_cipher_suites`](#ssl_policy_cipher_suites)
- [`ssl_profiles`](#ssl_profiles)
- [`tags`](#tags)




### zones

A list of zones the Application Gateway should be available in.

NOTICE: this is also enforced on the Public IP. The Public IP object brings in some limitations as it can only be non-zonal, pinned to a single zone or zone-redundant (so available in all zones in a region). 
Therefore make sure that if you specify more than one zone you specify all available in a region. You can use a subset, but the Public IP will be created in all zones anyway. This fact will cause terraform to recreate the IP resource during next `terraform apply` as there will be difference between the state and the actual configuration.

For details on zones currently available in a region of your choice refer to [Microsoft's documentation](https://docs.microsoft.com/en-us/azure/availability-zones/az-region).

Example:
```
zones = ["1","2","3"]
```


Type: `list(string)`

Default value: `&{}`


### domain_name_label

Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system.

Type: `string`

Default value: `&{}`

### managed_identities

A list of existing User-Assigned Managed Identities, which Application Gateway uses to retrieve certificates from Key Vault.

These identities have to have at least `GET` access to Key Vault's secrets. Otherwise Application Gateway will not be able to use certificates stored in the Vault.


Type: `list(string)`

Default value: `&{}`

### waf_enabled

Enables WAF Application Gateway. This only sets the SKU. This module does not support WAF rules configuration.

Type: `bool`

Default value: `false`

### capacity

A number of Application Gateway instances. A value bewteen 1 and 125.

This property is not used when autoscaling is enabled.


Type: `number`

Default value: `2`

### capacity_min

When set enables autoscaling and becomes the minimum capacity.

Type: `number`

Default value: `&{}`

### capacity_max

Optional, maximum capacity for autoscaling.

Type: `number`

Default value: `&{}`

### enable_http2

Enable HTTP2 on the Application Gateway.

Type: `bool`

Default value: `false`


### vmseries_ips

IP addresses of VMSeries' interfaces that will serve as backends for the Application Gateway.

Type: `list(string)`

Default value: `[]`


### ssl_policy_type

Type of an SSL policy. Possible values are `Predefined` or `Custom`.
If the value is `Custom` the following values are mandatory: `ssl_policy_cipher_suites` and `ssl_policy_min_protocol_version`.


Type: `string`

Default value: `Predefined`

### ssl_policy_name

Name of an SSL policy. Supported only for `ssl_policy_type` set to `Predefined`. Normally you can set it also for `Custom` policies but the name is discarded on Azure side causing an update to Application Gateway each time terraform code is run. Therefore this property is omitted in the code for `Custom` policies. 
  
For the `Predefined` polcies, check the [Microsoft documentation](https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-ssl-policy-overview) for possible values as they tend to change over time. The default value is currently (Q1 2022) a Microsoft's default.


Type: `string`

Default value: `AppGwSslPolicy20220101S`

### ssl_policy_min_protocol_version

Minimum version of the TLS protocol for SSL Policy. Required only for `ssl_policy_type` set to `Custom`. 

Possible values are: `TLSv1_0`, `TLSv1_1`, `TLSv1_2` or `null` (only to be used with a `Predefined` policy).


Type: `string`

Default value: `TLSv1_2`

### ssl_policy_cipher_suites

A list of accepted cipher suites. Required only for `ssl_policy_type` set to `Custom`. 
For possible values see [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#cipher_suites).


Type: `list(string)`

Default value: `[TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384]`

### ssl_profiles

A map of SSL profiles that can be later on referenced in HTTPS listeners by providing a name of the profile in the `ssl_profile_name` property. 

The structure of the map is as follows:
```
{
  profile_name = {
    ssl_policy_type                 = string
    ssl_policy_min_protocol_version = string
    ssl_policy_cipher_suites        = list
  }
}
```
For possible values check the: `ssl_policy_type`, `ssl_policy_min_protocol_version` and `ssl_policy_cipher_suites` variables as SSL profile is a named SSL policy - same properties apply. The only difference is that you cannot name an SSL policy inside an SSL profile. 


Type: `map(any)`

Default value: `map[]`

### tags

Azure tags to apply to the created resources.

Type: `map(string)`

Default value: `map[]`


## Module's Outputs


- [`public_ip`](#public_ip)
- [`public_domain_name`](#public_domain_name)
- [`backend_pool_id`](#backend_pool_id)


* `public_ip`: A public IP assigned to the Application Gateway.
* `public_domain_name`: Public domain name assigned to the Application Gateway.
* `backend_pool_id`: The identifier of the Application Gateway backend address pool.

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

- `application_gateway` (managed)
- `public_ip` (managed)
<!-- END_TF_DOCS -->
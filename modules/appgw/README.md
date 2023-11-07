<!-- BEGIN_TF_DOCS -->
# Palo Alto Networks Virtual Network Gateway Module for Azure

A terraform module for deploying a Virtual Network Gateway and its components required for the VM-Series firewalls in Azure.

## Usage

For usage refer to variables description, which include example for complex map of objects.

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`name`](#name) | `string` | The name of the Application Gateway.
[`resource_group_name`](#resource_group_name) | `string` | The name of the Resource Group to use.
[`location`](#location) | `string` | The name of the Azure region to deploy the resources in.
[`public_ip_name`](#public_ip_name) | `string` | Name for the public IP address.
[`subnet_id`](#subnet_id) | `string` | An ID of a subnet that will host the Application Gateway.
[`ssl_profiles`](#ssl_profiles) | `map` | A map of SSL profiles.
[`listeners`](#listeners) | `map` | A map of listeners for the Application Gateway.
[`backend_pool`](#backend_pool) | `object` | Backend pool.
[`probes`](#probes) | `map` | A map of probes for the Application Gateway.
[`rewrites`](#rewrites) | `map` | A map of rewrites for the Application Gateway.
[`rules`](#rules) | `map` | A map of rules for the Application Gateway.
[`redirects`](#redirects) | `map` | A map of redirects for the Application Gateway.
[`url_path_maps`](#url_path_maps) | `map` | A map of URL path maps for the Application Gateway.


## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`tags`](#tags) | `map` | The map of tags to assign to all created resources.
[`zones`](#zones) | `list` | A list of zones the Application Gateway should be available in.
[`domain_name_label`](#domain_name_label) | `string` | Label for the Domain Name.
[`enable_http2`](#enable_http2) | `bool` | Enable HTTP2 on the Application Gateway.
[`waf_enabled`](#waf_enabled) | `bool` | Enables WAF Application Gateway.
[`capacity`](#capacity) | `number` | A number of Application Gateway instances.
[`capacity_min`](#capacity_min) | `number` | When set enables autoscaling and becomes the minimum capacity.
[`capacity_max`](#capacity_max) | `number` | Optional, maximum capacity for autoscaling.
[`managed_identities`](#managed_identities) | `list` | A list of existing User-Assigned Managed Identities.
[`ssl_policy_type`](#ssl_policy_type) | `string` | Type of an SSL policy.
[`ssl_policy_name`](#ssl_policy_name) | `string` | Name of an SSL policy.
[`ssl_policy_min_protocol_version`](#ssl_policy_min_protocol_version) | `string` | Minimum version of the TLS protocol for SSL Policy.
[`ssl_policy_cipher_suites`](#ssl_policy_cipher_suites) | `list` | A list of accepted cipher suites.
[`frontend_ip_configuration_name`](#frontend_ip_configuration_name) | `string` | Frontend IP configuration name.
[`backends`](#backends) | `map` | A map of backend settings for the Application Gateway.



## Module's Outputs

Name |  Description
--- | ---
`public_ip` | A public IP assigned to the Application Gateway.
`public_domain_name` | Public domain name assigned to the Application Gateway.
`backend_pool_id` | The identifier of the Application Gateway backend address pool.

## Module's Nameplate


Requirements needed by this module:

- `terraform`, version: >= 1.3, < 2.0
- `azurerm`, version: ~> 3.25


Providers used in this module:

- `azurerm`, version: ~> 3.25




Resources used in this module:

- `application_gateway` (managed)
- `public_ip` (managed)

## Inputs/Outpus details

### Required Inputs


#### name

The name of the Application Gateway.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>

#### resource_group_name

The name of the Resource Group to use.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>

#### location

The name of the Azure region to deploy the resources in.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>



#### public_ip_name

Name for the public IP address.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>








#### subnet_id

An ID of a subnet that will host the Application Gateway.

Keep in mind that this subnet can contain only AppGWs and only of the same type.


Type: string

<sup>[back to list](#modules-required-inputs)</sup>





#### ssl_profiles

A map of SSL profiles.

SSL profiles can be later on referenced in HTTPS listeners by providing a name of the profile in the `ssl_profile_name` property.
For possible values check the: `ssl_policy_type`, `ssl_policy_min_protocol_version` and `ssl_policy_cipher_suites`
variables as SSL profile is a named SSL policy - same properties apply.
The only difference is that you cannot name an SSL policy inside an SSL profile.

Every SSL profile contains attributes:
- `name`                            - (`string`, required) name of the SSL profile
- `ssl_policy_type`                 - (`string`, optional) the Type of the Policy.
- `ssl_policy_min_protocol_version` - (`string`, optional) the minimal TLS version.
- `ssl_policy_cipher_suites`        - (`list`, optional) a List of accepted cipher suites.


Type: 

```hcl
map(object({
    name                            = string
    ssl_policy_type                 = optional(string)
    ssl_policy_min_protocol_version = optional(string)
    ssl_policy_cipher_suites        = optional(list(string))
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>


#### listeners

A map of listeners for the Application Gateway.

Every listener contains attributes:
- `name`                     - (`string`, required) The name for this Frontend Port.
- `port`                     - (`string`, required) The port used for this Frontend Port.
- `protocol`                 - (`string`, optional) The Protocol to use for this HTTP Listener.
- `host_names`               - (`list`, optional) A list of Hostname(s) should be used for this HTTP Listener.
                               It allows special wildcard characters.
- `ssl_profile_name`         - (`string`, optional) The name of the associated SSL Profile which should be used for this HTTP Listener.
- `ssl_certificate_path`     - (`string`, optional) Path to the file with tThe base64-encoded PFX certificate data.
- `ssl_certificate_pass`     - (`string`, optional) Password for the pfx file specified in data.
- `ssl_certificate_vault_id` - (`string`, optional) Secret Id of (base-64 encoded unencrypted pfx) Secret
                               or Certificate object stored in Azure KeyVault.
- `custom_error_pages`       - (`map`, optional) Map of string, where key is HTTP status code and value is
                               error page URL of the application gateway customer error.


Type: 

```hcl
map(object({
    name                     = string
    port                     = number
    protocol                 = optional(string, "Http")
    host_names               = optional(list(string))
    ssl_profile_name         = optional(string)
    ssl_certificate_path     = optional(string)
    ssl_certificate_pass     = optional(string)
    ssl_certificate_vault_id = optional(string)
    custom_error_pages       = optional(map(string), {})
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>

#### backend_pool

Backend pool.

Object contains attributes:
- `name`         - (`string`, optional, defaults to `vmseries`) name of the backend pool.
- `vmseries_ips` - (`list`, optional, defaults to `[]`) IP addresses of VMSeries' interfaces that will serve as backends for the Application Gateway.


Type: 

```hcl
object({
    name         = optional(string, "vmseries")
    vmseries_ips = optional(list(string), [])
  })
```


<sup>[back to list](#modules-required-inputs)</sup>


#### probes

A map of probes for the Application Gateway.

Every probe contains attributes:
- `name`       - (`string`, required) The name used for this Probe
- `path`       - (`string`, required) The path used for this Probe
- `host`       - (`string`, optional) The hostname used for this Probe
- `port`       - (`number`, optional) Custom port which will be used for probing the backend servers.
- `protocol`   - (`string`, optional, defaults `Http`) The protocol which should be used.
- `interval`   - (`number`, optional, defaults `5`) The interval between two consecutive probes in seconds.
- `timeout`    - (`number`, optional, defaults `30`) The timeout used for this Probe, which indicates when a probe becomes unhealthy.
- `threshold`  - (`number`, optional, defaults `2`) The unhealthy Threshold for this Probe, which indicates
                 the amount of retries which should be attempted before a node is deemed unhealthy.
- `match_code` - (`list`, optional) The list of allowed status codes for this Health Probe.
- `match_body` - (`string`, optional) A snippet from the Response Body which must be present in the Response.


Type: 

```hcl
map(object({
    name       = string
    path       = string
    host       = optional(string)
    port       = optional(number)
    protocol   = optional(string, "Http")
    interval   = optional(number, 5)
    timeout    = optional(number, 30)
    threshold  = optional(number, 2)
    match_code = optional(list(number))
    match_body = optional(string)
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>

#### rewrites

A map of rewrites for the Application Gateway.

Every rewrite contains attributes:
- `name`                - (`string`) Rewrite Rule Set name
- `rules`               - (`object`, optional) Rewrite Rule Set defined with attributes:
    - `name`            - (`string`, required) Rewrite Rule name.
    - `sequence`        - (`number`, required) Rule sequence of the rewrite rule that determines the order of execution in a set.
    - `conditions`      - (`map`, optional) One or more condition blocks as defined below:
      - `pattern`       - (`string`, required) The pattern, either fixed string or regular expression,
                          that evaluates the truthfulness of the condition.
      - `ignore_case`   - (`string`, required) Perform a case in-sensitive comparison.
      - `negate`        - (`bool`, required) Negate the result of the condition evaluation.
    - `request_headers` - (`map`, optional) Map of request header, where header name is the key,
                          header value is the value of the object in the map.
    - `response_headers`- (`map`, optional) Map of response header, where header name is the key,
                          header value is the value of the object in the map.


Type: 

```hcl
map(object({
    name = string
    rules = optional(map(object({
      name     = string
      sequence = number
      conditions = optional(map(object({
        pattern     = string
        ignore_case = string
        negate      = bool
      })), {})
      request_headers  = optional(map(string), {})
      response_headers = optional(map(string), {})
    })))
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>

#### rules

A map of rules for the Application Gateway.

A rule combines, http settings and health check configuration.
A key is an application name that is used to prefix all components inside Application Gateway that are created for this application.

Every rule contains attributes:
- `name`         - (`string`, required) Rule name.
- `priority`     - (`string`, required) Rule evaluation order can be dictated by specifying an integer value from 1 to 20000 with 1 being the highest priority and 20000 being the lowest priority.
- `backend`      - (`string`, optional) Backend settings` key
- `listener`     - (`string`, required) Listener's key
- `rewrite`      - (`string`, optional) Rewrite's key
- `url_path_map` - (`string`, optional) URL Path Map's key
- `redirect`     - (`string`, optional) Redirect's ky


Type: 

```hcl
map(object({
    name         = string
    priority     = number
    backend      = optional(string)
    listener     = string
    rewrite      = optional(string)
    url_path_map = optional(string)
    redirect     = optional(string)
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>

#### redirects

A map of redirects for the Application Gateway.

Every redirect contains attributes:
- `name`                 - (`string`, required) The name of redirect.
- `type`                 - (`string`, required) The type of redirect. Possible values are Permanent, Temporary, Found and SeeOther
- `target_listener`      - (`string`, optional) The name of the listener to redirect to.
- `target_url`           - (`string`, optional) The URL to redirect the request to.
- `include_path`         - (`bool`, optional) Whether or not to include the path in the redirected URL.
- `include_query_string` - (`bool`, optional) Whether or not to include the query string in the redirected URL.


Type: 

```hcl
map(object({
    name                 = string
    type                 = string
    target_listener      = optional(string)
    target_url           = optional(string)
    include_path         = optional(bool, false)
    include_query_string = optional(bool, false)
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>

#### url_path_maps

A map of URL path maps for the Application Gateway.

Every URL path map contains attributes:
- `name`         - (`string`, required) The name of redirect.
- `backend`      - (`string`, required) The default backend for redirect.
- `path_rules`   - (`map`, optional) The map of rules, where every object has attributes:
    - `paths`    - (`list`, required) List of paths
    - `backend`  - (`string`, optional) Backend's key
    - `redirect` - (`string`, optional) Redirect's key


Type: 

```hcl
map(object({
    name    = string
    backend = string
    path_rules = optional(map(object({
      paths    = list(string)
      backend  = optional(string)
      redirect = optional(string)
    })))
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>



### Optional Inputs





#### tags

The map of tags to assign to all created resources.

Type: map(string)

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### zones

A list of zones the Application Gateway should be available in.

NOTICE: this is also enforced on the Public IP. The Public IP object brings in some limitations as it can only be non-zonal,
pinned to a single zone or zone-redundant (so available in all zones in a region).
Therefore make sure that if you specify more than one zone you specify all available in a region. You can use a subset,
but the Public IP will be created in all zones anyway. This fact will cause terraform to recreate the IP resource during
next `terraform apply` as there will be difference between the state and the actual configuration.

For details on zones currently available in a region of your choice refer to
[Microsoft's documentation](https://docs.microsoft.com/en-us/azure/availability-zones/az-region).

Example:
```
zones = ["1","2","3"]
```


Type: list(string)

Default value: `[1 2 3]`

<sup>[back to list](#modules-optional-inputs)</sup>


#### domain_name_label

Label for the Domain Name.

Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created
for the public IP in the Microsoft Azure DNS system."


Type: string

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### enable_http2

Enable HTTP2 on the Application Gateway.

Type: bool

Default value: `false`

<sup>[back to list](#modules-optional-inputs)</sup>

#### waf_enabled

Enables WAF Application Gateway. This only sets the SKU. This module does not support WAF rules configuration.

Type: bool

Default value: `false`

<sup>[back to list](#modules-optional-inputs)</sup>

#### capacity

A number of Application Gateway instances. A value bewteen 1 and 125.

This property is not used when autoscaling is enabled.


Type: number

Default value: `2`

<sup>[back to list](#modules-optional-inputs)</sup>

#### capacity_min

When set enables autoscaling and becomes the minimum capacity.

Type: number

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### capacity_max

Optional, maximum capacity for autoscaling.

Type: number

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### managed_identities

A list of existing User-Assigned Managed Identities.

Application Gateway uses Managed Identities to retrieve certificates from Key Vault.
These identities have to have at least `GET` access to Key Vault's secrets.
Otherwise Application Gateway will not be able to use certificates stored in the Vault.


Type: list(string)

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>


#### ssl_policy_type

Type of an SSL policy.

Possible values are `Predefined` or `Custom` or `CustomV2`.
If the value is `Custom` the following values are mandatory:
`ssl_policy_cipher_suites` and `ssl_policy_min_protocol_version`.


Type: string

Default value: `Predefined`

<sup>[back to list](#modules-optional-inputs)</sup>

#### ssl_policy_name

Name of an SSL policy.

Supported only for `ssl_policy_type` set to `Predefined`. Normally you can set it also
for `Custom` policies but the name is discarded on Azure side causing an update
to Application Gateway each time terraform code is run.
Therefore this property is omitted in the code for `Custom` policies.
For the `Predefined` polcies, check the
[Microsoft documentation](https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-ssl-policy-overview)
for possible values as they tend to change over time. The default value is currently (Q1 2023) a Microsoft's default.


Type: string

Default value: `AppGwSslPolicy20220101S`

<sup>[back to list](#modules-optional-inputs)</sup>

#### ssl_policy_min_protocol_version

Minimum version of the TLS protocol for SSL Policy.

Required only for `ssl_policy_type` set to `Custom`.
Possible values are: `TLSv1_0`, `TLSv1_1`, `TLSv1_2`, `TLSv1_3` or `null` (only to be used with a `Predefined` policy).


Type: string

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### ssl_policy_cipher_suites

A list of accepted cipher suites.

Required only for `ssl_policy_type` set to `Custom`.
For possible values see [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#cipher_suites).


Type: list(string)

Default value: `[TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384]`

<sup>[back to list](#modules-optional-inputs)</sup>


#### frontend_ip_configuration_name

Frontend IP configuration name

Type: string

Default value: `public_ipconfig`

<sup>[back to list](#modules-optional-inputs)</sup>



#### backends

A map of backend settings for the Application Gateway.

Every backend contains attributes:
- `name`                  - (`string`, optional) The name of the backend settings
- `path`                  - (`string`, optional) The Path which should be used as a prefix for all HTTP requests.
- `hostname_from_backend` - (`bool`, optional) Whether host header should be picked from the host name of the backend server.
- `hostname`              - (`string`, optional) Host header to be sent to the backend servers.
- `port`                  - (`number`, required) The port which should be used for this Backend HTTP Settings Collection.
- `protocol`              - (`string`, required) The Protocol which should be used. Possible values are Http and Https.
- `timeout`               - (`number`, required) The request timeout in seconds, which must be between 1 and 86400 seconds.
- `cookie_based_affinity` - (`string`, required) Is Cookie-Based Affinity enabled? Possible values are Enabled and Disabled.
- `affinity_cookie_name`  - (`string`, optional) The name of the affinity cookie.
- `probe`                 - (`string`, optional) Probe's key.
- `root_certs`            - (`map`, optional) A list of trusted_root_certificate names.


Type: 

```hcl
map(object({
    name                  = optional(string)
    path                  = optional(string)
    hostname_from_backend = optional(bool, false)
    hostname              = optional(string)
    port                  = optional(number, 80)
    protocol              = optional(string, "Http")
    timeout               = optional(number, 60)
    cookie_based_affinity = optional(string, "Enabled")
    affinity_cookie_name  = optional(string)
    probe                 = optional(string)
    root_certs = optional(map(object({
      name = string
      path = string
    })), {})
  }))
```


Default value: `map[vmseries:map[cookie_based_affinity:Enabled port:80 protocol:Http timeout:60]]`

<sup>[back to list](#modules-optional-inputs)</sup>







<!-- END_TF_DOCS -->
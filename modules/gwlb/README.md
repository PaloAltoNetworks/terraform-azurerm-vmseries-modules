<!-- BEGIN_TF_DOCS -->
# Gateway Load Balancer Module for Azure

A Terraform module for deploying a Gateway Load Balancer for VM-Series firewalls.

## Usage

For usage see any of the reference architecture examples.

...
TODO: examples
...

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`name`](#name) | `string` | The name of the Azure Load Balancer.
[`resource_group_name`](#resource_group_name) | `string` | The name of the Resource Group to use.
[`location`](#location) | `string` | The name of the Azure region to deploy the resources in.
[`frontend_ip`](#frontend_ip) | `object` | Frontend IP configuration of the gateway load balancer.
[`health_probes`](#health_probes) | `map` | Health probe configuration for the gateway load balancer backends.


## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`tags`](#tags) | `map` | The map of tags to assign to all created resources.
[`zones`](#zones) | `list` | Controls zones for Gateway Load Balancer's Fronted IP configurations.
[`backends`](#backends) | `map` | Map with backend configurations for the gateway load balancer.
[`lb_rule`](#lb_rule) | `map` | Load balancing rule config.



## Module's Outputs

Name |  Description
--- | ---
`backend_pool_ids` | Backend pools' identifiers.
`frontend_ip_config_id` | Frontend IP configuration identifier.

## Module's Nameplate


Requirements needed by this module:

- `terraform`, version: >= 1.3, < 2.0
- `azurerm`, version: ~> 3.25


Providers used in this module:

- `azurerm`, version: ~> 3.25




Resources used in this module:

- `lb` (managed)
- `lb_backend_address_pool` (managed)
- `lb_probe` (managed)
- `lb_rule` (managed)

## Inputs/Outpus details

### Required Inputs


#### name

The name of the Azure Load Balancer.

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



#### frontend_ip

Frontend IP configuration of the gateway load balancer.

Following settings are available:
- `name`                          - (Required|string) Name of the frontend IP configuration. `var.name` by default.
- `subnet_id`                     - (Required|string) Id of a subnet to associate with the configuration.
- `private_ip_address`            - (Optional|string) Private IP address to assign.
- `private_ip_address_allocation` - (Optional|string) The allocation method for the private IP address.
- `private_ip_address_version`    - (Optional|string) The IP version for the private IP address.


Type: 

```hcl
object({
    name                          = string
    subnet_id                     = string
    private_ip_address            = optional(string)
    private_ip_address_allocation = optional(string)
    private_ip_address_version    = optional(string)
  })
```


<sup>[back to list](#modules-required-inputs)</sup>

#### health_probes

Health probe configuration for the gateway load balancer backends.

Following settings are available:
- `name`                - (Optional|string) Name of the health probe. Defaults to `name` variable value.
- `port`                - (Required|int)
- `protocol`            - (Optional|string)
- `probe_threshold`     - (Optional|int)
- `request_path`        - (Optional|string)
- `interval_in_seconds` - (Optional|int)
- `number_of_probes`    - (Optional|int)

For details, please refer to [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe#argument-reference).


Type: 

```hcl
map(object({
    name                = optional(string)
    port                = number
    protocol            = optional(string)
    probe_threshold     = optional(number)
    request_path        = optional(string)
    interval_in_seconds = optional(number)
    number_of_probes    = optional(number)
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

Controls zones for Gateway Load Balancer's Fronted IP configurations.

Setting this variable to explicit `null` disables a zonal deployment.
This can be helpful in regions where Availability Zones are not available.


Type: list(string)

Default value: `[1 2 3]`

<sup>[back to list](#modules-optional-inputs)</sup>



#### backends

Map with backend configurations for the gateway load balancer. Azure GWLB rule can have up to two backends.

Following settings are available:
- `name`              - (Optional|string) Name of the backend. If not specified name is generated from `name` variable and backend key.
- `tunnel_interfaces` - (Required|map) Map with tunnel interfaces specs.)

Each tunnel interface specification consists of following settings (refer to [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool#tunnel_interface) for details):
- `identifier` - (Required|int) Interface identifier.
- `port`       - (Required|int) Interface port.
- `type`       - (Required|string) Either "External" or "Internal".

If one backend is specified, it has to have both external and internal tunnel interfaces specified.
For two backends, each has to have exactly one.

On GWLB inspection enabled VM-Series instance, `identifier` and `port` default to:
- `800`/`2000` for `Internal` tunnel type
- `801`/`2001` for `External` tunnel type
Variable default reflects this configuration on GWLB side. Additionally, for VM-Series tunnel interface protocol is always VXLAN.


Type: 

```hcl
map(object({
    name = optional(string)
    tunnel_interfaces = map(object({
      identifier = number
      port       = number
      protocol   = optional(string, "VXLAN")
      type       = string
    }))
  }))
```


Default value: `map[ext-int:map[tunnel_interfaces:map[external:map[identifier:801 port:2001 protocol:VXLAN type:External] internal:map[identifier:800 port:2000 protocol:VXLAN type:Internal]]]]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### lb_rule

Load balancing rule config.

Available options:
- `name`              - (Optional|string) Name for the rule. Defaults to `var.frontend_ip_config.name`.
- `load_distribution` - (Optional|string) Refer to [provider docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule#load_distribution).


Type: map(string)

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>


<!-- END_TF_DOCS -->
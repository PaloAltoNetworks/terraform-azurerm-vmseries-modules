<!-- BEGIN_TF_DOCS -->
# Gateway Load Balancer Module for Azure

A Terraform module for deploying a Gateway Load Balancer for VM-Series firewalls.

## Usage

For usage see example `gwlb_with_vmseries`.

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`name`](#name) | `string` | The name of the Azure Load Balancer.
[`resource_group_name`](#resource_group_name) | `string` | The name of the Resource Group to use.
[`location`](#location) | `string` | The name of the Azure region to deploy the resources in.
[`frontend_ips`](#frontend_ips) | `map` | Map of frontend IP configurations of the Gateway Load Balancer.
[`health_probes`](#health_probes) | `map` | Map of health probes configuration for the Gateway Load Balancer backends.


## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`tags`](#tags) | `map` | The map of tags to assign to all created resources.
[`zones`](#zones) | `list` | Controls zones for Gateway Load Balancer's Fronted IP configurations.
[`backends`](#backends) | `map` | Map with backend configurations for the Gateway Load Balancer.
[`lb_rules`](#lb_rules) | `map` | Map of load balancing rules configuration.



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



#### frontend_ips

Map of frontend IP configurations of the Gateway Load Balancer.

Following settings are available:
- `name`                          - (`string`, required) name of the frontend IP configuration. `var.name` by default.
- `subnet_id`                     - (`string`, required) id of a subnet to associate with the configuration.
- `private_ip_address`            - (`string`, optional) private IP address to assign.
- `private_ip_address_allocation` - (`string`, optional, defaults to `Dynamic`) the allocation method for the private IP address.
- `private_ip_address_version`    - (`string`, optional, defaults to `IPv4`) the IP version for the private IP address.


Type: 

```hcl
map(object({
    name                          = string
    subnet_id                     = string
    private_ip_address            = optional(string)
    private_ip_address_allocation = optional(string, "Dynamic")
    private_ip_address_version    = optional(string, "IPv4")
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>

#### health_probes

Map of health probes configuration for the Gateway Load Balancer backends.

Following settings are available:
- `name`                - (`string`, optional) name of the health probe. Defaults to `name` variable value.
- `port`                - (`number`, required) port to run the probe against
- `protocol`            - (`string`, optional, defaults to `Tcp`) protocol used by the health probe,
                          can be one of "Tcp", "Http" or "Https".
- `probe_threshold`     - (`number`, optional) number of consecutive probes that decide on forwarding traffic to an endpoin.
- `request_path`        - (`string`, optional) used only for non `Tcp` probes,
                          the URI used to check the endpoint status when `protocol` is set to `Http(s)`
- `interval_in_seconds` - (`number`, optional) interval in seconds between probes, with a minimal value of 5
- `number_of_probes`    - (`number`, optional)


Type: 

```hcl
map(object({
    name                = optional(string)
    port                = number
    protocol            = optional(string, "Tcp")
    interval_in_seconds = optional(number)
    probe_threshold     = optional(number)
    request_path        = optional(string)
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

Map with backend configurations for the Gateway Load Balancer. Azure GWLB rule can have up to two backends.

Following settings are available:
- `name`              - (`string`, optional) name of the backend.
                        If not specified name is generated from `name` variable and backend key.
- `tunnel_interfaces` - (`map`, required) map with tunnel interfaces.

Each tunnel interface specification consists of following settings:
- `identifier` - (`number`, required) interface identifier.
- `port`       - (`number`, required) interface port.
- `type`       - (`string`, required) either "External" or "Internal".

If one backend is specified, it has to have both external and internal tunnel interfaces specified.
For two backends, each has to have exactly one.

On GWLB inspection enabled VM-Series instance, `identifier` and `port` default to:
- `800`/`2000` for `Internal` tunnel type
- `801`/`2001` for `External` tunnel type

Variable default reflects this configuration on GWLB side.
Additionally, for VM-Series tunnel interface protocol is always VXLAN.


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

#### lb_rules

Map of load balancing rules configuration.

Available options:
- `name`              - (`string`, optional) name for the rule.
- `load_distribution` - (`string`, optional, defaults to `Default`) specifies the load balancing distribution type
                        to be used by the Gateway Load Balancer.
- `backend_key`       - (`string`, optional) key of the backend
- `health_probe_key`  - (`string`, optional, defaults to `default`) key of the health probe assigned to LB rule.


Type: 

```hcl
map(object({
    name              = optional(string)
    load_distribution = optional(string, "Default")
    backend_key       = optional(string)
    health_probe_key  = optional(string, "default")
  }))
```


Default value: `map[default-rule:map[]]`

<sup>[back to list](#modules-optional-inputs)</sup>


<!-- END_TF_DOCS -->
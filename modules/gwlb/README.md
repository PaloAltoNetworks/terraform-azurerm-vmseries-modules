<!-- BEGIN_TF_DOCS -->


## Module's Required Inputs


- [`name`](#name)
- [`resource_group_name`](#resource_group_name)
- [`location`](#location)
- [`frontend_ip_config`](#frontend_ip_config)
- [`health_probe`](#health_probe)


### name

The name of the gateway load balancer.

Type: `string`

### resource_group_name

Name of a pre-existing resource group to place resources in.

Type: `string`

### location

Region to deploy load balancer and related resources in.

Type: `string`

### frontend_ip_config

Frontend IP configuration of the gateway load balancer. Following settings are available:
- `name`                          - (Optional|string) Name of the frontend IP configuration. `var.name` by default.
- `private_ip_address_allocation` - (Optional|string) The allocation method for the private IP address.
- `private_ip_address_version`    - (Optional|string) The IP version for the private IP address.
- `private_ip_address`            - (Optional|string) Private IP address to assign.
- `subnet_id`                     - (Required|string) Id of a subnet to associate with the configuration.
- `zones`                         - (Optional|list) List of AZs in which the IP address will be located in.


Type: `any`

### health_probe

Health probe configuration for the gateway load balancer backends. Following settings are available:
- `name`                - (Optional|string) Name of the health probe. Defaults to `name` variable value.
- `port`                - (Required|int)
- `protocol`            - (Optional|string)
- `probe_threshold`     - (Optional|int)
- `request_path`        - (Optional|string)
- `interval_in_seconds` - (Optional|int)
- `number_of_probes`    - (Optional|int)
  
For details, please refer to [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe#argument-reference).


Type: `map(any)`





## Module's Optional Inputs


- [`backends`](#backends)
- [`lb_rule`](#lb_rule)
- [`tags`](#tags)







### backends

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


Type: `map(any)`

Default value: `map[ext-int:map[tunnel_interfaces:map[external:map[identifier:801 port:2001 protocol:VXLAN type:External] internal:map[identifier:800 port:2000 protocol:VXLAN type:Internal]]]]`

### lb_rule

Load balancing rule config. Available options:
- `name`              - (Optional|string) Name for the rule. Defaults to `var.frontend_ip_config.name`.
- `load_distribution` - (Optional|string) Refer to [provider docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule#load_distribution).


Type: `map(string)`

Default value: `&{}`

### tags

Azure tags to apply to the created resources.

Type: `map(string)`

Default value: `map[]`


## Module's Outputs


- [`backend_pool_ids`](#backend_pool_ids)
- [`frontend_ip_config_id`](#frontend_ip_config_id)


* `backend_pool_ids`: Backend pools' identifiers.
* `frontend_ip_config_id`: Frontend IP configuration identifier.

## Module's Nameplate

Requirements needed by this module:

- `terraform`, version: >= 1.0, < 2.0
- `azurerm`, version: ~> 3.25

Providers used in this module:

- `azurerm`, version: ~> 3.25

Modules used in this module:
Name | Version | Source | Description
--- | --- | --- | ---

Resources used in this module:

- `lb` (managed)
- `lb_backend_address_pool` (managed)
- `lb_probe` (managed)
- `lb_rule` (managed)
<!-- END_TF_DOCS -->
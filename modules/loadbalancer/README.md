<!-- BEGIN_TF_DOCS -->


## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`frontend_ips`](#frontend_ips) | `any` | A map of objects describing LB Frontend IP configurations, inbound and outbound rules.
[`resource_group_name`](#resource_group_name) | `string` | Name of a pre-existing Resource Group to place the resources in.
[`location`](#location) | `string` | Region to deploy load balancer and dependencies.
[`name`](#name) | `string` | The name of the load balancer.

## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`backend_name`](#backend_name) | `string` | The name of the backend pool to create.
[`probe_name`](#probe_name) | `string` | The name of the load balancer probe.
[`probe_port`](#probe_port) | `string` | Health check port number of the load balancer probe.
[`network_security_allow_source_ips`](#network_security_allow_source_ips) | `list(string)` | List of IP CIDR ranges (such as `["192.
[`network_security_resource_group_name`](#network_security_resource_group_name) | `string` | Name of the Resource Group where the `network_security_group_name` resides.
[`network_security_group_name`](#network_security_group_name) | `string` | Name of the pre-existing Network Security Group (NSG) where to add auto-generated rules.
[`network_security_base_priority`](#network_security_base_priority) | `number` | The base number from which the auto-generated priorities of the NSG rules grow.
[`enable_zones`](#enable_zones) | `bool` | If `false`, all the subnet-associated frontends and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting).
[`tags`](#tags) | `map(string)` | Azure tags to apply to the created resources.
[`avzones`](#avzones) | `list(string)` | Controls zones for load balancer's Fronted IP configurations.

## Module's Outputs

Name |  Description
--- | ---
[`backend_pool_id`](#backend_pool_id) | The identifier of the backend pool
[`frontend_ip_configs`](#frontend_ip_configs) | Map of IP addresses, one per each entry of `frontend_ips` input
[`health_probe`](#health_probe) | The health probe object

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

- `lb` (managed)
- `lb_backend_address_pool` (managed)
- `lb_outbound_rule` (managed)
- `lb_probe` (managed)
- `lb_rule` (managed)
- `network_security_rule` (managed)
- `public_ip` (managed)
- `public_ip` (data)

## Inputs/Outpus details

### Required Inputs


#### frontend_ips

A map of objects describing LB Frontend IP configurations, inbound and outbound rules. Used for both public or private load balancers. 
Keys of the map are names of LB Frontend IP configurations.

Each Frontend IP configuration can have multiple rules assigned. They are defined in a maps called `in_rules` and `out_rules` for inbound and outbound rules respectively. A key in this map is the name of the rule, while value is the actual rule configuration. To understand this structure please see examples below.

**Inbound rules.**

Here is a list of properties supported by each `in_rule`:

- `protocol` : required, communication protocol, either 'Tcp', 'Udp' or 'All'.
- `port` : required, communication port, this is both the front- and the backend port if `backend_port` is not given.
- `backend_port` : optional, this is the backend port to forward traffic to in the backend pool.
- `floating_ip` : optional, defaults to `true`, enables floating IP for this rule.
- `session_persistence` : optional, defaults to 5 tuple (Azure default), see `Session persistence/Load distribution` below for details.

Public LB

- `create_public_ip` : Optional. Set to `true` to create a public IP.
- `public_ip_name` : Ignored if `create_public_ip` is `true`. The existing public IP resource name to use.
- `public_ip_resource_group` : Ignored if `create_public_ip` is `true` or if `public_ip_name` is null. The name of the resource group which holds `public_ip_name`.

Example

```
frontend_ips = {
  pip_existing = {
    create_public_ip         = false
    public_ip_name           = "my_ip"
    public_ip_resource_group = "my_rg_name"
    in_rules = {
      HTTP = {
        port         = 80
        protocol     = "Tcp"
      }
    }
  }
}
```

Forward to a different port on backend pool

```
frontend_ips = {
  pip_existing = {
    create_public_ip         = false
    public_ip_name           = "my_ip"
    public_ip_resource_group = "my_rg_name"
    in_rules = {
      HTTP = {
        port         = 80
        backend_port = 8080
        protocol     = "Tcp"
      }
    }
  }
}
```

Private LB

- `subnet_id` : Identifier of an existing subnet. This also trigger creation of an internal LB.
- `private_ip_address` : A static IP address of the Frontend IP configuration, has to be in limits of the subnet's (specified by `subnet_id`) address space. When not set, changes the address allocation from `Static` to `Dynamic`.

Example

```
frontend_ips = {
  internal_fe = {
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address            = "192.168.0.10"
    in_rules = {
      HA_PORTS = {
        port         = 0
        protocol     = "All"
      }
    }
  }
}
```

Session persistence/Load distribution

By default the Load Balancer uses a 5 tuple hash to map traffic to available servers. This can be controlled using `session_persistence` property defined inside a rule. Available values are:

- `Default` : this is the 5 tuple hash - this method is also used when no property is defined
- `SourceIP` : a 2 tuple hash is used
- `SourceIPProtocol` : a 3 tuple hash is used

Example

```
  frontend_ips = {
    rule_1 = {
      create_public_ip = true
      in_rules = {
        HTTP = {
          port     = 80
          protocol = "Tcp"
          session_persistence = "SourceIP"
        }
      }
    }
  }
```

**Outbound rules.**

Each Frontend IP config can have outbound rules specified. Setting at least one `out_rule` switches the outgoing traffic from SNAT to Outbound rules. Keep in mind that since we use a single backend, and you cannot mix SNAT and Outbound rules traffic in rules using the same backend, setting one `out_rule` switches the outgoing traffic route for **ALL** `in_rules`.

Following properties are available:

- `protocol` : Protocol used by the rule. On of `All`, `Tcp` or `Udp` is accepted.
- `allocated_outbound_ports` : Number of ports allocated per instance. Defaults to `1024`.
- `enable_tcp_reset` : Ignored when `protocol` is set to `Udp`, defaults to `False` (Azure defaults).
- `idle_timeout_in_minutes` : Ignored when `protocol` is set to `Udp`. TCP connection timeout in case the connection is idle. Defaults to 4 minutes (Azure defaults).

Example:

```
frontend_ips = {
  rule_1 = {
    create_public_ip = true
    in_rules = {
      HTTP = {
        port     = 80
        protocol = "Tcp"
        session_persistence = "SourceIP"
      }
    }
    out_rules = {
      "outbound_tcp" = {
        protocol                 = "Tcp"
        allocated_outbound_ports = 2048
        enable_tcp_reset         = true
        idle_timeout_in_minutes  = 10
      }
    }
  }
}



Type: `any`

<sup>[back to list](#modules-required-inputs)</sup>

#### resource_group_name

Name of a pre-existing Resource Group to place the resources in.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>

#### location

Region to deploy load balancer and dependencies.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>


#### name

The name of the load balancer.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>











### Optional Inputs





#### backend_name

The name of the backend pool to create. All the frontends of the load balancer always use the same single backend.


Type: `string`

Default value: `vmseries_backend`

<sup>[back to list](#modules-optional-inputs)</sup>


#### probe_name

The name of the load balancer probe.

Type: `string`

Default value: `vmseries_probe`

<sup>[back to list](#modules-optional-inputs)</sup>

#### probe_port

Health check port number of the load balancer probe.

Type: `string`

Default value: `80`

<sup>[back to list](#modules-optional-inputs)</sup>

#### network_security_allow_source_ips

List of IP CIDR ranges (such as `["192.168.0.0/16"]` or `["*"]`) from which the inbound traffic to all frontends should be allowed.
If it's empty, user is responsible for configuring a Network Security Group separately.
The list cannot include Azure tags like "Internet" or "Sql.EastUS".


Type: `list(string)`

Default value: `[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### network_security_resource_group_name

Name of the Resource Group where the `network_security_group_name` resides. If empty, defaults to `resource_group_name`.

Type: `string`

Default value: ``

<sup>[back to list](#modules-optional-inputs)</sup>

#### network_security_group_name

Name of the pre-existing Network Security Group (NSG) where to add auto-generated rules. Each NSG rule corresponds to a single `in_rule` on the load balancer.
User is responsible to associate the NSG with the load balancer's subnet, the module only supplies the rules.
If empty, user is responsible for configuring an NSG separately.


Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### network_security_base_priority

The base number from which the auto-generated priorities of the NSG rules grow.
Ignored if `network_security_group_name` is empty or if `network_security_allow_source_ips` is empty.


Type: `number`

Default value: `1000`

<sup>[back to list](#modules-optional-inputs)</sup>

#### enable_zones

If `false`, all the subnet-associated frontends and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones.

Type: `bool`

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>

#### tags

Azure tags to apply to the created resources.

Type: `map(string)`

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### avzones

Controls zones for load balancer's Fronted IP configurations. For:

* public IPs - these are regions in which the IP resource is available
* private IPs - this represents Zones to which Azure will deploy paths leading to this Frontend IP.

For public IPs, after provider version 3.x (Azure API upgrade) you need to specify all zones available in a region (typically 3), ie: for zone-redundant with 3 availability zone in current region value will be:
```["1","2","3"]```


Type: `list(string)`

Default value: `[]`

<sup>[back to list](#modules-optional-inputs)</sup>


### Outputs


#### `backend_pool_id`

The identifier of the backend pool.

<sup>[back to list](#modules-outputs)</sup>
#### `frontend_ip_configs`

Map of IP addresses, one per each entry of `frontend_ips` input. Contains public IP address for the frontends that have it, private IP address otherwise.

<sup>[back to list](#modules-outputs)</sup>
#### `health_probe`

The health probe object.

<sup>[back to list](#modules-outputs)</sup>
<!-- END_TF_DOCS -->
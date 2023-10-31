<!-- BEGIN_TF_DOCS -->
# Palo Alto Networks Virtual Network Gateway Module for Azure

A terraform module for deploying a VNG (Virtual Network Gateway) and its components required for the VM-Series firewalls in Azure.

## Usage

In order to use module `virtual_network_gateway`, you need to deploy `azurerm_resource_group` and use module `vnet` as prerequisites.
Then you can use below code as an example of calling module to create VNG:

```hcl
module "vng" {
  source = "../../modules/virtual_network_gateway"

  for_each = var.virtual_network_gateways

  location            = var.location
  resource_group_name = local.resource_group.name
  name                = each.value.name
  zones               = each.value.avzones

  type     = each.value.type
  vpn_type = each.value.vpn_type
  sku      = each.value.sku

  active_active                    = each.value.active_active
  default_local_network_gateway_id = each.value.default_local_network_gateway_id
  edge_zone                        = each.value.edge_zone
  enable_bgp                       = each.value.enable_bgp
  generation                       = each.value.generation
  private_ip_address_enabled       = each.value.private_ip_address_enabled

  ip_configuration = [
    for ip_configuration in each.value.ip_configuration :
    merge(ip_configuration, { subnet_id = module.vnet[ip_configuration.vnet_key].subnet_ids[ip_configuration.subnet_name] })
  ]

  vpn_client_configuration  = each.value.vpn_client_configuration
  azure_bgp_peers_addresses = each.value.azure_bgp_peers_addresses
  local_bgp_settings        = each.value.local_bgp_settings
  custom_route              = each.value.custom_route
  ipsec_shared_key          = each.value.ipsec_shared_key
  local_network_gateways    = each.value.local_network_gateways
  connection_mode           = each.value.connection_mode
  ipsec_policy              = each.value.ipsec_policy

  tags = var.tags
}
```

Below there are provided sample values for `virtual_network_gateways` map:

```hcl
virtual_network_gateways = {
  "vng" = {
    name          = "vng"
    type          = "Vpn"
    sku           = "VpnGw2"
    generation    = "Generation2"
    active_active = true
    enable_bgp    = true
    ip_configuration = [
      {
        name             = "001"
        create_public_ip = true
        public_ip_name   = "pip1"
        vnet_key         = "transit"
        subnet_name      = "GatewaySubnet"
      },
      {
        name             = "002"
        create_public_ip = true
        public_ip_name   = "pip2"
        vnet_key         = "transit"
        subnet_name      = "GatewaySubnet"
      }
    ]
    ipsec_shared_key = "test123"
    azure_bgp_peers_addresses = {
      primary_1   = "169.254.21.2"
      secondary_1 = "169.254.22.2"
    }
    local_bgp_settings = {
      asn = "65002"
      peering_addresses = {
        "001" = {
          apipa_addresses = ["primary_1"]
        },
        "002" = {
          apipa_addresses = ["secondary_1"]
        }
      }
    }
    local_network_gateways = {
      "lg1" = {
        local_ng_name   = "lg1"
        connection_name = "cn1"
        gateway_address = "8.8.8.8"
        remote_bgp_settings = [{
          asn                 = "65000"
          bgp_peering_address = "169.254.21.1"
        }]
        custom_bgp_addresses = [
          {
            primary   = "primary_1"
            secondary = "secondary_1"
          }
        ]
      },
      "lg2" = {
        local_ng_name   = "lg2"
        connection_name = "cn2"
        gateway_address = "4.4.4.4"
        remote_bgp_settings = [{
          asn                 = "65000"
          bgp_peering_address = "169.254.22.1"
        }]
        custom_bgp_addresses = [
          {
            primary   = "primary_1"
            secondary = "secondary_1"
          }
        ]
      }
    }
    connection_mode = "InitiatorOnly"
    ipsec_policy = [
      {
        dh_group         = "ECP384"
        ike_encryption   = "AES256"
        ike_integrity    = "SHA256"
        ipsec_encryption = "AES256"
        ipsec_integrity  = "SHA256"
        pfs_group        = "ECP384"
        sa_datasize      = "102400000"
        sa_lifetime      = "14400"
      }
    ]
  }
}
```

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`name`](#name) | `string` | The name of the Virtual Network Gateway.
[`resource_group_name`](#resource_group_name) | `string` | The name of the Resource Group to use.
[`location`](#location) | `string` | The name of the Azure region to deploy the resources in.
[`default_local_network_gateway_id`](#default_local_network_gateway_id) | `string` | The ID of the local network gateway.
[`edge_zone`](#edge_zone) | `string` | Specifies the Edge Zone within the Azure Region where this Virtual Network Gateway should exist.
[`vpn_client_configuration`](#vpn_client_configuration) | `list` | VPN client configurations (IPSec point-to-site connections).
[`local_bgp_settings`](#local_bgp_settings) | `object` | BGP settings.
[`local_network_gateways`](#local_network_gateways) | `map` | Map of local network gateways.
[`ipsec_shared_key`](#ipsec_shared_key) | `string` | The shared IPSec key.
[`ipsec_policies`](#ipsec_policies) | `list` | IPsec policies used for Virtual Network Connection.


## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`tags`](#tags) | `map` | The map of tags to assign to all created resources.
[`type`](#type) | `string` | The type of the Virtual Network Gateway.
[`vpn_type`](#vpn_type) | `string` | The routing type of the Virtual Network Gateway.
[`sku`](#sku) | `string` | Configuration of the size and capacity of the virtual network gateway.
[`active_active`](#active_active) | `bool` | Active-active Virtual Network Gateway.
[`enable_bgp`](#enable_bgp) | `bool` | Controls whether BGP (Border Gateway Protocol) will be enabled for this Virtual Network Gateway.
[`generation`](#generation) | `string` | The Generation of the Virtual Network gateway.
[`private_ip_address_enabled`](#private_ip_address_enabled) | `bool` | Controls whether the private IP is enabled on the gateway.
[`zones`](#zones) | `list` | After provider version 3.
[`ip_configuration`](#ip_configuration) | `list` | IP configurations.
[`azure_bgp_peers_addresses`](#azure_bgp_peers_addresses) | `map` | Map of IP addresses used on Azure side for BGP.
[`custom_route`](#custom_route) | `list` | List of custom routes.
[`connection_type`](#connection_type) | `string` | The type of VNG connection.
[`connection_mode`](#connection_mode) | `string` | The connection mode to use.



## Module's Outputs

Name |  Description
--- | ---
`public_ip` | Public IP addresses for Virtual Network Gateway
`ipsec_policy` | IPsec policy used for Virtual Network Gateway connection

## Module's Nameplate


Requirements needed by this module:

- `terraform`, version: >= 1.3, < 2.0
- `azurerm`, version: ~> 3.25


Providers used in this module:

- `azurerm`, version: ~> 3.25




Resources used in this module:

- `local_network_gateway` (managed)
- `public_ip` (managed)
- `virtual_network_gateway` (managed)
- `virtual_network_gateway_connection` (managed)
- `public_ip` (data)

## Inputs/Outpus details

### Required Inputs


#### name

The name of the Virtual Network Gateway.

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






#### default_local_network_gateway_id

The ID of the local network gateway.

Outbound Internet traffic from the virtual network, in which the gateway is created,
will be routed through local network gateway(forced tunnelling)"


Type: string

<sup>[back to list](#modules-required-inputs)</sup>

#### edge_zone

Specifies the Edge Zone within the Azure Region where this Virtual Network Gateway should exist.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>






#### vpn_client_configuration

VPN client configurations (IPSec point-to-site connections).

List of available attributes of each VPN client configurations:
- `address_space`           - (`string`, required) the address space out of which IP addresses for vpn clients will be taken.
                              You can provide more than one address space, e.g. in CIDR notation.
- `aad_tenant`              - (`string`, optional, defaults to `null`) AzureAD Tenant URL
- `aad_audience`            - (`string`, optional, defaults to `null`) the client id of the Azure VPN application.
                              See Create an Active Directory (AD) tenant for P2S OpenVPN protocol connections for values
- `aad_issuer`              - (`string`, optional, defaults to `null`) the STS url for your tenant
- `root_certificate`        - (`object`, optional, defaults to `null`) one or more root_certificate blocks which are defined below.
                              These root certificates are used to sign the client certificate used by the VPN clients to connect to the gateway.
- `revoked_certificate`     - (`object`, optional, defaults to `null`) one or more revoked_certificate blocks which are defined below.
- `radius_server_address`   - (`string`, optional, defaults to `null`) the address of the Radius server.
- `radius_server_secret`    - (`string`, optional, defaults to `null`) the secret used by the Radius server.
- `vpn_client_protocols`    - (`list(string)`, optional, defaults to `null`) list of the protocols supported by the vpn client.
                              The supported values are SSTP, IkeV2 and OpenVPN. Values SSTP and IkeV2 are incompatible with the use of aad_tenant, aad_audience and aad_issuer.
- `vpn_auth_types`          - (`list(string)`, optional, defaults to `null`) list of the vpn authentication types for the virtual network gateway.
                              The supported values are AAD, Radius and Certificate.



Type: 

```hcl
list(object({
    address_space = string
    aad_tenant    = optional(string)
    aad_audience  = optional(string)
    aad_issuer    = optional(string)
    root_certificate = optional(object({
      name             = string
      public_cert_data = string
    }))
    revoked_certificate = optional(object({
      name       = string
      thumbprint = string
    }))
    radius_server_address = optional(string)
    radius_server_secret  = optional(string)
    vpn_client_protocols  = optional(list(string))
    vpn_auth_types        = optional(list(string))
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>


#### local_bgp_settings

BGP settings.

Attributes:
- `asn`                 - (`string`, required) the Autonomous System Number (ASN) to use as part of the BGP.
- `peering_addresses`   - (`map`, required) a map of peering addresses, which contains 1 (for active-standby)
                          or 2 objects (for active-active), where key is the ip configuration name and with attributes:
  - `apipa_addresses`   - (`list`, required) is the list of keys for IP addresses defined in variable azure_bgp_peers_addresses
  - `default_addresses` - (`list`, optional, defaults to `null`) is the list of peering address assigned to the BGP peer of the Virtual Network Gateway.
- `peer_weight`         - (`number`, optional, defaults to `null`) the weight added to routes which have been learned through BGP peering.

Example:

```hcl
local_bgp_settings = {
  asn = "65001"
  peering_addresses = {
    "001" = {
      apipa_addresses = ["primary_1", "primary_2"]
    },
    "002" = {
      apipa_addresses = ["secondary_1", "secondary_2"]
    }
  }
}
```


Type: 

```hcl
object({
    asn = string
    peering_addresses = map(object({
      apipa_addresses   = list(string)
      default_addresses = optional(list(string))
    }))
    peer_weight = optional(number)
  })
```


<sup>[back to list](#modules-required-inputs)</sup>


#### local_network_gateways

Map of local network gateways.

Every object in the map contains attributes:
- local_ng_name           - (`string`, required) the name of the local network gateway.
- connection_name         - (`string`, required) the name of the virtual network gateway connection.
- remote_bgp_settings     - (`list`, optional, defaults to `[]`) block containing Local Network Gateway's BGP speaker settings:
  - asn                   - (`string`, required) the BGP speaker's ASN.
  - bgp_peering_address   - (`string`, required) the BGP peering address and BGP identifier of this BGP speaker.
  - peer_weight           - (`number`, optional, defaults to `null`) the weight added to routes learned from this BGP speaker.
- gateway_address         - (`string`, optional, defaults to `null`) the gateway IP address to connect with.
- address_space           - (`list`, optional, defaults to `[]`) the list of string CIDRs representing the address spaces the gateway exposes.
- custom_bgp_addresses    - (`list`, optional, defaults to `[]`) Border Gateway Protocol custom IP Addresses,
                            which can only be used on IPSec / active-active connections. Object contains 2 attributes:
  - primary               - (`string`, required) single IP address that is part of the azurerm_virtual_network_gateway ip_configuration (first one)
  - secondary             - (`string`, optional, defaults to `null`) single IP address that is part of the azurerm_virtual_network_gateway ip_configuration (second one)

Example:

```hcl
local_network_gateways = {
  "lg1" = {
    local_ng_name   = "001"
    connection_name = "001"
    gateway_address = "PUBLIC_IP_1"
    remote_bgp_settings = [{
      asn                 = "65002"
      bgp_peering_address = "169.254.21.1"
    }]
    custom_bgp_addresses = [
      {
        primary   = "primary_1"
        secondary = "secondary_1"
      }
    ]
  }
  "lg2" = {
    local_ng_name   = "002"
    connection_name = "002"
    gateway_address = "PUBLIC_IP_2"
    remote_bgp_settings = [{
      asn                 = "65003"
      bgp_peering_address = "169.254.21.5"
    }]
    custom_bgp_addresses = [
      {
        primary   = "primary_2"
        secondary = "secondary_2"
      }
    ]
  }
  "lg3" = {
    local_ng_name   = "003"
    connection_name = "003"
    gateway_address = "PUBLIC_IP_3"
    remote_bgp_settings = [{
      asn                 = "65002"
      bgp_peering_address = "169.254.22.1"
    }]
    custom_bgp_addresses = [
      {
        primary   = "primary_1"
        secondary = "secondary_1"
      }
    ]
  }
  "lg4" = {
    local_ng_name   = "004"
    connection_name = "004"
    gateway_address = "PUBLIC_IP_4"
    remote_bgp_settings = [{
      asn                 = "65003"
      bgp_peering_address = "169.254.22.5"
    }]
    custom_bgp_addresses = [
      {
        primary   = "primary_2"
        secondary = "secondary_2"
      }
    ]
  }
}
```


Type: 

```hcl
map(object({
    local_ng_name   = string
    connection_name = string
    remote_bgp_settings = optional(list(object({
      asn                 = string
      bgp_peering_address = string
      peer_weight         = optional(number)
    })), [])
    gateway_address = optional(string)
    address_space   = optional(list(string), [])
    custom_bgp_addresses = optional(list(object({
      primary   = string
      secondary = optional(string)
    })), [])
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>



#### ipsec_shared_key

The shared IPSec key.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>

#### ipsec_policies

IPsec policies used for Virtual Network Connection.

Single policy contains attributes:
- `dh_group`          - (`string`, required) The DH group used in IKE phase 1 for initial SA.
- `ike_encryption`    - (`string`, required) The IKE encryption algorithm.
- `ike_integrity`     - (`string`, required) The IKE integrity algorithm.
- `ipsec_encryption`  - (`string`, required) The IPSec encryption algorithm.
- `ipsec_integrity`   - (`string`, required) The IPSec integrity algorithm.
- `pfs_group`         - (`string`, required) The DH group used in IKE phase 2 for new child SA.
- `sa_datasize`       - (`string`, optional, defaults to `102400000`) The IPSec SA payload size in KB. Must be at least 1024 KB.
- `sa_lifetime`       - (`string`, optional, defaults to `27000`) The IPSec SA lifetime in seconds. Must be at least 300 seconds.

Example:

```hcl
ipsec_policy = [
  {
    dh_group         = "ECP384"
    ike_encryption   = "AES256"
    ike_integrity    = "SHA256"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "ECP384"
    sa_datasize      = "102400000"
    sa_lifetime      = "27000"
  }
]
```


Type: 

```hcl
list(object({
    dh_group         = string
    ike_encryption   = string
    ike_integrity    = string
    ipsec_encryption = string
    ipsec_integrity  = string
    pfs_group        = string
    sa_datasize      = optional(string, "102400000")
    sa_lifetime      = optional(string, "27000")
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>



### Optional Inputs





#### tags

The map of tags to assign to all created resources.

Type: map(string)

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### type

The type of the Virtual Network Gateway.

Type: string

Default value: `Vpn`

<sup>[back to list](#modules-optional-inputs)</sup>

#### vpn_type

The routing type of the Virtual Network Gateway.

Type: string

Default value: `RouteBased`

<sup>[back to list](#modules-optional-inputs)</sup>

#### sku

Configuration of the size and capacity of the virtual network gateway.

Valid option depends on the type, vpn_type and generation arguments. A PolicyBased gateway only supports the Basic SKU.
Further, the UltraPerformance SKU is only supported by an ExpressRoute gateway.


Type: string

Default value: `Basic`

<sup>[back to list](#modules-optional-inputs)</sup>

#### active_active

Active-active Virtual Network Gateway.

If true, an active-active Virtual Network Gateway will be created.
An active-active gateway requires a HighPerformance or an UltraPerformance SKU.
If false, an active-standby gateway will be created. Defaults to false.


Type: bool

Default value: `false`

<sup>[back to list](#modules-optional-inputs)</sup>



#### enable_bgp

Controls whether BGP (Border Gateway Protocol) will be enabled for this Virtual Network Gateway.

Type: bool

Default value: `false`

<sup>[back to list](#modules-optional-inputs)</sup>

#### generation

The Generation of the Virtual Network gateway.

Type: string

Default value: `Generation1`

<sup>[back to list](#modules-optional-inputs)</sup>

#### private_ip_address_enabled

Controls whether the private IP is enabled on the gateway.

Type: bool

Default value: `false`

<sup>[back to list](#modules-optional-inputs)</sup>

#### zones

After provider version 3.x you need to specify in which availability zone(s) you want to place IP.

For zone-redundant with 3 availability zones in current region value will be:
```["1","2","3"]```


Type: list(string)

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### ip_configuration

IP configurations.

List of available attributes of each IP configuration.

- `name`                          - (`string`, required) name of the IP configuration
- `create_public_ip`              - (`bool`, required) - true if public IP needs to be created
- `public_ip_name`                - (`string`, required) name of the public IP resource used, when there is no need to create new one
- `private_ip_address_allocation` - (`string`, optional, defaults to `Dynamic`) defines how the private IP address of the gateways virtual interface is assigned.
- `subnet_id`                     - (`string`, required) the ID of the gateway subnet of a virtual network in which the virtual network gateway will be created.

Example:

```hcl
ip_configuration = [
  {
    name             = "001"
    create_public_ip = true
    subnet_id        = "ID_for_subnet_GatewaySubnet"
  },
  {
    name             = "002"
    create_public_ip = true
    subnet_id        = "ID_for_subnet_GatewaySubnet"
  }
]
```


Type: 

```hcl
list(object({
    name                          = string
    create_public_ip              = bool
    public_ip_name                = string
    private_ip_address_allocation = optional(string, "Dynamic")
    subnet_id                     = string
  }))
```


Default value: `[]`

<sup>[back to list](#modules-optional-inputs)</sup>


#### azure_bgp_peers_addresses

Map of IP addresses used on Azure side for BGP.

Map is used to not to duplicate IP address and refer to keys while configuring:
- `custom_bgp_addresses`
- `peering_addresses` in `local_bgp_settings`

Example:

```hcl
azure_bgp_peers_addresses = {
  primary_1   = "169.254.21.2"
  secondary_1 = "169.254.22.2"
  primary_2   = "169.254.21.6"
  secondary_2 = "169.254.22.6"
}
```


Type: map(string)

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>


#### custom_route

List of custom routes.

Every object in the list contains attributes:
- `address_prefixes` - (`list`, optional, defaults to `null`) a list of address blocks reserved for this virtual network in CIDR notation as defined below.



Type: 

```hcl
list(object({
    address_prefixes = optional(list(string))
  }))
```


Default value: `[]`

<sup>[back to list](#modules-optional-inputs)</sup>


#### connection_type

The type of VNG connection.

Type: string

Default value: `IPsec`

<sup>[back to list](#modules-optional-inputs)</sup>

#### connection_mode

The connection mode to use.

Type: string

Default value: `Default`

<sup>[back to list](#modules-optional-inputs)</sup>




<!-- END_TF_DOCS -->
<!-- BEGIN_TF_DOCS -->
# Palo Alto Networks Virtual Network Gateway Module for Azure

A terraform module for deploying a Virtual Network Gateway and its components required for the VM-Series firewalls in Azure.

## Usage

For usage refer to variables description, which include example for complex map of objects.

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`resource_group_name`](#resource_group_name) | `string` | Name of a pre-existing Resource Group to place the resources in.
[`location`](#location) | `string` | Region to deploy load balancer and dependencies.
[`name`](#name) | `string` | The name of the Virtual Network Gateway.
[`vpn_client_configuration`](#vpn_client_configuration) | `list` | VPN client configurations (IPSec point-to-site connections).
[`local_bgp_settings`](#local_bgp_settings) | `object` | BGP settings.
[`local_network_gateways`](#local_network_gateways) | `map` | Map of local network gateways.
[`ipsec_shared_key`](#ipsec_shared_key) | `string` | The shared IPSec key.
[`ipsec_policy`](#ipsec_policy) | `list` | IPsec policies used for Virtual Network Connection.


## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`name_prefix`](#name_prefix) | `string` | A prefix added to all resource names created by this module.
[`name_suffix`](#name_suffix) | `string` | A suffix added to all resource names created by this module.
[`tags`](#tags) | `map` | Azure tags to apply to the created resources.
[`avzones`](#avzones) | `list` | After provider version 3.
[`type`](#type) | `string` | The type of the Virtual Network Gateway.
[`vpn_type`](#vpn_type) | `string` | The routing type of the Virtual Network Gateway.
[`sku`](#sku) | `string` | Configuration of the size and capacity of the virtual network gateway.
[`active_active`](#active_active) | `bool` | If true, an active-active Virtual Network Gateway will be created.
[`default_local_network_gateway_id`](#default_local_network_gateway_id) | `string` | The ID of the local network gateway through which outbound Internet traffic from the virtual network in which the gateway is created will be routed (forced tunnelling).
[`edge_zone`](#edge_zone) | `string` | Specifies the Edge Zone within the Azure Region where this Virtual Network Gateway should exist.
[`enable_bgp`](#enable_bgp) | `bool` | If true, BGP (Border Gateway Protocol) will be enabled for this Virtual Network Gateway.
[`generation`](#generation) | `string` | The Generation of the Virtual Network gateway.
[`private_ip_address_enabled`](#private_ip_address_enabled) | `bool` | Should private IP be enabled on this gateway for connections?.
[`local_azure_ip_address_enabled`](#local_azure_ip_address_enabled) | `bool` | Use private local Azure IP for the connection.
[`ip_configuration`](#ip_configuration) | `list` | IP configurations.
[`azure_bgp_peers_addresses`](#azure_bgp_peers_addresses) | `map` | Map of IP addresses used on Azure side for BGP.
[`custom_route`](#custom_route) | `list` | List of custom routes.
[`connection_type`](#connection_type) | `string` | The type of VNG connection.
[`connection_mode`](#connection_mode) | `string` | Connection mode to use.



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


#### resource_group_name

Name of a pre-existing Resource Group to place the resources in.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>

#### location

Region to deploy load balancer and dependencies.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>



#### name

The name of the Virtual Network Gateway. Changing this forces a new resource to be created

Type: string

<sup>[back to list](#modules-required-inputs)</sup>














#### vpn_client_configuration

VPN client configurations (IPSec point-to-site connections).

List of available attributes of each VPN client configurations:
- `address_space`           - (`string`, required) the address space out of which IP addresses for vpn clients will be taken. You can provide more than one address space, e.g. in CIDR notation.
- `aad_tenant`              - (`string`, optional) AzureAD Tenant URL
- `aad_audience`            - (`string`, optional) the client id of the Azure VPN application. See Create an Active Directory (AD) tenant for P2S OpenVPN protocol connections for values
- `aad_issuer`              - (`string`, optional) the STS url for your tenant
- `root_certificate`        - (`object`, optional) one or more root_certificate blocks which are defined below. These root certificates are used to sign the client certificate used by the VPN clients to connect to the gateway.
- `revoked_certificate`     - (`object`, optional) one or more revoked_certificate blocks which are defined below.
- `radius_server_address`   - (`string`, optional) the address of the Radius server.
- `radius_server_secret`    - (`string`, optional) the secret used by the Radius server.
- `vpn_client_protocols`    - (`list(string)`, optional) list of the protocols supported by the vpn client. The supported values are SSTP, IkeV2 and OpenVPN. Values SSTP and IkeV2 are incompatible with the use of aad_tenant, aad_audience and aad_issuer.
- `vpn_auth_types`          - (`list(string)`, optional) list of the vpn authentication types for the virtual network gateway. The supported values are AAD, Radius and Certificate.



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
- `asn`                 - (`string`, optional) the Autonomous System Number (ASN) to use as part of the BGP.
- `peering_addresses`   - (`map`, optional) a map of peering addresses, which contains 1 (for active-standby) or 2 objects (for active-active), where key is the ip configuration name and with attributes:
  - `apipa_addresses`   - (`list`, required) is the list of keys for IP addresses defined in variable azure_bgp_peers_addresses
  - `default_addresses` - (`list`, optional) is the list of peering address assigned to the BGP peer of the Virtual Network Gateway.
- `peer_weight`         - (`number`, optional) the weight added to routes which have been learned through BGP peering. Valid values can be between 0 and 100.

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
    asn = optional(string)
    peering_addresses = optional(map(object({
      apipa_addresses   = list(string)
      default_addresses = optional(list(string))
    })))
    peer_weight = optional(number)
  })
```


<sup>[back to list](#modules-required-inputs)</sup>


#### local_network_gateways

Map of local network gateways.

Every object in the map contains attributes:
- name                    - (`string`, required) the name of the local network gateway.
- connection              - (`string`, required) the name of the virtual network gateway connection.
- remote_bgp_settings     - (`list`, optional) block containing Local Network Gateway's BGP speaker settings:
  - asn                   - (`string`, required) the BGP speaker's ASN.
  - bgp_peering_address   - (`string`, required) the BGP peering address and BGP identifier of this BGP speaker.
  - peer_weight           - (`number`, optional) the weight added to routes learned from this BGP speaker.
- gateway_address         - (`string`, optional) the gateway IP address to connect with.
- address_space           - (`list`, optional) the list of string CIDRs representing the address spaces the gateway exposes.
- custom_bgp_addresses    - (`list`, optional) Border Gateway Protocol custom IP Addresses, which can only be used on IPSec / active-active connections. Object contains 2 attributes:
  - primary               - (`string`, required) single IP address that is part of the azurerm_virtual_network_gateway ip_configuration (first one)
  - secondary             - (`string`, optional) single IP address that is part of the azurerm_virtual_network_gateway ip_configuration (second one)

Example:

```hcl
local_network_gateways = {
  "lg1" = {
    name            = "001"
    connection      = "001"
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
    name            = "002"
    connection      = "002"
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
    name            = "003"
    connection      = "003"
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
    name            = "004"
    connection      = "004"
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
    name       = string
    connection = string
    remote_bgp_settings = optional(list(object({
      asn                 = string
      bgp_peering_address = string
      peer_weight         = optional(number)
    })))
    gateway_address = optional(string)
    address_space   = optional(list(string))
    custom_bgp_addresses = optional(list(object({
      primary   = string
      secondary = optional(string)
    })))
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>

#### ipsec_shared_key

The shared IPSec key.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>



#### ipsec_policy

IPsec policies used for Virtual Network Connection.
  
Single policy contains attributes:
- `dh_group`          - (`string`, required) The DH group used in IKE phase 1 for initial SA. Valid options are DHGroup1, DHGroup14, DHGroup2, DHGroup2048, DHGroup24, ECP256, ECP384, or None.
- `ike_encryption`    - (`string`, required) The IKE encryption algorithm. Valid options are AES128, AES192, AES256, DES, DES3, GCMAES128, or GCMAES256.
- `ike_integrity`     - (`string`, required) The IKE integrity algorithm. Valid options are GCMAES128, GCMAES256, MD5, SHA1, SHA256, or SHA384.
- `ipsec_encryption`  - (`string`, required) The IPSec encryption algorithm. Valid options are AES128, AES192, AES256, DES, DES3, GCMAES128, GCMAES192, GCMAES256, or None.
- `ipsec_integrity`   - (`string`, required) The IPSec integrity algorithm. Valid options are GCMAES128, GCMAES192, GCMAES256, MD5, SHA1, or SHA256.
- `pfs_group`         - (`string`, required) The DH group used in IKE phase 2 for new child SA. Valid options are ECP256, ECP384, PFS1, PFS14, PFS2, PFS2048, PFS24, PFSMM, or None.
- `sa_datasize`       - (`string`, optional) The IPSec SA payload size in KB. Must be at least 1024 KB. Defaults to 102400000 KB.
- `sa_lifetime`       - (`string`, optional) The IPSec SA lifetime in seconds. Must be at least 300 seconds. Defaults to 27000 seconds.

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
    sa_datasize      = optional(string)
    sa_lifetime      = optional(string)
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>



### Optional Inputs




#### name_prefix

A prefix added to all resource names created by this module

Type: string

Default value: ``

<sup>[back to list](#modules-optional-inputs)</sup>

#### name_suffix

A suffix added to all resource names created by this module

Type: string

Default value: ``

<sup>[back to list](#modules-optional-inputs)</sup>


#### tags

Azure tags to apply to the created resources.

Type: map(string)

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### avzones

After provider version 3.x you need to specify in which availability zone(s) you want to place IP.

For zone-redundant with 3 availability zone in current region value will be:
```["1","2","3"]```


Type: list(string)

Default value: `[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### type

The type of the Virtual Network Gateway. Valid options are Vpn or ExpressRoute. Changing the type forces a new resource to be created

Type: string

Default value: `Vpn`

<sup>[back to list](#modules-optional-inputs)</sup>

#### vpn_type

The routing type of the Virtual Network Gateway. Valid options are RouteBased or PolicyBased. Defaults to RouteBased. Changing this forces a new resource to be created.

Type: string

Default value: `RouteBased`

<sup>[back to list](#modules-optional-inputs)</sup>

#### sku

Configuration of the size and capacity of the virtual network gateway. Valid options are Basic, Standard, HighPerformance, UltraPerformance, ErGw1AZ, ErGw2AZ, ErGw3AZ, VpnGw1, VpnGw2, VpnGw3, VpnGw4,VpnGw5, VpnGw1AZ, VpnGw2AZ, VpnGw3AZ,VpnGw4AZ and VpnGw5AZ and depend on the type, vpn_type and generation arguments. A PolicyBased gateway only supports the Basic SKU. Further, the UltraPerformance SKU is only supported by an ExpressRoute gateway.

Type: string

Default value: `Basic`

<sup>[back to list](#modules-optional-inputs)</sup>

#### active_active

If true, an active-active Virtual Network Gateway will be created. An active-active gateway requires a HighPerformance or an UltraPerformance SKU. If false, an active-standby gateway will be created. Defaults to false.

Type: bool

Default value: `false`

<sup>[back to list](#modules-optional-inputs)</sup>

#### default_local_network_gateway_id

The ID of the local network gateway through which outbound Internet traffic from the virtual network in which the gateway is created will be routed (forced tunnelling)

Type: string

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### edge_zone

Specifies the Edge Zone within the Azure Region where this Virtual Network Gateway should exist.

Type: string

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### enable_bgp

If true, BGP (Border Gateway Protocol) will be enabled for this Virtual Network Gateway. Defaults to false

Type: bool

Default value: `false`

<sup>[back to list](#modules-optional-inputs)</sup>

#### generation

The Generation of the Virtual Network gateway. Possible values include Generation1, Generation2 or None

Type: string

Default value: `Generation1`

<sup>[back to list](#modules-optional-inputs)</sup>

#### private_ip_address_enabled

Should private IP be enabled on this gateway for connections?

Type: bool

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### local_azure_ip_address_enabled

Use private local Azure IP for the connection.

Type: bool

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### ip_configuration

IP configurations.

List of available attributes of each IP configuration.

- `name`                          - (`string`, optional, defaults to `vnetGatewayConfig`) name of the IP configuration
- `create_public_ip`              - (`bool`, required) - true if public IP needs to be created
- `public_ip_name`                - (`string`, required when `create_public_ip = false`) name of the public IP resource used, when there is no need to create new one
- `private_ip_address_allocation` - (`string`, optional, defaults to `Dynamic`) defines how the private IP address of the gateways virtual interface is assigned. Valid options are Static or Dynamic. Defaults to Dynamic.
- `public_ip_standard_sku`        - (`bool`, optional, defaults to `false`) when set to `true` creates a Standard SKU, statically allocated public IP, otherwise it will be a Basic/Dynamic one.
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
    name                          = optional(string, "vnetGatewayConfig")
    create_public_ip              = bool
    public_ip_name                = optional(string)
    private_ip_address_allocation = optional(string, "Dynamic")
    public_ip_standard_sku        = optional(bool, false)
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
- `address_prefixes` - (`list`, optional) a list of address blocks reserved for this virtual network in CIDR notation as defined below.



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

Connection mode to use.

Type: string

Default value: `Default`

<sup>[back to list](#modules-optional-inputs)</sup>



<!-- END_TF_DOCS -->
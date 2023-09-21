<!-- BEGIN_TF_DOCS -->


## Module's Required Inputs


- [`resource_group_name`](#resource_group_name)
- [`location`](#location)
- [`name`](#name)
- [`type`](#type)
- [`sku`](#sku)
- [`default_local_network_gateway_id`](#default_local_network_gateway_id)
- [`edge_zone`](#edge_zone)
- [`private_ip_address_enabled`](#private_ip_address_enabled)
- [`ip_configuration`](#ip_configuration)
- [`vpn_client_configuration`](#vpn_client_configuration)
- [`azure_bgp_peers_addresses`](#azure_bgp_peers_addresses)
- [`local_bgp_settings`](#local_bgp_settings)
- [`custom_route`](#custom_route)
- [`local_network_gateways`](#local_network_gateways)
- [`ipsec_shared_key`](#ipsec_shared_key)
- [`connection_mode`](#connection_mode)
- [`ipsec_policy`](#ipsec_policy)


### resource_group_name

Name of a pre-existing Resource Group to place the resources in.

Type: `string`

### location

Region to deploy load balancer and dependencies.

Type: `string`



### name

The name of the Virtual Network Gateway. Changing this forces a new resource to be created

Type: `string`




### type

The type of the Virtual Network Gateway. Valid options are Vpn or ExpressRoute. Changing the type forces a new resource to be created

Type: `string`


### sku

Configuration of the size and capacity of the virtual network gateway. Valid options are Basic, Standard, HighPerformance, UltraPerformance, ErGw1AZ, ErGw2AZ, ErGw3AZ, VpnGw1, VpnGw2, VpnGw3, VpnGw4,VpnGw5, VpnGw1AZ, VpnGw2AZ, VpnGw3AZ,VpnGw4AZ and VpnGw5AZ and depend on the type, vpn_type and generation arguments. A PolicyBased gateway only supports the Basic SKU. Further, the UltraPerformance SKU is only supported by an ExpressRoute gateway.

Type: `string`


### default_local_network_gateway_id

The ID of the local network gateway through which outbound Internet traffic from the virtual network in which the gateway is created will be routed (forced tunnelling)

Type: `string`

### edge_zone

Specifies the Edge Zone within the Azure Region where this Virtual Network Gateway should exist.

Type: `string`



### private_ip_address_enabled

Should private IP be enabled on this gateway for connections?

Type: `bool`

### ip_configuration

List of IP configurations - every object in the list contains attributes:

- name - name of the IP configuration
- create_public_ip - boolean value, true if public IP needs to be created
- public_ip_name - name of the public IP resource used, when there is no need to create new one
- private_ip_address_allocation - defines how the private IP address of the gateways virtual interface is assigned. Valid options are Static or Dynamic. Defaults to Dynamic.
- public_ip_standard_sku - defaults to `false`, when set to `true` creates a Standard SKU, statically allocated public IP, otherwise it will be a Basic/Dynamic one.
- subnet_id - the ID of the gateway subnet of a virtual network in which the virtual network gateway will be created.

Example:

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



Type: `list(any)`

### vpn_client_configuration

List of VPN client configurations - every object in the list contains attributes:
- address_space - the address space out of which IP addresses for vpn clients will be taken. You can provide more than one address space, e.g. in CIDR notation.
- aad_tenant - AzureAD Tenant URL
- aad_audience - the client id of the Azure VPN application. See Create an Active Directory (AD) tenant for P2S OpenVPN protocol connections for values
- aad_issuer - the STS url for your tenant
- root_certificate - one or more root_certificate blocks which are defined below. These root certificates are used to sign the client certificate used by the VPN clients to connect to the gateway.
- revoked_certificate - one or more revoked_certificate blocks which are defined below.
- radius_server_address - the address of the Radius server.
- radius_server_secret - the secret used by the Radius server.
- vpn_client_protocols - list of the protocols supported by the vpn client. The supported values are SSTP, IkeV2 and OpenVPN. Values SSTP and IkeV2 are incompatible with the use of aad_tenant, aad_audience and aad_issuer.
- vpn_auth_types - list of the vpn authentication types for the virtual network gateway. The supported values are AAD, Radius and Certificate.



Type: `list(any)`

### azure_bgp_peers_addresses

Map of IP addresses used on Azure side for BGP. Map is used to not to duplicate IP address and refer to keys while configuring:
- custom_bgp_addresses
- peering_addresses in local_bgp_settings

Example:

azure_bgp_peers_addresses = {
  primary_1   = "169.254.21.2"
  secondary_1 = "169.254.22.2"
  primary_2   = "169.254.21.6"
  secondary_2 = "169.254.22.6"
}



Type: `map(string)`

### local_bgp_settings

Map of BGP settings:
- asn - the Autonomous System Number (ASN) to use as part of the BGP.
- peering_addresses - a map of peering addresses, which contains 1 (for active-standby) or 2 objects (for active-active) with:
  - key is the ip configuration name
  - apipa_addresses is the list of keys for IP addresses defined in variable azure_bgp_peers_addresses
- peer_weight - the weight added to routes which have been learned through BGP peering. Valid values can be between 0 and 100.

Example:

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



Type: `any`

### custom_route

List of custom routes - every object in the list contains attributes:
- address_prefixes - a list of address blocks reserved for this virtual network in CIDR notation as defined below.



Type: `list(any)`

### local_network_gateways

Map of local network gateways - every object in the map contains attributes:
- name - the name of the local network gateway.
- connection - the name of the virtual network gateway connection.
- remote_bgp_settings - block containing Local Network Gateway's BGP speaker settings:
  - asn - the BGP speaker's ASN.
  - bgp_peering_address - the BGP peering address and BGP identifier of this BGP speaker.
  - peer_weight - the weight added to routes learned from this BGP speaker.
- gateway_address - the gateway IP address to connect with.
- address_space - the list of string CIDRs representing the address spaces the gateway exposes.
- custom_bgp_addresses - Border Gateway Protocol custom IP Addresses, which can only be used on IPSec / active-active connections. Object contains 2 attributes:
  - primary - single IP address that is part of the azurerm_virtual_network_gateway ip_configuration (first one)
  - secondary - single IP address that is part of the azurerm_virtual_network_gateway ip_configuration (second one)

Example:

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



Type: `any`

### ipsec_shared_key

The shared IPSec key.

Type: `string`

### connection_mode

Connection mode to use. Possible values are Default, InitiatorOnly and ResponderOnly. Defaults to Default. Changing this value will force a resource to be created.

Type: `string`

### ipsec_policy

IPsec policy used for Virtual Network Connection with attributes:
- dh_group - The DH group used in IKE phase 1 for initial SA. Valid options are DHGroup1, DHGroup14, DHGroup2, DHGroup2048, DHGroup24, ECP256, ECP384, or None.
- ike_encryption - The IKE encryption algorithm. Valid options are AES128, AES192, AES256, DES, DES3, GCMAES128, or GCMAES256.
- ike_integrity - The IKE integrity algorithm. Valid options are GCMAES128, GCMAES256, MD5, SHA1, SHA256, or SHA384.
- ipsec_encryption - The IPSec encryption algorithm. Valid options are AES128, AES192, AES256, DES, DES3, GCMAES128, GCMAES192, GCMAES256, or None.
- ipsec_integrity - The IPSec integrity algorithm. Valid options are GCMAES128, GCMAES192, GCMAES256, MD5, SHA1, or SHA256.
- pfs_group - The DH group used in IKE phase 2 for new child SA. Valid options are ECP256, ECP384, PFS1, PFS14, PFS2, PFS2048, PFS24, PFSMM, or None.
- sa_datasize - The IPSec SA payload size in KB. Must be at least 1024 KB. Defaults to 102400000 KB.
- sa_lifetime - The IPSec SA lifetime in seconds. Must be at least 300 seconds. Defaults to 27000 seconds.

Example:

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



Type: `any`


## Module's Optional Inputs


- [`name_prefix`](#name_prefix)
- [`name_suffix`](#name_suffix)
- [`tags`](#tags)
- [`enable_zones`](#enable_zones)
- [`avzones`](#avzones)
- [`vpn_type`](#vpn_type)
- [`active_active`](#active_active)
- [`enable_bgp`](#enable_bgp)
- [`generation`](#generation)




### name_prefix

A prefix added to all resource names created by this module

Type: `string`

Default value: ``

### name_suffix

A suffix added to all resource names created by this module

Type: `string`

Default value: ``


### tags

Azure tags to apply to the created resources.

Type: `map(string)`

Default value: `map[]`

### enable_zones

If false, all the subnet-associated frontends and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones.

Type: `bool`

Default value: `true`

### avzones

After provider version 3.x you need to specify in which availability zone(s) you want to place IP.
ie: for zone-redundant with 3 availability zone in current region value will be:
```["1","2","3"]```


Type: `list(string)`

Default value: `[]`


### vpn_type

The routing type of the Virtual Network Gateway. Valid options are RouteBased or PolicyBased. Defaults to RouteBased. Changing this forces a new resource to be created.

Type: `string`

Default value: `RouteBased`


### active_active

If true, an active-active Virtual Network Gateway will be created. An active-active gateway requires a HighPerformance or an UltraPerformance SKU. If false, an active-standby gateway will be created. Defaults to false.

Type: `bool`

Default value: `false`



### enable_bgp

If true, BGP (Border Gateway Protocol) will be enabled for this Virtual Network Gateway. Defaults to false

Type: `bool`

Default value: `false`

### generation

The Generation of the Virtual Network gateway. Possible values include Generation1, Generation2 or None

Type: `string`

Default value: `Generation1`












## Module's Outputs


- [`public_ip`](#public_ip)
- [`ipsec_policy`](#ipsec_policy)


* `public_ip`: Public IP addresses for Virtual Network Gateway
* `ipsec_policy`: IPsec policy used for Virtual Network Gateway connection

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

- `local_network_gateway` (managed)
- `public_ip` (managed)
- `virtual_network_gateway` (managed)
- `virtual_network_gateway_connection` (managed)
- `public_ip` (data)
<!-- END_TF_DOCS -->
variable "resource_group_name" {
  description = "Name of a pre-existing Resource Group to place the resources in."
  type        = string
}

variable "location" {
  description = "Region to deploy load balancer and dependencies."
  type        = string
}

variable "name_prefix" {
  description = "A prefix added to all resource names created by this module"
  default     = ""
  type        = string
}

variable "name_suffix" {
  description = "A suffix added to all resource names created by this module"
  default     = ""
  type        = string
}

variable "name" {
  description = "The name of the Virtual Network Gateway. Changing this forces a new resource to be created"
  type        = string
}

variable "tags" {
  description = "Azure tags to apply to the created resources."
  default     = {}
  type        = map(string)
}

variable "enable_zones" {
  description = "If false, all the subnet-associated frontends and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones."
  default     = true
}

variable "avzones" {
  description = <<-EOF
  After provider version 3.x you need to specify in which availability zone(s) you want to place IP.
  ie: for zone-redundant with 3 availability zone in current region value will be:
  ```["1","2","3"]```
  EOF
  default     = []
  type        = list(string)
}

variable "type" {
  description = "The type of the Virtual Network Gateway. Valid options are Vpn or ExpressRoute. Changing the type forces a new resource to be created"
  type        = string
}

variable "vpn_type" {
  description = "The routing type of the Virtual Network Gateway. Valid options are RouteBased or PolicyBased. Defaults to RouteBased. Changing this forces a new resource to be created."
  default     = "RouteBased"
  type        = string
}

variable "sku" {
  description = "Configuration of the size and capacity of the virtual network gateway. Valid options are Basic, Standard, HighPerformance, UltraPerformance, ErGw1AZ, ErGw2AZ, ErGw3AZ, VpnGw1, VpnGw2, VpnGw3, VpnGw4,VpnGw5, VpnGw1AZ, VpnGw2AZ, VpnGw3AZ,VpnGw4AZ and VpnGw5AZ and depend on the type, vpn_type and generation arguments. A PolicyBased gateway only supports the Basic SKU. Further, the UltraPerformance SKU is only supported by an ExpressRoute gateway."
  type        = string
}

variable "active_active" {
  description = "If true, an active-active Virtual Network Gateway will be created. An active-active gateway requires a HighPerformance or an UltraPerformance SKU. If false, an active-standby gateway will be created. Defaults to false."
  default     = false
  type        = bool
}

variable "default_local_network_gateway_id" {
  description = "The ID of the local network gateway through which outbound Internet traffic from the virtual network in which the gateway is created will be routed (forced tunnelling)"
  type        = string
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Virtual Network Gateway should exist."
  type        = string
}

variable "enable_bgp" {
  description = "If true, BGP (Border Gateway Protocol) will be enabled for this Virtual Network Gateway. Defaults to false"
  default     = false
  type        = bool
}

variable "generation" {
  description = "The Generation of the Virtual Network gateway. Possible values include Generation1, Generation2 or None"
  type        = string
}

variable "private_ip_address_enabled" {
  description = "Should private IP be enabled on this gateway for connections?"
  type        = bool
}

variable "ip_configuration" {
  description = <<-EOF
  List of IP configurations - every object in the list contains attributes:

  - name - name of the IP configuration
  - create_public_ip - boolean value, true if public IP needs to be created
  - private_ip_address_allocation - defines how the private IP address of the gateways virtual interface is assigned. Valid options are Static or Dynamic. Defaults to Dynamic.
  - public_ip_standard_sku - defaults to `false`, when set to `true` creates a Standard SKU, statically allocated public IP, otherwise it will be a Basic/Dynamic one.
  - subnet_id - the ID of the gateway subnet of a virtual network in which the virtual network gateway will be created.

  EOF
  type        = list(any)
}

variable "vpn_client_configuration" {
  description = <<-EOF
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

  EOF
  type        = list(any)
}

variable "azure_bgp_peers_addresses" {
  description = <<-EOF
  Map of IP addresses used on Azure side for BGP. Map is used to not to duplicate IP address and refer to keys while configuring:
  - custom_bgp_addresses
  - peering_addresses in local_bgp_settings

  EOF
  type        = map(string)
}

variable "local_bgp_settings" {
  description = <<-EOF
  List of BGP settings - every object in the list contains attributes:
  - asn - the Autonomous System Number (ASN) to use as part of the BGP.
  - peering_addresses - a map of peering addresses, which contains 1 (for active-standby) or 2 objects (for active-active) with:
    - key is the ip configuration name
    - apipa_addresses is the list of keys for IP addresses defined in variable azure_bgp_peers_addresses
  - peer_weight - the weight added to routes which have been learned through BGP peering. Valid values can be between 0 and 100.

  EOF
  type        = list(any)
}

variable "custom_route" {
  description = <<-EOF
  List of custom routes - every object in the list contains attributes:
  - address_prefixes - a list of address blocks reserved for this virtual network in CIDR notation as defined below.

  EOF
  type        = list(any)
}

variable "local_network_gateways" {
  description = <<-EOF
  Map of local network gateways - every object in the map contains attributes:
  - name - the name of the local network gateway.
  - connection - the name of the virtual network gateway connection.
  - bgp_settings - block containing Local Network Gateway's BGP speaker settings:
    - asn - the BGP speaker's ASN.
    - bgp_peering_address - the BGP peering address and BGP identifier of this BGP speaker.
    - peer_weight - the weight added to routes learned from this BGP speaker.
  - gateway_address - the gateway IP address to connect with.
  - address_space - the list of string CIDRs representing the address spaces the gateway exposes.
  - custom_bgp_addresses - Border Gateway Protocol custom IP Addresses, which can only be used on IPSec / active-active connections. Object contains 2 attributes:
    - primary - single IP address that is part of the azurerm_virtual_network_gateway ip_configuration (first one)
    - secondary - single IP address that is part of the azurerm_virtual_network_gateway ip_configuration (second one)

  EOF
  type        = any
}

variable "ipsec_shared_key" {
  description = "The shared IPSec key."
  type        = string
  sensitive   = true
}

variable "connection_mode" {
  description = "Connection mode to use. Possible values are Default, InitiatorOnly and ResponderOnly. Defaults to Default. Changing this value will force a resource to be created."
  type        = string
}

variable "ipsec_policy" {
  description = <<-EOF
  IPsec policy used for Virtual Network Connection with attributes:
  - dh_group - The DH group used in IKE phase 1 for initial SA. Valid options are DHGroup1, DHGroup14, DHGroup2, DHGroup2048, DHGroup24, ECP256, ECP384, or None.
  - ike_encryption - The IKE encryption algorithm. Valid options are AES128, AES192, AES256, DES, DES3, GCMAES128, or GCMAES256.
  - ike_integrity - The IKE integrity algorithm. Valid options are GCMAES128, GCMAES256, MD5, SHA1, SHA256, or SHA384.
  - ipsec_encryption - The IPSec encryption algorithm. Valid options are AES128, AES192, AES256, DES, DES3, GCMAES128, GCMAES192, GCMAES256, or None.
  - ipsec_integrity - The IPSec integrity algorithm. Valid options are GCMAES128, GCMAES192, GCMAES256, MD5, SHA1, or SHA256.
  - pfs_group - The DH group used in IKE phase 2 for new child SA. Valid options are ECP256, ECP384, PFS1, PFS14, PFS2, PFS2048, PFS24, PFSMM, or None.
  - sa_datasize - The IPSec SA payload size in KB. Must be at least 1024 KB. Defaults to 102400000 KB.
  - sa_lifetime - The IPSec SA lifetime in seconds. Must be at least 300 seconds. Defaults to 27000 seconds.

  EOF
  type        = any
}

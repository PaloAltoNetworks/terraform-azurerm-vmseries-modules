# Main resource
variable "name" {
  description = "The name of the Virtual Network Gateway."
  type        = string
}

# Common settings
variable "resource_group_name" {
  description = "The name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "The name of the Azure region to deploy the resources in."
  type        = string
}

variable "tags" {
  description = "The map of tags to assign to all created resources."
  default     = {}
  type        = map(string)
}

# Virtual Network Gateway
variable "type" {
  description = "The type of the Virtual Network Gateway."
  default     = "Vpn"
  nullable    = false
  type        = string
  validation {
    condition     = contains(["Vpn", "ExpressRoute"], var.type)
    error_message = "Valid options are Vpn or ExpressRoute"
  }
}

variable "vpn_type" {
  description = "The routing type of the Virtual Network Gateway."
  default     = "RouteBased"
  nullable    = false
  type        = string
  validation {
    condition     = contains(["RouteBased", "PolicyBased"], var.vpn_type)
    error_message = "Valid options are RouteBased or PolicyBased"
  }
}

variable "sku" {
  description = <<-EOF
  Configuration of the size and capacity of the virtual network gateway.

  Valid option depends on the type, vpn_type and generation arguments. A PolicyBased gateway only supports the Basic SKU.
  Further, the UltraPerformance SKU is only supported by an ExpressRoute gateway.
  EOF
  default     = "Basic"
  nullable    = false
  type        = string
  validation {
    condition     = contains(["Basic", "Standard", "HighPerformance", "UltraPerformance", "ErGw1AZ", "ErGw2AZ", "ErGw3AZ", "VpnGw1", "VpnGw2", "VpnGw3", "VpnGw4", "VpnGw5", "VpnGw1AZ", "VpnGw2AZ", "VpnGw3AZ", "VpnGw4AZ", "VpnGw5AZ"], var.sku)
    error_message = "Valid options are Basic, Standard, HighPerformance, UltraPerformance, ErGw1AZ, ErGw2AZ, ErGw3AZ, VpnGw1, VpnGw2, VpnGw3, VpnGw4,VpnGw5, VpnGw1AZ, VpnGw2AZ, VpnGw3AZ,VpnGw4AZ and VpnGw5AZ and depend on the type, vpn_type and generation arguments"
  }
}

variable "active_active" {
  description = <<-EOF
  Active-active Virtual Network Gateway.

  If true, an active-active Virtual Network Gateway will be created.
  An active-active gateway requires a HighPerformance or an UltraPerformance SKU.
  If false, an active-standby gateway will be created. Defaults to false.
  EOF
  default     = false
  nullable    = false
  type        = bool
}

variable "default_local_network_gateway_id" {
  description = <<-EOF
  The ID of the local network gateway.

  Outbound Internet traffic from the virtual network, in which the gateway is created,
  will be routed through local network gateway(forced tunnelling)"
  EOF
  type        = string
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Virtual Network Gateway should exist."
  type        = string
}

variable "enable_bgp" {
  description = "Controls whether BGP (Border Gateway Protocol) will be enabled for this Virtual Network Gateway."
  default     = false
  nullable    = false
  type        = bool
}

variable "generation" {
  description = "The Generation of the Virtual Network gateway."
  type        = string
  default     = "Generation1"
  nullable    = false
  validation {
    condition     = contains(["Generation1", "Generation2", "None"], coalesce(var.generation, "Generation1"))
    error_message = "Valid options are Generation1, Generation2 or None"
  }
}

variable "private_ip_address_enabled" {
  description = "Controls whether the private IP is enabled on the gateway."
  default     = false
  nullable    = false
  type        = bool
}

variable "zones" {
  description = <<-EOF
  After provider version 3.x you need to specify in which availability zone(s) you want to place IP.

  For zone-redundant with 3 availability zones in current region value will be:
  ```["1","2","3"]```
  EOF
  default     = null
  type        = list(string)
  validation {
    condition = var.zones == null || (var.zones != null ? (
      length(var.zones) == 3 && length(setsubtract(var.zones, ["1", "2", "3"])) == 0
    ) : true)
    error_message = "No zones or all 3 zones are expected"
  }
}

variable "ip_configuration" {
  description = <<-EOF
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
  EOF
  default     = []
  nullable    = false
  type = list(object({
    name                          = string
    create_public_ip              = bool
    public_ip_name                = string
    private_ip_address_allocation = optional(string, "Dynamic")
    subnet_id                     = string
  }))
  validation {
    condition     = length(flatten([for _, config in var.ip_configuration : config.name])) == length(distinct(flatten([for _, config in var.ip_configuration : config.name])))
    error_message = "The `name` property has to be unique among all IP configuration."
  }
  validation {
    condition = alltrue(flatten([
      for _, config in var.ip_configuration : [
        contains(["Static", "Dynamic"], config.private_ip_address_allocation)
    ]]))
    error_message = "Possible values for `private_ip_address_allocation` are Static or Dynamic"
  }
}

variable "vpn_client_configuration" {
  description = <<-EOF
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

  EOF
  type = list(object({
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
}

variable "azure_bgp_peers_addresses" {
  description = <<-EOF
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
  EOF
  default     = {}
  nullable    = false
  type        = map(string)
}

variable "local_bgp_settings" {
  description = <<-EOF
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
  EOF
  type = object({
    asn = string
    peering_addresses = map(object({
      apipa_addresses   = list(string)
      default_addresses = optional(list(string))
    }))
    peer_weight = optional(number)
  })
  validation {
    condition     = var.local_bgp_settings.peer_weight != null ? var.local_bgp_settings.peer_weight >= 0 && var.local_bgp_settings.peer_weight <= 100 : true
    error_message = "Possible values for `peer_weight` are between 0 and 100."
  }
}

variable "custom_route" {
  description = <<-EOF
  List of custom routes.

  Every object in the list contains attributes:
  - `address_prefixes` - (`list`, optional, defaults to `null`) a list of address blocks reserved for this virtual network in CIDR notation as defined below.

  EOF
  default     = []
  nullable    = false
  type = list(object({
    address_prefixes = optional(list(string))
  }))
}

# Local network gateways
variable "local_network_gateways" {
  description = <<-EOF
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
  EOF
  type = map(object({
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
}

# Virtual Network Gateway connection
variable "connection_type" {
  description = "The type of VNG connection."
  default     = "IPsec"
  nullable    = false
  type        = string
  validation {
    condition     = contains(["IPsec", "ExpressRoute", "Vnet2Vnet"], var.connection_type)
    error_message = "Valid options are IPsec (Site-to-Site), ExpressRoute (ExpressRoute), and Vnet2Vnet (VNet-to-VNet)"
  }
}

variable "connection_mode" {
  description = "The connection mode to use."
  default     = "Default"
  nullable    = false
  type        = string
  validation {
    condition     = contains(["Default", "InitiatorOnly", "ResponderOnly"], var.connection_mode)
    error_message = "Possible values are Default, InitiatorOnly and ResponderOnly"
  }
}

variable "ipsec_shared_key" {
  description = "The shared IPSec key."
  type        = string
  sensitive   = true
}

variable "ipsec_policies" {
  description = <<-EOF
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
  EOF
  type = list(object({
    dh_group         = string
    ike_encryption   = string
    ike_integrity    = string
    ipsec_encryption = string
    ipsec_integrity  = string
    pfs_group        = string
    sa_datasize      = optional(string, "102400000")
    sa_lifetime      = optional(string, "27000")
  }))
  validation {
    condition = alltrue(flatten([
      for _, ipsec_policy in var.ipsec_policies : [
        contains(["DHGroup1", "DHGroup14", "DHGroup2", "DHGroup2048", "DHGroup24", "ECP256", "ECP384", "None"], ipsec_policy.dh_group)
    ]]))
    error_message = "Possible values for `dh_group` are DHGroup1, DHGroup14, DHGroup2, DHGroup2048, DHGroup24, ECP256, ECP384 or None"
  }
  validation {
    condition = alltrue(flatten([
      for _, ipsec_policy in var.ipsec_policies : [
        contains(["AES128", "AES192", "AES256", "DES", "DES3", "GCMAES128", "GCMAES256"], ipsec_policy.ike_encryption)
    ]]))
    error_message = "Possible values for `ike_encryption` are AES128, AES192, AES256, DES, DES3, GCMAES128, or GCMAES256"
  }
  validation {
    condition = alltrue(flatten([
      for _, ipsec_policy in var.ipsec_policies : [
        contains(["GCMAES128", "GCMAES256", "MD5", "SHA1", "SHA256", "SHA384"], ipsec_policy.ike_integrity)
    ]]))
    error_message = "Possible values for `ike_integrity` are GCMAES128, GCMAES256, MD5, SHA1, SHA256, or SHA384"
  }
  validation {
    condition = alltrue(flatten([
      for _, ipsec_policy in var.ipsec_policies : [
        contains(["AES128", "AES192", "AES256", "DES", "DES3", "GCMAES128", "GCMAES192", "GCMAES256", "None"], ipsec_policy.ipsec_encryption)
    ]]))
    error_message = "Possible values for `ipsec_encryption` are AES128, AES192, AES256, DES, DES3, GCMAES128, GCMAES192, GCMAES256, or None"
  }
  validation {
    condition = alltrue(flatten([
      for _, ipsec_policy in var.ipsec_policies : [
        contains(["GCMAES128", "GCMAES192", "GCMAES256", "MD5", "SHA1", "SHA256"], ipsec_policy.ipsec_integrity)
    ]]))
    error_message = "Possible values for `ipsec_integrity` are GCMAES128, GCMAES192, GCMAES256, MD5, SHA1, or SHA256"
  }
  validation {
    condition = alltrue(flatten([
      for _, ipsec_policy in var.ipsec_policies : [
        contains(["ECP256", "ECP384", "PFS1", "PFS14", "PFS2", "PFS2048", "PFS24", "PFSMM", "None"], ipsec_policy.pfs_group)
    ]]))
    error_message = "Possible values for `pfs_group` are ECP256, ECP384, PFS1, PFS14, PFS2, PFS2048, PFS24, PFSMM, or None"
  }
}

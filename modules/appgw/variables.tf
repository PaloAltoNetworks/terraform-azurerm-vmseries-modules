variable "resource_group_name" {
  description = "Name of an existing resource group."
  type        = string
}

variable "location" {
  description = "Location to place the Application Gateway in."
  type        = string
}

variable "zones" {
  description = <<-EOF
  A list of zones the Application Gateway should be available in.

  NOTICE: this is also enforced on the Public IP. The Public IP object brings in some limitations as it can only be non-zonal, pinned to a single zone or zone-redundant (so available in all zones in a region). 
  Therefore make sure that if you specify more than one zone you specify all available in a region. You can use a subset, but the Public IP will be created in all zones anyway. This fact will cause terraform to recreate the IP resource during next `terraform apply` as there will be difference between the state and the actual configuration.

  For details on zones currently available in a region of your choice refer to [Microsoft's documentation](https://docs.microsoft.com/en-us/azure/availability-zones/az-region).

  Example:
  ```
  zones = ["1","2","3"]
  ```
  EOF
  default     = null
  type        = list(string)
}

variable "name" {
  description = "Name of the Application Gateway."
  type        = string
}

variable "domain_name_label" {
  description = "A value that will be used to construct the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
  default     = null
  type        = string
}

variable "managed_identities" {
  description = <<-EOF
  A list of existing User-Assigned Managed Identities, which Application Gateway uses to retrieve certificates from Key Vault.

  These identities have to have at least `GET` access to Key Vault's secrets. Otherwise Application Gateway will not be able to use certificates stored in the Vault.
  EOF
  default     = null
  type        = list(string)
}

variable "waf_enabled" {
  description = "Enables WAF Application Gateway. This only sets the SKU. This module does not support WAF rules configuration."
  default     = "false"
  type        = bool
}

variable "capacity" {
  description = <<-EOF
  A number of Application Gateway instances. A value bewteen 1 and 125.

  This property is not used when autoscaling is enabled.
  EOF
  default     = 2
  type        = number
}

variable "capacity_min" {
  description = "Minimum amount of instances when autoscaling is enabled."
  default     = null
  type        = number
}

variable "capacity_max" {
  description = "Maximum amount of instances when autoscaling is enabled."
  default     = null
  type        = number
}

variable "enable_http2" {
  description = "Enable HTTP2 on the Application Gateway."
  default     = false
  type        = bool
}

variable "subnet_id" {
  description = "An ID of a subnet that will host the Application Gateway. Keep in mind that this subnet can contain only AppGWs and only of the same type."
  type        = string
}

variable "vmseries_ips" {
  description = "IP addresses of VMSeries' interfaces that will serve as backends for the Application Gateway."
  default     = []
  type        = list(string)
}

variable "rules" {
  description = <<-EOF
  A map of rules for the Application Gateway. 
  
  A rule combines listener, http settings and health check configuration. 
  A key is an application name that is used to prefix all components inside Application Gateway that are created for this application. 

  Details on configuration can be found [here](#rules-property-explained).
  EOF
  default     = {}
  type        = any
}

variable "ssl_policy_type" {
  description = <<-EOF
  Type of an SSL policy.
  
  Possible values are `Predefined` or `Custom`.
  If the value is `Custom` the following values are mandatory: `ssl_policy_cipher_suites` and `ssl_policy_min_protocol_version`.
  EOF
  default     = "Predefined"
  nullable    = false
  type        = string
}

variable "ssl_policy_name" {
  description = <<-EOF
  Name of an SSL policy when `ssl_policy_type` is set to `Predefined`.
  
  Normally you can set it also for `Custom` policies but the name is discarded on Azure side causing an update to Application Gateway each time terraform code is run. Therefore this property is omitted in the code for `Custom` policies. 
  
  For the `Predefined` policies, check the [Microsoft documentation](https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-ssl-policy-overview) for possible values as they tend to change over time. The default value is currently (Q1 2022) a Microsoft's default.
  EOF
  default     = "AppGwSslPolicy20220101S"
  nullable    = false
  type        = string
}

variable "ssl_policy_min_protocol_version" {
  description = <<-EOF
  Minimum version of the TLS protocol for SSL Policy when `ssl_policy_type` is set to `Custom`.
  Possible values are: `TLSv1_0`, `TLSv1_1`, `TLSv1_2` or `null` (only to be used with a `Predefined` policy).
  EOF
  default     = "TLSv1_2"
  nullable    = false
  type        = string
}

variable "ssl_policy_cipher_suites" {
  description = <<-EOF
  A list of accepted SSL cipher suites when `ssl_policy_type` is set to `Custom`.
  For possible values see [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#cipher_suites).
  EOF
  default = [
    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
  ]
  nullable = false
  type     = list(string)
}

variable "ssl_profiles" {
  description = <<-EOF
  A map of SSL profiles that can be later on referenced in HTTPS listeners by providing a name of the profile in the `ssl_profile_name` property. 

  Following properties are available:

  - `name`                              - (`string`, required) name of a profile
  - `ssl_policy_type`                   - (`string`, required) for meaning and possible values see [`ssl_policy_type`](#ssl_policy_type)
  - `ssl_policy_min_protocol_version`   - (`string`, required when `ssl_policy_type` is set to `Custom`) for meaning and possible values see [`ssl_policy_min_protocol_version`](#ssl_policy_min_protocol_version)
  - `ssl_policy_cipher_suites`          - (`list`, required when `ssl_policy_type` is set to `Custom`) for meaning and possible values see [`ssl_policy_cipher_suites`](#ssl_policy_cipher_suites)

  EOF
  default     = {}
  nullable    = false
  type = map(object({
    name                            = string
    ssl_policy_type                 = string
    ssl_policy_min_protocol_version = optional(string)
    ssl_policy_cipher_suites        = optional(list(string))
  }))
}

variable "tags" {
  description = "Azure tags to apply to the created resources."
  default     = {}
  type        = map(string)
}
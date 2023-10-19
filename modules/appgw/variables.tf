# Main resource

variable "name" {
  description = "Name of the Application Gateway."
  type        = string
}

# Common settings
variable "resource_group_name" {
  description = "Name of an existing resource group."
  type        = string
}

variable "location" {
  description = "Location to place the Application Gateway in."
  type        = string
}

variable "tags" {
  description = "Azure tags to apply to the created resources."
  default     = {}
  type        = map(string)
}

# Application Gateway
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

variable "public_ip_name" {
  description = "Name for the public IP address"
  type        = string
}

variable "domain_name_label" {
  description = "Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
  default     = null
  type        = string
}

variable "enable_http2" {
  description = "Enable HTTP2 on the Application Gateway."
  default     = false
  type        = bool
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
  validation {
    condition     = var.capacity >= 1 && var.capacity <= 125
    error_message = "When using a V2 SKU this value must be between 1 to 125"
  }
}

variable "capacity_min" {
  description = "When set enables autoscaling and becomes the minimum capacity."
  default     = null
  type        = number
}

variable "capacity_max" {
  description = "Optional, maximum capacity for autoscaling."
  default     = null
  type        = number
}

variable "managed_identities" {
  description = <<-EOF
  A list of existing User-Assigned Managed Identities, which Application Gateway uses to retrieve certificates from Key Vault.

  These identities have to have at least `GET` access to Key Vault's secrets. Otherwise Application Gateway will not be able to use certificates stored in the Vault.
  EOF
  default     = null
  type        = list(string)
}

variable "subnet_id" {
  description = "An ID of a subnet that will host the Application Gateway. Keep in mind that this subnet can contain only AppGWs and only of the same type."
  type        = string
}

variable "ssl_policy_type" {
  description = <<-EOF
  Type of an SSL policy.

  Possible values are `Predefined` or `Custom` or `CustomV2`.
  If the value is `Custom` the following values are mandatory: `ssl_policy_cipher_suites` and `ssl_policy_min_protocol_version`.
  EOF
  default     = "Predefined"
  type        = string
  validation {
    condition     = contains(["Predefined", "Custom", "CustomV2"], var.ssl_policy_type)
    error_message = "Possible values are Predefined, Custom and CustomV2"
  }
  nullable = false
}

variable "ssl_policy_name" {
  description = <<-EOF
  Name of an SSL policy.

  Supported only for `ssl_policy_type` set to `Predefined`. Normally you can set it also for `Custom` policies but the name is discarded on Azure side causing an update to Application Gateway each time terraform code is run. Therefore this property is omitted in the code for `Custom` policies.
  For the `Predefined` polcies, check the [Microsoft documentation](https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-ssl-policy-overview) for possible values as they tend to change over time. The default value is currently (Q1 2022) a Microsoft's default.
  EOF
  default     = "AppGwSslPolicy20220101S"
  type        = string
  nullable    = false
}

variable "ssl_policy_min_protocol_version" {
  description = <<-EOF
  Minimum version of the TLS protocol for SSL Policy.

  Required only for `ssl_policy_type` set to `Custom`.
  Possible values are: `TLSv1_0`, `TLSv1_1`, `TLSv1_2`, `TLSv1_3` or `null` (only to be used with a `Predefined` policy).
  EOF
  default     = "TLSv1_2"
  type        = string
  validation {
    condition     = contains(["TLSv1_0", "TLSv1_1", "TLSv1_2", "TLSv1_3"], coalesce(var.ssl_policy_min_protocol_version, "TLSv1_2"))
    error_message = "Possible values are TLSv1_0, TLSv1_1, TLSv1_2 and TLSv1_3"
  }
}

variable "ssl_policy_cipher_suites" {
  description = <<-EOF
  A list of accepted cipher suites.

  Required only for `ssl_policy_type` set to `Custom`.
  For possible values see [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#cipher_suites).
  EOF
  default     = ["TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"]
  type        = list(string)
  validation {
    condition     = length(coalesce(var.ssl_policy_cipher_suites, [])) == 0 || length(setsubtract(coalesce(var.ssl_policy_cipher_suites, []), ["TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA", "TLS_DHE_DSS_WITH_AES_128_CBC_SHA", "TLS_DHE_DSS_WITH_AES_128_CBC_SHA256", "TLS_DHE_DSS_WITH_AES_256_CBC_SHA", "TLS_DHE_DSS_WITH_AES_256_CBC_SHA256", "TLS_DHE_RSA_WITH_AES_128_CBC_SHA", "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_DHE_RSA_WITH_AES_256_CBC_SHA", "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA", "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA", "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256", "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA", "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_RSA_WITH_3DES_EDE_CBC_SHA", "TLS_RSA_WITH_AES_128_CBC_SHA", "TLS_RSA_WITH_AES_128_CBC_SHA256", "TLS_RSA_WITH_AES_128_GCM_SHA256", "TLS_RSA_WITH_AES_256_CBC_SHA", "TLS_RSA_WITH_AES_256_CBC_SHA256", "TLS_RSA_WITH_AES_256_GCM_SHA384"])) == 0
    error_message = "Possible values are: TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA, TLS_DHE_DSS_WITH_AES_128_CBC_SHA, TLS_DHE_DSS_WITH_AES_128_CBC_SHA256, TLS_DHE_DSS_WITH_AES_256_CBC_SHA, TLS_DHE_DSS_WITH_AES_256_CBC_SHA256, TLS_DHE_RSA_WITH_AES_128_CBC_SHA, TLS_DHE_RSA_WITH_AES_128_GCM_SHA256, TLS_DHE_RSA_WITH_AES_256_CBC_SHA, TLS_DHE_RSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA, TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256, TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA, TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384, TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256, TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA, TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384, TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384, TLS_RSA_WITH_3DES_EDE_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA256, TLS_RSA_WITH_AES_128_GCM_SHA256, TLS_RSA_WITH_AES_256_CBC_SHA, TLS_RSA_WITH_AES_256_CBC_SHA256 and TLS_RSA_WITH_AES_256_GCM_SHA384"
  }
}

variable "ssl_profiles" {
  description = <<-EOF
  A map of SSL profiles.

  SSL profiles can be later on referenced in HTTPS listeners by providing a name of the profile in the `ssl_profile_name` property.
  For possible values check the: `ssl_policy_type`, `ssl_policy_min_protocol_version` and `ssl_policy_cipher_suites` variables as SSL profile is a named SSL policy - same properties apply.
  The only difference is that you cannot name an SSL policy inside an SSL profile.

  Every SSL profile contains attributes:
  - `name`                            - (`string`, required) name of the SSL profile
  - `ssl_policy_type`                 - (`string`, optional) the Type of the Policy. Possible values are Predefined, Custom and CustomV2
  - `ssl_policy_min_protocol_version` - (`string`, optional) the minimal TLS version. Possible values are TLSv1_0, TLSv1_1, TLSv1_2 and TLSv1_3
  - `ssl_policy_cipher_suites`        - (`list`, optional) a List of accepted cipher suites. Possible values are: TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA, TLS_DHE_DSS_WITH_AES_128_CBC_SHA, TLS_DHE_DSS_WITH_AES_128_CBC_SHA256, TLS_DHE_DSS_WITH_AES_256_CBC_SHA, TLS_DHE_DSS_WITH_AES_256_CBC_SHA256, TLS_DHE_RSA_WITH_AES_128_CBC_SHA, TLS_DHE_RSA_WITH_AES_128_GCM_SHA256, TLS_DHE_RSA_WITH_AES_256_CBC_SHA, TLS_DHE_RSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA, TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256, TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA, TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384, TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256, TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA, TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384, TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384, TLS_RSA_WITH_3DES_EDE_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA256, TLS_RSA_WITH_AES_128_GCM_SHA256, TLS_RSA_WITH_AES_256_CBC_SHA, TLS_RSA_WITH_AES_256_CBC_SHA256 and TLS_RSA_WITH_AES_256_GCM_SHA384
  EOF
  default     = {}
  type = map(object({
    name                            = string
    ssl_policy_type                 = optional(string)
    ssl_policy_min_protocol_version = optional(string)
    ssl_policy_cipher_suites        = optional(list(string))
  }))
  validation {
    condition = alltrue(flatten([
      for _, ssl_profile in var.ssl_profiles : [
        contains(["Predefined", "Custom", "CustomV2"], coalesce(ssl_profile.ssl_policy_type, "Predefined"))
    ]]))
    error_message = "Possible values for `ssl_policy_type` are Predefined, Custom and CustomV2"
  }
  validation {
    condition = alltrue(flatten([
      for _, ssl_profile in var.ssl_profiles : [
        contains(["TLSv1_0", "TLSv1_1", "TLSv1_2", "TLSv1_3"], coalesce(ssl_profile.ssl_policy_min_protocol_version, "TLSv1_3"))
    ]]))
    error_message = "Possible values for `ssl_policy_min_protocol_version` are TLSv1_0, TLSv1_1, TLSv1_2 and TLSv1_3"
  }
  validation {
    condition = alltrue(flatten([
      for _, ssl_profile in var.ssl_profiles : [
        length(setsubtract(coalesce(ssl_profile.ssl_policy_cipher_suites, []),
          ["TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA", "TLS_DHE_DSS_WITH_AES_128_CBC_SHA", "TLS_DHE_DSS_WITH_AES_128_CBC_SHA256", "TLS_DHE_DSS_WITH_AES_256_CBC_SHA", "TLS_DHE_DSS_WITH_AES_256_CBC_SHA256", "TLS_DHE_RSA_WITH_AES_128_CBC_SHA", "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_DHE_RSA_WITH_AES_256_CBC_SHA", "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA", "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA", "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256", "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA", "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_RSA_WITH_3DES_EDE_CBC_SHA", "TLS_RSA_WITH_AES_128_CBC_SHA", "TLS_RSA_WITH_AES_128_CBC_SHA256", "TLS_RSA_WITH_AES_128_GCM_SHA256", "TLS_RSA_WITH_AES_256_CBC_SHA", "TLS_RSA_WITH_AES_256_CBC_SHA256", "TLS_RSA_WITH_AES_256_GCM_SHA384"]
        )) == 0
    ]]))
    error_message = "Possible values for `ssl_policy_cipher_suites` are TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA, TLS_DHE_DSS_WITH_AES_128_CBC_SHA, TLS_DHE_DSS_WITH_AES_128_CBC_SHA256, TLS_DHE_DSS_WITH_AES_256_CBC_SHA, TLS_DHE_DSS_WITH_AES_256_CBC_SHA256, TLS_DHE_RSA_WITH_AES_128_CBC_SHA, TLS_DHE_RSA_WITH_AES_128_GCM_SHA256, TLS_DHE_RSA_WITH_AES_256_CBC_SHA, TLS_DHE_RSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA, TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256, TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA, TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384, TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256, TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA, TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384, TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384, TLS_RSA_WITH_3DES_EDE_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA256, TLS_RSA_WITH_AES_128_GCM_SHA256, TLS_RSA_WITH_AES_256_CBC_SHA, TLS_RSA_WITH_AES_256_CBC_SHA256 and TLS_RSA_WITH_AES_256_GCM_SHA384"
  }
}

variable "frontend_ip_configuration_name" {
  description = "Frontend IP configuration name"
  default     = "public_ipconfig"
  type        = string
}

variable "listeners" {
  description = <<-EOF
  A map of listeners for the Application Gateway.

  Every listener contains attributes:
  - `name`                                       - (`string`, required) The name for this Frontend Port.
  - `port`                                       - (`string`, required) The port used for this Frontend Port.
  - `protocol`                                   - (`string`, optional) The Protocol to use for this HTTP Listener. Possible values are Http and Https
  - `host_names`                                 - (`list`, optional) A list of Hostname(s) should be used for this HTTP Listener. It allows special wildcard characters.
  - `ssl_profile_name`                           - (`string`, optional) The name of the associated SSL Profile which should be used for this HTTP Listener.
  - `ssl_certificate_path`                       - (`string`, optional) Path to the file with tThe base64-encoded PFX certificate data.
  - `ssl_certificate_pass`                       - (`string`, optional) Password for the pfx file specified in data.
  - `ssl_certificate_vault_id`                   - (`string`, optional) Secret Id of (base-64 encoded unencrypted pfx) Secret or Certificate object stored in Azure KeyVault.
  - `custom_error_pages`                         - (`map`, optional) Map of string, where key is HTTP status code and value is error page URL of the application gateway customer error.
  EOF
  type = map(object({
    name                     = string
    port                     = number
    protocol                 = optional(string, "Http")
    host_names               = optional(list(string))
    ssl_profile_name         = optional(string)
    ssl_certificate_path     = optional(string)
    ssl_certificate_pass     = optional(string)
    ssl_certificate_vault_id = optional(string)
    custom_error_pages       = optional(map(string), {})
  }))
  validation {
    condition = alltrue(flatten([
      for _, listener in var.listeners : [
        contains(["Http", "Https"], coalesce(listener.protocol, "Http"))
    ]]))
    error_message = "Possible values for `protocol` are Http and Https"
  }
}

variable "backend_pool" {
  description = <<-EOF
  Backend pool.

  Object contains attributes:
  - `name`         - (`string`, optional) name of the backend pool.
  - `vmseries_ips` - (`list`, optional) IP addresses of VMSeries' interfaces that will serve as backends for the Application Gateway.
  EOF
  type = object({
    name         = optional(string, "vmseries")
    vmseries_ips = optional(list(string), [])
  })
}

variable "backends" {
  description = <<-EOF
  A map of backend settings for the Application Gateway.

  Every backend contains attributes:
  - `name`                                       - (`string`, optional) The name of the backend settings
  - `path`                                       - (`string`, optional) The Path which should be used as a prefix for all HTTP requests.
  - `hostname_from_backend`                      - (`bool`, optional) Whether host header should be picked from the host name of the backend server.
  - `hostname`                                   - (`string`, optional) Host header to be sent to the backend servers.
  - `port`                                       - (`number`, required) The port which should be used for this Backend HTTP Settings Collection.
  - `protocol`                                   - (`string`, required) The Protocol which should be used. Possible values are Http and Https.
  - `timeout`                                    - (`number`, required) The request timeout in seconds, which must be between 1 and 86400 seconds.
  - `cookie_based_affinity`                      - (`string`, required) Is Cookie-Based Affinity enabled? Possible values are Enabled and Disabled.
  - `affinity_cookie_name`                       - (`string`, optional) The name of the affinity cookie.
  - `probe`                                 - (`string`, optional) Probe's key.
  - `root_certs`                                 - (`map`, optional) A list of trusted_root_certificate names.
  EOF
  default = {
    "vmseries" = {
      port                  = 80
      protocol              = "Http"
      timeout               = 60
      cookie_based_affinity = "Enabled"
    }
  }
  type = map(object({
    name                  = optional(string)
    path                  = optional(string)
    hostname_from_backend = optional(bool, false)
    hostname              = optional(string)
    port                  = optional(number, 80)
    protocol              = optional(string, "Http")
    timeout               = optional(number, 60)
    cookie_based_affinity = optional(string, "Enabled")
    affinity_cookie_name  = optional(string)
    probe                 = optional(string)
    root_certs = optional(map(object({
      name = string
      path = string
    })), {})
  }))
  validation {
    condition = alltrue(flatten([
      for _, backend in var.backends : [
        contains(["Http", "Https"], coalesce(backend.protocol, "Http"))
    ]]))
    error_message = "Possible values for `protocol` are Http and Https"
  }
  validation {
    condition = alltrue(flatten([
      for _, backend in var.backends : [
        contains(["Enabled", "Disabled"], coalesce(backend.cookie_based_affinity, "Enabled"))
    ]]))
    error_message = "Possible values for `cookie_based_affinity` are Enabled and Disabled"
  }
}

variable "probes" {
  description = <<-EOF
  A map of probes for the Application Gateway.

  Every probe contains attributes:
  - `name`                                       - (`string`, required) The name used for this Probe
  - `path`                                       - (`string`, required) The path used for this Probe
  - `host`                                       - (`string`, optional) The hostname used for this Probe
  - `port`                                       - (`number`, optional) Custom port which will be used for probing the backend servers.
  - `protocol`                                   - (`string`, optional) The protocol which should be used. Possible values are Http and Https.
  - `interval`                                   - (`number`, optional) The interval between two consecutive probes in seconds.
  - `timeout`                                    - (`number`, optional) The timeout used for this Probe, which indicates when a probe becomes unhealthy.
  - `threshold`                                  - (`number`, optional) The unhealthy Threshold for this Probe, which indicates the amount of retries which should be attempted before a node is deemed unhealthy.
  - `match_code`                                 - (`list`, optional) The list of allowed status codes for this Health Probe.
  - `match_body`                                 - (`string`, optional) A snippet from the Response Body which must be present in the Response.
  EOF
  default     = {}
  type = map(object({
    name       = string
    path       = string
    host       = optional(string)
    port       = optional(number)
    protocol   = optional(string, "Http")
    interval   = optional(number, 5)
    timeout    = optional(number, 30)
    threshold  = optional(number, 2)
    match_code = optional(list(number))
    match_body = optional(string)
  }))
  validation {
    condition = var.probes != null ? alltrue(flatten([
      for _, backend in var.probes : [
        contains(["Http", "Https"], coalesce(backend.protocol, "Http"))
    ]])) : true
    error_message = "Possible values for `protocol` are Http and Https"
  }
}

variable "rewrites" {
  description = <<-EOF
  A map of rewrites for the Application Gateway.

  Every rewrite contains attributes:
  - `name`                                       - (`string`, optional) Rewrite Rule Set name
  - `rules`                                      - (`object`, optional) Rewrite Rule Set defined with attributes:
      - `name`                                   - (`string`, required) Rewrite Rule name.
      - `sequence`                               - (`number`, required) Rule sequence of the rewrite rule that determines the order of execution in a set.
      - `conditions`                             - (`map`, optional) One or more condition blocks as defined below:
        - `pattern`                              - (`string`, required) The pattern, either fixed string or regular expression, that evaluates the truthfulness of the condition.
        - `ignore_case`                          - (`string`, required) Perform a case in-sensitive comparison.
        - `negate`                               - (`bool`, required) Negate the result of the condition evaluation.
      - `request_headers`                        - (`map`, optional) Map of request header, where header name is the key, header value is the value of the object in the map.
      - `response_headers`                       - (`map`, optional) Map of response header, where header name is the key, header value is the value of the object in the map.

  EOF
  type = map(object({
    name = optional(string)
    rules = optional(map(object({
      name     = string
      sequence = number
      conditions = optional(map(object({
        pattern     = string
        ignore_case = string
        negate      = bool
      })), {})
      request_headers  = optional(map(string), {})
      response_headers = optional(map(string), {})
    })))
  }))
}

variable "rules" {
  description = <<-EOF
  A map of rules for the Application Gateway.

  A rule combines, http settings and health check configuration.
  A key is an application name that is used to prefix all components inside Application Gateway that are created for this application.

  Every rule contains attributes:
  - `name`                                       - (`string`, required) Rule name.
  - `priority`                                   - (`string`, required) Rule evaluation order can be dictated by specifying an integer value from 1 to 20000 with 1 being the highest priority and 20000 being the lowest priority.
  - `backend`                                    - (`string`, required) Backend settings` key
  - `listener`                                   - (`string`, required) Listener's key
  - `rewrite`                                    - (`string`, optional) Rewrite's key
  - `url_path_maps`                              - (`map`, optional) URL Path Map.
  - `redirect`                                   - (`object`, optional) Redirect object defined with attributes:
      - `type`                                   - (`string`, required) The type of redirect. Possible values are Permanent, Temporary, Found and SeeOther
      - `target_listener_name`                   - (`string`, required) The name of the listener to redirect to.
      - `target_url`                             - (`string`, required) The URL to redirect the request to.
      - `include_path`                           - (`string`, required) Whether or not to include the path in the redirected URL.
      - `include_query_string`                   - (`string`, required) Whether or not to include the query string in the redirected URL.
  EOF
  type = map(object({
    name          = string
    priority      = number
    backend       = string
    listener      = string
    rewrite       = optional(string)
    url_path_maps = optional(map(string), {})
    redirect = optional(object({
      type                 = string
      target_listener_name = string
      target_url           = string
      include_path         = string
      include_query_string = string
    }))
  }))
}

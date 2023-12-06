# Main resource
variable "name" {
  description = "The name of the Application Gateway."
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

# Application Gateway
variable "zones" {
  description = <<-EOF
  A list of zones the Application Gateway should be available in.

  NOTICE: this is also enforced on the Public IP. The Public IP object brings in some limitations as it can only be non-zonal,
  pinned to a single zone or zone-redundant (so available in all zones in a region).
  Therefore make sure that if you specify more than one zone you specify all available in a region. You can use a subset,
  but the Public IP will be created in all zones anyway. This fact will cause terraform to recreate the IP resource during
  next `terraform apply` as there will be difference between the state and the actual configuration.

  For details on zones currently available in a region of your choice refer to
  [Microsoft's documentation](https://docs.microsoft.com/en-us/azure/availability-zones/az-region).

  Example:
  ```
  zones = ["1","2","3"]
  ```
  EOF
  default     = ["1", "2", "3"]
  type        = list(string)
  validation {
    condition     = var.zones == null || length(setsubtract(var.zones, ["1", "2", "3"])) == 0
    error_message = "The `var.zones` can either bea non empty list of Availability Zones or explicit `null`."
  }
}

variable "public_ip" {
  description = "Public IP address."
  type = object({
    name           = string
    resource_group = optional(string)
    create         = optional(bool, true)
  })
}

variable "domain_name_label" {
  description = <<-EOF
  Label for the Domain Name.

  Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created
  for the public IP in the Microsoft Azure DNS system."
  EOF
  default     = null
  type        = string
}

variable "enable_http2" {
  description = "Enable HTTP2 on the Application Gateway."
  default     = false
  nullable    = false
  type        = bool
}

variable "waf" {
  description = <<-EOF
  Object sets only the SKU and provide basic WAF configuration for Application Gateway.

  This module does not support WAF rules configuration and advanced WAF settings.
  Only below attributes are allowed:
  - `enabled`          - (`bool`, required) Enables WAF Application Gateway
  - `firewall_mode`    - (`string`, optional) The Web Application Firewall Mode
  - `rule_set_type`    - (`string`, optional, defaults to `OWASP`) The Type of the Rule Set used for this Web Application Firewall
  - `rule_set_version` - (`string`, optional) The Version of the Rule Set used for this Web Application Firewall
  EOF
  default = {
    enabled = false
  }
  nullable = false
  type = object({
    enabled          = bool
    firewall_mode    = optional(string)
    rule_set_type    = optional(string, "OWASP")
    rule_set_version = optional(string)
  })
  validation {
    condition     = contains(["Detection", "Prevention"], coalesce(var.waf.firewall_mode, "Detection"))
    error_message = "For `firewall_mode` possible values are Detection and Prevention"
  }
  validation {
    condition     = contains(["OWASP", "Microsoft_BotManagerRuleSet"], var.waf.rule_set_type)
    error_message = "For `rule_set_type` possible values are OWASP and Microsoft_BotManagerRuleSet"
  }
  validation {
    condition     = contains(["0.1", "1.0", "2.2.9", "3.0", "3.1", "3.2"], coalesce(var.waf.rule_set_version, "3.2"))
    error_message = "For `rule_set_version` possible values are 0.1, 1.0, 2.2.9, 3.0, 3.1 and 3.2"
  }
}

variable "capacity" {
  description = <<-EOF
  Capacity configuration for Application Gateway.

  Object defines static or autoscale configuration using attributes:
  - `static`    - (`number`, optional) A static number of Application Gateway instances. A value bewteen 1 and 125
                  or null, if autoscale configuration is provided
  - `autoscale` - (`object`, optional) Autoscaling configuration (used only, if static is null) with attributes:
    - `min`     - (`number`, optional) Minimum capacity for autoscaling.
    - `max`     - (`number`, optional) Maximum capacity for autoscaling.
  EOF
  default = {
    static = 2
  }
  nullable = false
  type = object({
    static = optional(number)
    autoscale = optional(object({
      min = optional(number)
      max = optional(number)
    }))
  })
  validation {
    condition     = coalesce(var.capacity.static, 1) >= 1 && coalesce(var.capacity.static, 125) <= 125
    error_message = "Static number of Application Gateway instances must be between 1 to 125."
  }
  validation {
    condition = (var.capacity.static != null && var.capacity.autoscale == null
    || var.capacity.static == null && var.capacity.autoscale != null)
    error_message = "Only 1 capacity configuration can be used - static or autoscale."
  }
}

variable "managed_identities" {
  description = <<-EOF
  A list of existing User-Assigned Managed Identities.

  Application Gateway uses Managed Identities to retrieve certificates from Key Vault.
  These identities have to have at least `GET` access to Key Vault's secrets.
  Otherwise Application Gateway will not be able to use certificates stored in the Vault.
  EOF
  default     = null
  type        = list(string)
}

variable "subnet_id" {
  description = <<-EOF
  An ID of a subnet that will host the Application Gateway.

  Keep in mind that this subnet can contain only AppGWs and only of the same type.
  EOF
  type        = string
}

variable "ssl_global" {
  description = <<-EOF
  Global SSL settings.

  SSL settings are defined by attributes:
  - `ssl_policy_type`                 - (`string`, required) type of an SSL policy. Possible values are `Predefined`
                                        or `Custom` or `CustomV2`. If the value is `Custom` the following values are mandatory:
                                        `ssl_policy_cipher_suites` and `ssl_policy_min_protocol_version`.
  - `ssl_policy_name`                 - (`string`, optional) name of an SSL policy.
                                        Supported only for `ssl_policy_type` set to `Predefined`.
                                        Normally you can set it also for `Custom` policies but the name is discarded
                                        on Azure side causing an update to Application Gateway each time terraform code is run.
                                        Therefore this property is omitted in the code for `Custom` policies.
                                        For the `Predefined` policies, check the Microsoft documentation
                                        https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-ssl-policy-overview
                                        for possible values as they tend to change over time.
                                        The default value is currently (Q1 2023) a Microsoft's default.
  - `ssl_policy_min_protocol_version` - (`string`, optional) minimum version of the TLS protocol for SSL Policy.
                                        Required only for `ssl_policy_type` set to `Custom`.
  - `ssl_policy_cipher_suites`        - (`list`, optional) a list of accepted cipher suites.
                                        Required only for `ssl_policy_type` set to `Custom`.
                                        For possible values see documentation:
                                        https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#cipher_suites
  EOF
  default = {
    ssl_policy_type                 = "Predefined"
    ssl_policy_name                 = "AppGwSslPolicy20220101S"
    ssl_policy_min_protocol_version = null
    ssl_policy_cipher_suites        = []
  }
  nullable = false
  type = object({
    ssl_policy_type                 = string
    ssl_policy_name                 = optional(string)
    ssl_policy_min_protocol_version = optional(string)
    ssl_policy_cipher_suites        = optional(list(string))
  })
  validation {
    condition     = contains(["Predefined", "Custom", "CustomV2"], var.ssl_global.ssl_policy_type)
    error_message = "For global SSL settings possible types are Predefined, Custom and CustomV2."
  }
  validation {
    condition = contains(["TLSv1_0", "TLSv1_1", "TLSv1_2", "TLSv1_3"],
    coalesce(var.ssl_global.ssl_policy_min_protocol_version, "TLSv1_3"))
    error_message = "For global SSL settings possible min protocol versions are TLSv1_0, TLSv1_1, TLSv1_2 and TLSv1_3."
  }
  validation {
    condition = length(setsubtract(coalesce(var.ssl_global.ssl_policy_cipher_suites, []),
      ["TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA", "TLS_DHE_DSS_WITH_AES_128_CBC_SHA", "TLS_DHE_DSS_WITH_AES_128_CBC_SHA256",
        "TLS_DHE_DSS_WITH_AES_256_CBC_SHA", "TLS_DHE_DSS_WITH_AES_256_CBC_SHA256", "TLS_DHE_RSA_WITH_AES_128_CBC_SHA",
        "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_DHE_RSA_WITH_AES_256_CBC_SHA", "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384",
        "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA", "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256",
        "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA",
        "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
        "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA", "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256", "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
        "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA", "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
        "TLS_RSA_WITH_3DES_EDE_CBC_SHA", "TLS_RSA_WITH_AES_128_CBC_SHA", "TLS_RSA_WITH_AES_128_CBC_SHA256",
        "TLS_RSA_WITH_AES_128_GCM_SHA256", "TLS_RSA_WITH_AES_256_CBC_SHA", "TLS_RSA_WITH_AES_256_CBC_SHA256",
    "TLS_RSA_WITH_AES_256_GCM_SHA384"])) == 0
    error_message = <<-EOF
    For global SSL settings possible cipher suites are: TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA, TLS_DHE_DSS_WITH_AES_128_CBC_SHA,
    TLS_DHE_DSS_WITH_AES_128_CBC_SHA256, TLS_DHE_DSS_WITH_AES_256_CBC_SHA, TLS_DHE_DSS_WITH_AES_256_CBC_SHA256,
    TLS_DHE_RSA_WITH_AES_128_CBC_SHA, TLS_DHE_RSA_WITH_AES_128_GCM_SHA256, TLS_DHE_RSA_WITH_AES_256_CBC_SHA,
    TLS_DHE_RSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA, TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,
    TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA, TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384,
    TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,
    TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA, TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,
    TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384, TLS_RSA_WITH_3DES_EDE_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA,
    TLS_RSA_WITH_AES_128_CBC_SHA256, TLS_RSA_WITH_AES_128_GCM_SHA256, TLS_RSA_WITH_AES_256_CBC_SHA,
    TLS_RSA_WITH_AES_256_CBC_SHA256 and TLS_RSA_WITH_AES_256_GCM_SHA384."
    EOF
  }
}

variable "ssl_profiles" {
  description = <<-EOF
  A map of SSL profiles.

  SSL profiles can be later on referenced in HTTPS listeners by providing a name of the profile in the `name` property.
  For possible values check the: `ssl_policy_type`, `ssl_policy_min_protocol_version` and `ssl_policy_cipher_suites`
  variables as SSL profile is a named SSL policy - same properties apply.
  The only difference is that you cannot name an SSL policy inside an SSL profile.

  Every SSL profile contains attributes:
  - `name`                            - (`string`, required) name of the SSL profile
  - `ssl_policy_name`                 - (`string`, optional) name of predefined policy
  - `ssl_policy_min_protocol_version` - (`string`, optional) the minimal TLS version.
  - `ssl_policy_cipher_suites`        - (`list`, optional) a list of accepted cipher suites.
  EOF
  type = map(object({
    name                            = string
    ssl_policy_name                 = optional(string)
    ssl_policy_min_protocol_version = optional(string)
    ssl_policy_cipher_suites        = optional(list(string))
  }))
  validation {
    condition = alltrue(flatten([
      for _, ssl_profile in var.ssl_profiles : [
        contains(["TLSv1_0", "TLSv1_1", "TLSv1_2", "TLSv1_3"], coalesce(ssl_profile.ssl_policy_min_protocol_version, "TLSv1_3"))
    ]]))
    error_message = "Possible values for `ssl_policy_min_protocol_version` are TLSv1_0, TLSv1_1, TLSv1_2 and TLSv1_3."
  }
  validation {
    condition = alltrue(flatten([
      for _, ssl_profile in var.ssl_profiles : [
        length(setsubtract(coalesce(ssl_profile.ssl_policy_cipher_suites, []),
          ["TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA", "TLS_DHE_DSS_WITH_AES_128_CBC_SHA", "TLS_DHE_DSS_WITH_AES_128_CBC_SHA256",
            "TLS_DHE_DSS_WITH_AES_256_CBC_SHA", "TLS_DHE_DSS_WITH_AES_256_CBC_SHA256", "TLS_DHE_RSA_WITH_AES_128_CBC_SHA",
            "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_DHE_RSA_WITH_AES_256_CBC_SHA", "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384",
            "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA", "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256",
            "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA",
            "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
            "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA", "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256",
            "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA",
            "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
            "TLS_RSA_WITH_3DES_EDE_CBC_SHA", "TLS_RSA_WITH_AES_128_CBC_SHA", "TLS_RSA_WITH_AES_128_CBC_SHA256",
            "TLS_RSA_WITH_AES_128_GCM_SHA256", "TLS_RSA_WITH_AES_256_CBC_SHA", "TLS_RSA_WITH_AES_256_CBC_SHA256",
          "TLS_RSA_WITH_AES_256_GCM_SHA384"]
        )) == 0
    ]]))
    error_message = <<-EOF
    Possible values for `ssl_policy_cipher_suites` are TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA, TLS_DHE_DSS_WITH_AES_128_CBC_SHA,
    TLS_DHE_DSS_WITH_AES_128_CBC_SHA256, TLS_DHE_DSS_WITH_AES_256_CBC_SHA, TLS_DHE_DSS_WITH_AES_256_CBC_SHA256,
    TLS_DHE_RSA_WITH_AES_128_CBC_SHA, TLS_DHE_RSA_WITH_AES_128_GCM_SHA256, TLS_DHE_RSA_WITH_AES_256_CBC_SHA,
    TLS_DHE_RSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,
    TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256, TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,
    TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384, TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,
    TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256, TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,
    TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384, TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384, TLS_RSA_WITH_3DES_EDE_CBC_SHA,
    TLS_RSA_WITH_AES_128_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA256, TLS_RSA_WITH_AES_128_GCM_SHA256, TLS_RSA_WITH_AES_256_CBC_SHA,
    TLS_RSA_WITH_AES_256_CBC_SHA256 and TLS_RSA_WITH_AES_256_GCM_SHA384.
    EOF
  }
  validation {
    condition = (length(flatten([for _, ssl_profile in var.ssl_profiles : ssl_profile.name])) ==
    length(distinct(flatten([for _, ssl_profile in var.ssl_profiles : ssl_profile.name]))))
    error_message = "The `name` property has to be unique among all SSL profiles."
  }
}

variable "frontend_ip_configuration_name" {
  description = "Frontend IP configuration name"
  default     = "public_ipconfig"
  nullable    = false
  type        = string
}

variable "listeners" {
  description = <<-EOF
  A map of listeners for the Application Gateway.

  Every listener contains attributes:
  - `name`                     - (`string`, required) The name for this Frontend Port.
  - `port`                     - (`string`, required) The port used for this Frontend Port.
  - `protocol`                 - (`string`, optional) The Protocol to use for this HTTP Listener.
  - `host_names`               - (`list`, optional) A list of Hostname(s) should be used for this HTTP Listener.
                                 It allows special wildcard characters.
  - `ssl_profile_name`         - (`string`, optional) The name of the associated SSL Profile which should be used
                                 for this HTTP Listener.
  - `ssl_certificate_path`     - (`string`, optional) Path to the file with tThe base64-encoded PFX certificate data.
  - `ssl_certificate_pass`     - (`string`, optional) Password for the pfx file specified in data.
  - `ssl_certificate_vault_id` - (`string`, optional) Secret Id of (base-64 encoded unencrypted pfx) Secret
                                 or Certificate object stored in Azure KeyVault.
  - `custom_error_pages`       - (`map`, optional) Map of string, where key is HTTP status code and value is
                                 error page URL of the application gateway customer error.
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
        contains(["Http", "Https"], listener.protocol)
    ]]))
    error_message = "Possible values for `protocol` are `Http` and `Https`."
  }
  validation {
    condition = alltrue(flatten([
      for _, listener in var.listeners : (listener.port >= 1 && listener.port <= 65535)
    ]))
    error_message = "The listener `port` should be a valid TCP port number from 1 to 65535."
  }
  validation {
    condition = alltrue(flatten([
      for _, listener in var.listeners : (listener.protocol == "Https" ?
        try(length(coalesce(listener.ssl_certificate_vault_id, listener.ssl_certificate_path)), -1) > 0
      : true)
    ]))
    error_message = "If `Https` protocol is used, then SSL certificate (from file or Azure Key Vault) is required"
  }
  validation {
    condition = alltrue(flatten([
      for _, listener in var.listeners : (listener.protocol == "Https" ?
        try(length(listener.ssl_certificate_pass), -1) >= 0
      : true)
    ]))
    error_message = "If `Https` protocol is used, then SSL certificate password is required"
  }
  validation {
    condition = (length(flatten([for _, listener in var.listeners : listener.name])) ==
    length(distinct(flatten([for _, listener in var.listeners : listener.name]))))
    error_message = "The `name` property has to be unique among all listeners."
  }
}

variable "backend_pool" {
  description = <<-EOF
  Backend pool.

  Object contains attributes:
  - `name`         - (`string`, required) name of the backend pool.
  - `vmseries_ips` - (`list`, optional, defaults to `[]`) IP addresses of VMSeries' interfaces that will serve as backends
                     for the Application Gateway.
  EOF
  default = {
    name = "vmseries"
  }
  nullable = false
  type = object({
    name         = string
    vmseries_ips = optional(list(string), [])
  })
}

variable "backends" {
  description = <<-EOF
  A map of backend settings for the Application Gateway.

  Every backend contains attributes:
  - `name`                  - (`string`, optional) The name of the backend settings
  - `path`                  - (`string`, optional) The Path which should be used as a prefix for all HTTP requests.
  - `hostname_from_backend` - (`bool`, optional) Whether host header should be picked from the host name of the backend server.
  - `hostname`              - (`string`, optional) Host header to be sent to the backend servers.
  - `port`                  - (`number`, required) The port which should be used for this Backend HTTP Settings Collection.
  - `protocol`              - (`string`, required) The Protocol which should be used. Possible values are Http and Https.
  - `timeout`               - (`number`, required) The request timeout in seconds, which must be between 1 and 86400 seconds.
  - `cookie_based_affinity` - (`string`, required) Is Cookie-Based Affinity enabled? Possible values are Enabled and Disabled.
  - `affinity_cookie_name`  - (`string`, optional) The name of the affinity cookie.
  - `probe`                 - (`string`, optional) Probe's key.
  - `root_certs`            - (`map`, optional) A list of trusted_root_certificate names.
  EOF
  default = {
    "minimum" = {
      name = "minimum"
    }
  }
  nullable = false
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
        contains(["Http", "Https"], backend.protocol)
    ]]))
    error_message = "Possible values for `protocol` are `Http` and `Https`."
  }
  validation {
    condition = alltrue(flatten([
      for _, backend in var.backends : [
        contains(["Enabled", "Disabled"], backend.cookie_based_affinity)
    ]]))
    error_message = "Possible values for `cookie_based_affinity` are Enabled and Disabled."
  }
  validation {
    condition = alltrue(flatten([
      for _, backend in var.backends : (backend.port >= 1 && backend.port <= 65535)
    ]))
    error_message = "The backend `port` should be a valid TCP port number from 1 to 65535."
  }
  validation {
    condition = alltrue(flatten([
      for _, backend in var.backends : (backend.timeout != null ? backend.timeout >= 1 && backend.timeout <= 86400 : true)
    ]))
    error_message = "The backend `timeout` property should can take values between 1 and 86400 (seconds)."
  }
  validation {
    condition = (length(flatten([for _, backend in var.backends : backend.name])) ==
    length(distinct(flatten([for _, backend in var.backends : backend.name]))))
    error_message = "The `name` property has to be unique among all backends."
  }
}

variable "probes" {
  description = <<-EOF
  A map of probes for the Application Gateway.

  Every probe contains attributes:
  - `name`       - (`string`, required) The name used for this Probe
  - `path`       - (`string`, required) The path used for this Probe
  - `host`       - (`string`, optional) The hostname used for this Probe
  - `port`       - (`number`, optional) Custom port which will be used for probing the backend servers.
  - `protocol`   - (`string`, optional, defaults `Http`) The protocol which should be used.
  - `interval`   - (`number`, optional, defaults `5`) The interval between two consecutive probes in seconds.
  - `timeout`    - (`number`, optional, defaults `30`) The timeout used for this Probe,
                   which indicates when a probe becomes unhealthy.
  - `threshold`  - (`number`, optional, defaults `2`) The unhealthy Threshold for this Probe, which indicates
                   the amount of retries which should be attempted before a node is deemed unhealthy.
  - `match_code` - (`list`, optional) The list of allowed status codes for this Health Probe.
  - `match_body` - (`string`, optional) A snippet from the Response Body which must be present in the Response.
  EOF
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
        contains(["Http", "Https"], backend.protocol)
    ]])) : true
    error_message = "Possible values for `protocol` are `Http` and `Https`."
  }
  validation {
    condition = (length(flatten([for _, probe in var.probes : probe.name])) ==
    length(distinct(flatten([for _, probe in var.probes : probe.name]))))
    error_message = "The `name` property has to be unique among all probes."
  }
  validation {
    condition = alltrue(flatten([
      for _, probe in var.probes : ((coalesce(probe.port, 80)) >= 1 && (coalesce(probe.port, 80)) <= 65535)
    ]))
    error_message = "The probe `port` should be a valid TCP port number from 1 to 65535."
  }
  validation {
    condition = alltrue(flatten([
      for _, probe in var.probes : (probe.timeout != null ? probe.timeout >= 1 && probe.timeout <= 86400 : true)
    ]))
    error_message = "The probe `timeout` property should can take values between 1 and 86400 (seconds)."
  }
  validation {
    condition = alltrue(flatten([
      for _, probe in var.probes : (probe.interval != null ? probe.interval >= 1 && probe.interval <= 86400 : true)
    ]))
    error_message = "The probe `interval` property should can take values between 1 and 86400 (seconds)."
  }
  validation {
    condition = alltrue(flatten([
      for _, probe in var.probes : (probe.threshold != null ? probe.threshold >= 1 && probe.threshold <= 20 : true)
    ]))
    error_message = "The probe `threshold` property should can take values between 1 and 20."
  }
}

variable "rewrites" {
  description = <<-EOF
  A map of rewrites for the Application Gateway.

  Every rewrite contains attributes:
  - `name`                - (`string`) Rewrite Rule Set name
  - `rules`               - (`object`, optional) Rewrite Rule Set defined with attributes:
      - `name`            - (`string`, required) Rewrite Rule name.
      - `sequence`        - (`number`, required) Rule sequence of the rewrite rule that determines
                            the order of execution in a set.
      - `conditions`      - (`map`, optional) One or more condition blocks as defined below:
        - `pattern`       - (`string`, required) The pattern, either fixed string or regular expression,
                            that evaluates the truthfulness of the condition.
        - `ignore_case`   - (`string`, optional, defaults to `false`) Perform a case in-sensitive comparison.
        - `negate`        - (`bool`, optional, defaults to `false`) Negate the result of the condition evaluation.
      - `request_headers` - (`map`, optional) Map of request header, where header name is the key,
                            header value is the value of the object in the map.
      - `response_headers`- (`map`, optional) Map of response header, where header name is the key,
                            header value is the value of the object in the map.
  EOF
  type = map(object({
    name = string
    rules = optional(map(object({
      name     = string
      sequence = number
      conditions = optional(map(object({
        pattern     = string
        ignore_case = optional(bool, false)
        negate      = optional(bool, false)
      })), {})
      request_headers  = optional(map(string), {})
      response_headers = optional(map(string), {})
    })))
  }))
  validation {
    condition = (length(flatten([for _, rewrite in var.rewrites : rewrite.name])) ==
    length(distinct(flatten([for _, rewrite in var.rewrites : rewrite.name]))))
    error_message = "The `name` property has to be unique among all rewrites."
  }
}

variable "rules" {
  description = <<-EOF
  A map of rules for the Application Gateway.

  A rule combines, backend, listener, rewrites and redirects configurations.
  A key is an application name that is used to prefix all components inside Application Gateway
  that are created for this application.

  Every rule contains attributes:
  - `name`         - (`string`, required) Rule name.
  - `priority`     - (`string`, required) Rule evaluation order can be dictated by specifying an integer value
                     from 1 to 20000 with 1 being the highest priority and 20000 being the lowest priority.
  - `backend`      - (`string`, optional) Backend settings` key
  - `listener`     - (`string`, required) Listener's key
  - `rewrite`      - (`string`, optional) Rewrite's key
  - `url_path_map` - (`string`, optional) URL Path Map's key
  - `redirect`     - (`string`, optional) Redirect's key
  EOF
  type = map(object({
    name         = string
    priority     = number
    backend      = optional(string)
    listener     = string
    rewrite      = optional(string)
    url_path_map = optional(string)
    redirect     = optional(string)
  }))
  validation {
    condition = alltrue(flatten([
      for _, rule in var.rules : [
        rule.priority >= 1, rule.priority <= 20000
    ]]))
    error_message = "Rule priority is integer value from 1 to 20000."
  }
  validation {
    condition = (length(flatten([for _, rule in var.rules : rule.name])) ==
    length(distinct(flatten([for _, rule in var.rules : rule.name]))))
    error_message = "The `name` property has to be unique among all rules."
  }
  validation {
    condition = alltrue([for _, rule in var.rules :
      rule.backend != null && rule.redirect == null && rule.url_path_map == null ||
      rule.backend == null && rule.redirect != null && rule.url_path_map == null ||
      rule.backend == null && rule.redirect == null && rule.url_path_map != null
    ])
    error_message = "Either `backend`, `redirect` or `url_path_map` is required, but not all as they are mutually exclusive."
  }
}

variable "redirects" {
  description = <<-EOF
  A map of redirects for the Application Gateway.

  Every redirect contains attributes:
  - `name`                 - (`string`, required) The name of redirect.
  - `type`                 - (`string`, required) The type of redirect.
                             Possible values are Permanent, Temporary, Found and SeeOther
  - `target_listener`      - (`string`, optional) The name of the listener to redirect to.
  - `target_url`           - (`string`, optional) The URL to redirect the request to.
  - `include_path`         - (`bool`, optional) Whether or not to include the path in the redirected URL.
  - `include_query_string` - (`bool`, optional) Whether or not to include the query string in the redirected URL.
  EOF
  type = map(object({
    name                 = string
    type                 = string
    target_listener      = optional(string)
    target_url           = optional(string)
    include_path         = optional(bool, false)
    include_query_string = optional(bool, false)
  }))
  validation {
    condition = var.redirects != null ? alltrue(flatten([
      for _, redirect in var.redirects : [
        contains(["Permanent", "Temporary", "Found", "SeeOther"], coalesce(redirect.type, "Permanent"))
    ]])) : true
    error_message = "Possible values for `type` are Permanent, Temporary, Found and SeeOther."
  }
  validation {
    condition = (length(flatten([for _, redirect in var.redirects : redirect.name])) ==
    length(distinct(flatten([for _, redirect in var.redirects : redirect.name]))))
    error_message = "The `name` property has to be unique among all redirects."
  }
}

variable "url_path_maps" {
  description = <<-EOF
  A map of URL path maps for the Application Gateway.

  Every URL path map contains attributes:
  - `name`         - (`string`, required) The name of redirect.
  - `backend`      - (`string`, required) The default backend for redirect.
  - `path_rules`   - (`map`, optional) The map of rules, where every object has attributes:
      - `paths`    - (`list`, required) List of paths
      - `backend`  - (`string`, optional) Backend's key
      - `redirect` - (`string`, optional) Redirect's key
  EOF
  type = map(object({
    name    = string
    backend = string
    path_rules = optional(map(object({
      paths    = list(string)
      backend  = optional(string)
      redirect = optional(string)
    })))
  }))
  validation {
    condition = (length(flatten([for _, url_path_map in var.url_path_maps : url_path_map.name])) ==
    length(distinct(flatten([for _, url_path_map in var.url_path_maps : url_path_map.name]))))
    error_message = "The `name` property has to be unique among all URL path maps."
  }
}

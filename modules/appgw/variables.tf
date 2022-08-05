variable "resource_group_name" {
  description = "Name of an existing resource group."
  type        = string
}

variable "location" {
  description = "Location to place the Application Gateway in."
  type        = string
}

variable "name" {
  description = "Name of the Application Gateway."
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

variable "sku" {
  description = "Sku of the Application Gateway. Check Microsoft documentation for possible values,their combinations and limitations."
  default = {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
  type = object({
    name     = string
    tier     = string
    capacity = number
  })
}

variable "subnet_id" {
  description = "An ID of a subnet that will host the Application Gateway. Keep in mind that this subnet can contain only AppGWs and only of the same type."
  type        = string
}

variable "vmseries_ips" {
  description = "IP addresses of VMSeries' interfaces that will serve as backends for the Application Gateway."
  type        = list(string)
}

variable "rules" {
  description = <<-EOF
    A map of rules for the Application Gateway. A rule combines listener, http settings and health check configuration. 
    A key is an application name that is used to prefix all components inside Application Gateway that are created for this application. 

    For maximum and minimum values for particular properties please refer to Microsoft documentation.

    The following general properties are available:

    * priority - (optional, for v2 gateways only) rule's priority
    * xff_strip_port - (optional, for v2 gateways only) enables a rewrite rule set that strips the port number from X-Forwarded-For header
    * listener - provides general listener setting like port, protocol, error pages, etc (for details see below)
    * backend - (optional) complete http settings configuration (for details see below)
    * probe - (optional) health check probe configuration (for details see below)
    * redirect - (optional) mutually exclusive with backend and probe, creates a redirect rule (for details see below)

    Details on each of the properties can be found [here](#rules-property-explained).
  EOF

  # validation {
  #   # The following conditions are checked:
  #   # - at least one of `backend_hostname` or `backend_hostname_from_backend` is set when we define a probe w/o setting `probe_host`
  #   # - and
  #   # - we do not set `backend_hostname` and `backend_hostname_from_backend` at the same time
  #   # - and
  #   # - for v2 all rules have or do not have `priority` set. We cannot have a mix of rules with priority set or not.
  #   condition = (alltrue([
  #     for k, v in var.rules : (
  #       (can(v.probe_path) ? can(v.probe_host) : true)
  #       || can(v.backend_hostname)
  #       || try(v.backend_hostname_from_backend, false)
  #       ) && !(
  #       can(v.backend_hostname)
  #       && try(v.backend_hostname_from_backend, false)
  #     )
  #     ])) && (alltrue([
  #     for k, v in var.rules : can(v.priority)
  #   ]))
  #   error_message = "Please check one of the rules for following configuration issues: \n - one cannot have a probe w/o a host name specified having at the same time http settings that do not override a host header \n - one cannot set a backend host name and force the http settings to set the host header to a backend's hostname at the same time \n - for v2 tiers one cannot use `priority` in a subset of rules; you have to specify it in either all or none."
  # }
  type = any
}

variable "ssl_policy_type" {
  description = <<-EOF
  Type of an SSL policy. Possible values are `Predefined` or `Custom`.
  If the value is `Custom` the following values are mandatory: `ssl_policy_cipher_suites` and `ssl_policy_min_protocol_version`.
  EOF
  default     = "Predefined"
  type        = string
}

variable "ssl_policy_name" {
  description = <<-EOF
  Name of an SSL policy. Supported only for `ssl_policy_type` set to `Predefined`. Normally you can set it also for `Custom` policies but the name is discarded on Azure side causing an update to Application Gateway each time terraform code is run. Therefore this property is omited in the code for `Custom` policies. 
  
  For the `Predefined` polcies, check the [Microsoft documentation](https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-ssl-policy-overview) for possible values as they tend to change over time. The default value is currently (Q1 2022) a Microsoft's default.
  EOF
  default     = "AppGwSslPolicy20150501"
  type        = string
}

variable "ssl_policy_min_protocol_version" {
  description = <<-EOF
  Minimum version of the TLS protocol for SSL Policy. Required only for `ssl_policy_type` set to `Custom`. 
  Possible values are: `TLSv1_0`, `TLSv1_1` or `TLSv1_2`.
  EOF
  default     = null
  type        = string
}

variable "ssl_policy_cipher_suites" {
  description = <<-EOF
  A List of accepted cipher suites. Required only for `ssl_policy_type` set to `Custom`. 
  For possible values see [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#cipher_suites).
  EOF
  default     = null
  type        = list(string)
}

variable "ssl_profiles" {
  description = <<-EOF
  **Application Gateway v2 only.**
  
  A map of SSL profiles that can be later on referenced in HTTPS listeners by providing a name of the profile in the `ssl_profile_name` property. 

  The structure of the map is as follows:
  ```
  {
    profile_name = {
      ssl_policy_type                 = string
      ssl_policy_min_protocol_version = string
      ssl_policy_cipher_suites        = list
    }
  }
  ```
  For possible values check the: `ssl_policy_type`, `ssl_policy_min_protocol_version` and `ssl_policy_cipher_suites` variables as SSL profile is a named SSL policy - same properties apply. The only difference is that you cannot name an SSL policy inside an SSL profile. 
  EOF
  default     = {}
  type        = map(any)
}

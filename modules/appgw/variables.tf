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
  description = "An existing user-assigned managed identity, which Application Gateway uses to retrieve certificates from Key Vault."
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

    For maximum and minimum values for particular protperties please refer to Microsoft documentation.

    The following properties are available:

    ```
    - `listener_protocol`
      - example value: "http" 
      - description: listener protocol, this can be `http` or `https`, defaults to `http`
    - `host_names`
      - example value: ["www.example.net"]
      - list of host header values this rule should react on, this creates a Multi-Site listener, for V1 Application Gateways only 1st item from the list is being used as V1 does not support multiple host headers
    - `custom_error_configuration`
      - example value: `{ HttpStatus403 = "http://error.com/403/page.html", HttpStatus502 = "http://error.com/502/page.html" }`
      - a map that contains ULRs to custom error pages. Keys in this map are not custom, they reflect the actual properties used by the provider. URLs are only customizable and they have to contain the protocol and have to point directly to an HTML file. Both are optional, so only one can be specified.
    
    - `backend_port`
      - example value: `80`
      - port on which the backend is actually listening, defaults to `80`
    - `backend_protocol`
      - example value: "http"
      - protocol for the backend service, this can be `http` or `https`, defaults to `http`
    - `backend_hostname_from_backend`
      - example value: `true`
      - override host header with backend's host name, defaults to `false`, mutually exclusive with `backend_hostname`. When both are not set the host header of the original request remains unchainged. At least one has to be specified if the `probe_host` is not set. When both (`backend_hostname` and `backend_hostname_from_backend` are set the module acts like non of them is set
    - `backend_hostname`
      - example value: "host.name
      - override host header with a custom host name, when not set defaults to the host header of the original request, mutually exclusive with `backend_hostname_from_backend` (see above)
    - `backend_timeout`
      - example value: 60
      - timeout for backend's response in seconds, default to 60s
    - `backend_path`
      - example value: "/path"
      - path prefix, in case we need to shift the url path for the backend, optinal, can be omited
    - `cookie_based_affinity`
      - example value: "Enabled"
      - cookie based routing, defaults to `Enabled`
    - `affinity_cookie_name`
      - example value: "SomeCookieName"
      - name of the affinity cookie, defaults to Azure default name
    - `backend_root_certs`
      - example value: `{ some_root_cert = "./files/self_signed.crt" }`
      - (v2 only) a map of custom root certificates used to sign backend's certificate.
    
    - `probe_path`
      - example value: "/healthcheck"
      - url for the health check endpoint, this property controls if the custom probe is created or not. If this is not set, http settings will have the property `Use custom probe` set to `No`
    - `probe_host`
      - example value: "www.example.com"
      - host header for the health check probe, when omited sets the `Pick host name from backend HTTP settings` to `Yes`. Cannot be omited when `backend_hostname` nor `backend_hostname_from_backend` are not set.
    - `probe_port`
      - example value: `80`
      - (v2 only) port for the health check, defaults to default protocol port
    - `probe_interval`
      - example value: 2
      - probe interval in seconds, defaults to 5
    - `probe_timeout`
      - example value: 30
      - probe timeout in seconds, defaults to 30
    - `probe_theshold`
      - example value: 2
      - number of failed probes until the bakckend is marked as down, defaults to 2
    - `probe_match_code`
      - example value: [200]
      - a list of acceptible http response codes. `probe_match_code` controls the custom match condition for a health probe, if not set, it disables the custom match conditions.
    - `probe_match_body`
      - example value: ""
      - a snippet of the backend response that can be matched for health check conditions, defaults to an empty string
    
    - `ssl_certificate_path`
      - example value: "cert/path"
      - a path to a certificate in `.pfx` format. Required only for `https` listeners
    - `ssl_certificate_pass`
      - example value: "cert_password"
      - a matching password for the certificate specified in `ssl_certificate_path`
    ```
  EOF
  validation {
    # The following conditions are checked:
    # - at least one of `backend_hostname` or `backend_hostname_from_backend` is set when we define a probe w/o setting `probe_host`
    # - and
    # - we do not set `backend_hostname` and `backend_hostname_from_backend` at the same time
    # - and
    # - for v2 all rules have or do not have `priority` set. We cannot have a mix of rules with priority set or not.
    condition = (alltrue([
      for k, v in var.rules : (
        (can(v.probe_path) ? can(v.probe_host) : true)
        || can(v.backend_hostname)
        || try(v.backend_hostname_from_backend, false)
        ) && !(
        can(v.backend_hostname)
        && try(v.backend_hostname_from_backend, false)
      )
      ])) && (alltrue([
      for k, v in var.rules : can(v.priority)
    ]))
    error_message = "Please check one of the rules for following configuration issues: \n - one cannot have a probe w/o a host name specified having at the same time http settings that do not override a host header \n - one cannot set a backend host name and force the http settings to set the host header to a backend's hostname at the same time \n - for v2 tiers one cannot use `priority` in a subset of rules; you have to specify it in either all or none."
  }
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

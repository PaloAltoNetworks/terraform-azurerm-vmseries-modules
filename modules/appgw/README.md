# Palo Alto Networks VNet Module for Azure

A terraform module for deploying an Application Gateway. The module is designed to be dedicated to the FW, hence it supports only one backend - the NGFWs.

## Usage

It requires that Firewalls and a dedicated subnet are set up already.

```hcl
module "appgw" {
  source = "../modules/appgw"

  name                = "example-public-appgw"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  subnet_id           = module.security_vnet.subnet_ids["subnet-appgw"]
  sku = {
    name     = "Standard_Medium"
    tier     = "Standard"
    capacity = 2
  }
  vmseries_ips = ["x.x.x.x", "x.x.x.x"]
  rules = {
    "example-http-app" = {
      listener_port         = 80
      listener_protocol     = "http"
      host_names            = ["www.example.net"]
      cookie_based_affinity = "Disabled"

      backend_port     = 80
      backend_protocol = "http"
      backend_timeout  = 60
      backend_path     = "/path"

      priority = 1

      probe_host       = "www.example.com"
      probe_protocol   = "http"
      probe_path       = "/"
      probe_port       = 80
      probe_interval   = 2
      probe_timeout    = 30
      probe_theshold   = 2
      probe_match_code = [200]
    }
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.29, < 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 2.90 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 2.90 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Location to place the Application Gateway in. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Application Gateway. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of an existing resource group. | `string` | n/a | yes |
| <a name="input_rules"></a> [rules](#input\_rules) | A map of rules for the Application Gateway. A rule combines listener, http settings and health check configuration. <br>A key is an application name that is used to prefix all components inside Application Gateway that are created for this application. <br><br>For maximum and minimum values for particular protperties please refer to Microsoft documentation.<br><br>The following properties are available:<pre>- `listener_protocol`<br>  - example value: "http" <br>  - description: listener protocol, this can be `http` or `https`, defaults to `http`<br>- `host_names`<br>  - example value: ["www.example.net"]<br>  - list of host header values this rule should react on, this creates a Multi-Site listener, for V1 Application Gateways only 1st item from the list is being used as V1 does not support multiple host headers<br>- `custom_error_configuration`<br>  - example value: `{ HttpStatus403 = "http://error.com/403/page.html", HttpStatus502 = "http://error.com/502/page.html" }`<br>  - a map that contains ULRs to custom error pages. Keys in this map are not custom, they reflect the actual properties used by the provider. URLs are only customizable and they have to contain the protocol and have to point directly to an HTML file. Both are optional, so only one can be specified.<br>    <br>- `backend_port`<br>  - example value: `80`<br>  - port on which the backend is actually listening, defaults to `80`<br>- `backend_protocol`<br>  - example value: "http"<br>  - protocol for the backend service, this can be `http` or `https`, defaults to `http`<br>- `backend_hostname_from_backend`<br>  - example value: `true`<br>  - override host header with backend's host name, defaults to `false`, mutually exclusive with `backend_hostname`. When both are not set the host header of the original request remains unchainged. At least one has to be specified if the `probe_host` is not set. When both (`backend_hostname` and `backend_hostname_from_backend` are set the module acts like non of them is set<br>- `backend_hostname`<br>  - example value: "host.name<br>  - override host header with a custom host name, when not set defaults to the host header of the original request, mutually exclusive with `backend_hostname_from_backend` (see above)<br>- `backend_timeout`<br>  - example value: 60<br>  - timeout for backend's response in seconds, default to 60s<br>- `backend_path`<br>  - example value: "/path"<br>  - path prefix, in case we need to shift the url path for the backend, optinal, can be omited<br>- `cookie_based_affinity`<br>  - example value: "Enabled"<br>  - cookie based routing, defaults to `Enabled`<br>- `affinity_cookie_name`<br>  - example value: "SomeCookieName"<br>  - name of the affinity cookie, defaults to Azure default name<br>- `backend_root_certs`<br>  - example value: `{ some_root_cert = "./files/self_signed.crt" }`<br>  - (v2 only) a map of custom root certificates used to sign backend's certificate.<br>    <br>- `probe_path`<br>  - example value: "/healthcheck"<br>  - url for the health check endpoint, this property controls if the custom probe is created or not. If this is not set, http settings will have the property `Use custom probe` set to `No`<br>- `probe_host`<br>  - example value: "www.example.com"<br>  - host header for the health check probe, when omited sets the `Pick host name from backend HTTP settings` to `Yes`. Cannot be omited when `backend_hostname` nor `backend_hostname_from_backend` are not set.<br>- `probe_port`<br>  - example value: `80`<br>  - (v2 only) port for the health check, defaults to default protocol port<br>- `probe_interval`<br>  - example value: 2<br>  - probe interval in seconds, defaults to 5<br>- `probe_timeout`<br>  - example value: 30<br>  - probe timeout in seconds, defaults to 30<br>- `probe_theshold`<br>  - example value: 2<br>  - number of failed probes until the bakckend is marked as down, defaults to 2<br>- `probe_match_code`<br>  - example value: [200]<br>  - a list of acceptible http response codes. `probe_match_code` controls the custom match condition for a health probe, if not set, it disables the custom match conditions.<br>- `probe_match_body`<br>  - example value: ""<br>  - a snippet of the backend response that can be matched for health check conditions, defaults to an empty string<br>    <br>- `ssl_certificate_path`<br>  - example value: "cert/path"<br>  - a path to a certificate in `.pfx` format. Required only for `https` listeners<br>- `ssl_certificate_pass`<br>  - example value: "cert_password"<br>  - a matching password for the certificate specified in `ssl_certificate_path`</pre> | `any` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | Sku of the Application Gateway. Check Microsoft documentation for possible values,their combinations and limitations. | <pre>object({<br>    name     = string<br>    tier     = string<br>    capacity = number<br>  })</pre> | <pre>{<br>  "capacity": 2,<br>  "name": "Standard_v2",<br>  "tier": "Standard_v2"<br>}</pre> | no |
| <a name="input_ssl_policy_cipher_suites"></a> [ssl\_policy\_cipher\_suites](#input\_ssl\_policy\_cipher\_suites) | A List of accepted cipher suites. Required only for `ssl_policy_type` set to `Custom`. <br>For possible values see [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#cipher_suites). | `list(string)` | `null` | no |
| <a name="input_ssl_policy_min_protocol_version"></a> [ssl\_policy\_min\_protocol\_version](#input\_ssl\_policy\_min\_protocol\_version) | Minimum version of the TLS protocol for SSL Policy. Required only for `ssl_policy_type` set to `Custom`. <br>Possible values are: `TLSv1_0`, `TLSv1_1` or `TLSv1_2`. | `string` | `null` | no |
| <a name="input_ssl_policy_name"></a> [ssl\_policy\_name](#input\_ssl\_policy\_name) | Name of an SSL policy. Supported only for `ssl_policy_type` set to `Predefined`. Normally you can set it also for `Custom` policies but the name is discarded on Azure side causing an update to Application Gateway each time terraform code is run. Therefore this property is omited in the code for `Custom` policies. <br><br>For the `Predefined` polcies, check the [Microsoft documentation](https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-ssl-policy-overview) for possible values as they tend to change over time. The default value is currently (Q1 2022) a Microsoft's default. | `string` | `"AppGwSslPolicy20150501"` | no |
| <a name="input_ssl_policy_type"></a> [ssl\_policy\_type](#input\_ssl\_policy\_type) | Type of an SSL policy. Possible values are `Predefined` or `Custom`.<br>If the value is `Custom` the following values are mandatory: `ssl_policy_cipher_suites` and `ssl_policy_min_protocol_version`. | `string` | `"Predefined"` | no |
| <a name="input_ssl_profiles"></a> [ssl\_profiles](#input\_ssl\_profiles) | **Application Gateway v2 only.**<br><br>A map of SSL profiles that can be later on referenced in HTTPS listeners by providing a name of the profile in the `ssl_profile_name` property. <br><br>The structure of the map is as follows:<pre>{<br>  profile_name = {<br>    ssl_policy_type                 = string<br>    ssl_policy_min_protocol_version = string<br>    ssl_policy_cipher_suites        = list<br>  }<br>}</pre>For possible values check the: `ssl_policy_type`, `ssl_policy_min_protocol_version` and `ssl_policy_cipher_suites` variables as SSL profile is a named SSL policy - same properties apply. The only difference is that you cannot name an SSL policy inside an SSL profile. | `map(any)` | `{}` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | An ID of a subnet that will host the Application Gateway. Keep in mind that this subnet can contain only AppGWs and only of the same type. | `string` | n/a | yes |
| <a name="input_vmseries_ips"></a> [vmseries\_ips](#input\_vmseries\_ips) | IP addresses of VMSeries' interfaces that will serve as backends for the Application Gateway. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | A public IP assigned to the Application Gateway. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

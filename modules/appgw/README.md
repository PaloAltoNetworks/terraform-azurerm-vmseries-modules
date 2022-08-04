# Palo Alto Networks VNet Module for Azure

A terraform module for deploying an Application Gateway. The module is designed to be dedicated to the FW, hence it supports only one backend - the NGFWs.

## Rules property explained

The `rules` property combines configuration for several Application Gateway components and groups them by a logical application. In other words, an application defines a listener, http settings, health check probe or redirect rules. Those are always unique for an application, meaning that you cannot share them between application definitions. Most of the settings are optional and depend on a use case. The only one that is required is the listener port (for v2 Gateways a rule priority is a must since 2022 AzureRM API updates).

In general `rules` property is a map where a key is the logical application name and value is a set of properties, like below (AppGWv2 example):

```hcl
rules = {
  "redirect_2_app_1 = {
    priority = 1
    listener = {
      port = 80
    }
    redirect = {
      type                 = "Temporary"
      target_listener_name = "application_1-listener"
      include_path         = true
      include_query_string = true
    }
  }
  "application_1" = {
    priority = 2
    listener = {
      port = 443
      protocol = "Https"
      ssl_certificate_path = "/path/to/cert"
      ssl_certificate_pass = "cert_password"
    }
  }
}
```

The example above is a setup where the AppGW serves only as a reverse proxy terminating SSL connections (by default all traffic sent to the backend pool is sent to port 80, plain text). It also redirects all http communication sent to port 80 to https on port 443.

As you can see in the `target_listener_name` property, all Application Gateway component created for an application are prefixed with the application name (so the key value).

For each application one can configure the following properties:

* priority - (optional fot v1 gateways only) rule's priority
* [listener](#property-listener) - provides general listener setting like port, protocol, error pages, etc
* [backend](#property-backend) - (optional) complete http settings configuration
* [probe](#property-probe) - (optional) health check probe configuration
* [redirect](#property-redirect) - (optional) mutually exclusive with backend and probe, creates a redirect rule

For details on each of them (except for `priority`) see below.

### property: listener

Configures the listener, frontend port and, optionally, the SSL Certificate component that will be used by the listener (required for `https` listeners). The following properties are available:

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `port` | a port number | `number` | n/a | yes |
| `protocol` | either `Http` or `Https` (case sensitive) | `string` | `"Http"` | no |
| `host_names` | host header values this rule should react on, this creates a Multi-Site listener, for V1 Application Gateways only 1st item from the list is being used as V1 does not support multiple host headers | `list(string)` | `null` | no |
| `ssl_certificate_path` | a path to a certificate in `.pfx` format | `string` | `null` | yes, if protocol == `https`, mutually exclusive with `ssl_certificate_vault_id` |
| `ssl_certificate_pass` | a matching password for the certificate specified in `ssl_certificate_path` | `string` | `null` | yes, if protocol == `https`, mutually exclusive with `ssl_certificate_vault_id` |
| `ssl_certificate_vault_id` | an ID of a certificate stored in a Azure Key Vault, requires `managed_identities` property, the identity(-ties) used has to have at least `GET` access to Key Vault's secrets | `string` | `null` | yes, if protocol == `https`, mutually exclusive with `ssl_certificate_path` |
| `custom_error_pages` | a map that contains ULRs for custom error pages, for more information see below | `map` | `null` | no |

The `custom_error_pages` map has the following format:

```hcl
custom_error_pages = { 
  HttpStatus403 = "http://error.com/403/page.html",
  HttpStatus502 = "http://error.com/502/page.html"
}
```

Keys can have values only like the ones above. Both are optional though. Only the error page path is customizable and it has to point to a HTML file.

### property: backend

Configures the backend's http setting, so any port and protocol properties for a connection between an Application Gateway and the actual Firewalls. Following properties are available:

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `port` | port on which the backend is actually listening | `number` | `80` | no |
| `protocol` | protocol for the backend service, this can be `Http` or `Https` | `string` | `"Http"` | no |
| `hostname_from_backend` | override host header with backend's host name, when both are not set the host header of the original request remains unchanged, has to be specified if the `probe_host` is not set | `bool` | `false` | no, mutually exclusive with `hostname` |
| `hostname` | override host header with a custom host name, when not set defaults to the host header of the original request | `string` | `null` | no, mutually exclusive with `hostname_from_backend` (see above) |
| `path` | path prefix, in case we need to shift the url path for the backend | `string` | `null` | no |
| `timeout` | timeout for backend's response in seconds | `number` | `60` | no |
| `cookie_based_affinity` | cookie based routing | `string` | `"Enabled"` | no |
| `affinity_cookie_name` | name of the affinity cookie, when skipped defaults to Azure's default name | `string` | `null` | no |
| `root_certs` | (v2 only) for https traffic only, a map of custom root certificates used to sign backend's certificate (see below) | `map` | `null` | no |

The `root_certs` map has the following format:

```hcl
root_certs = {
  some_root_cert = "./files/ca.crt"
}
```

### property: probe

Configures a health check probe. A probe is fully customizable, meaning that one decides what should be probed, the FW or an application behind it.

One can decide on the port used by the probe but the protocol is always aligned to the one set in http settings.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `path` | url for the health check endpoint, this property controls if the custom probe is created or not, if this is not set, http settings will have the property `Use custom probe` set to `No` | `string` | `null` | no |
| `host` | host header for the health check probe, when omitted sets the `Pick host name from backend HTTP settings` to `Yes`, cannot be skipped when `backend.hostname` or `backend.hostname_from_backend` are not set | `string` | `null` | no |
| `port` | (v2 only) port for the health check, defaults to default protocol port | `number` | n/a | no |
| `interval` | probe interval in seconds | `nubmer` | `5` | no |
| `timeout` | probe timeout in seconds  | `nubmer` | `30` | no |
| `threshold` | number of failed probes until the backend is marked as down | `nubmer` | `2` | no |
| `match_code` | a list of acceptable http response codes, this property controls the custom match condition for a health probe, if not set, it disables them | `list(nubmer)` | `null` | no |
| `match_body` | a snippet of the backend response that can be matched for health check conditions | `string` | `null` | no |

### property: redirect

Configures a rule that only redirects traffic (traffic matched by this rules never reaches the Firewalls). Hence it is mutally exclusive with `backend` and `probe` properties.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `type` | this property triggers creation of a redirect rule, possible values are: `Permanent`, `Temporary`, `Found` and `SeeOther` | `string` | `null` | no |
| `target_listener_name` | a name of an existing listener to which traffic will be redirected, this is basically a name of a rule suffixed with `-listener` | `string` | `null` | no, mutually exclusive with `target_url` |
| `target_url` | a URL to which traffic will be redirected | `string` | `null` | no, mutually exclusive with `target_listener_name` |
| `include_path` | decides whether to include the path in the redirected Url | `bool` | `false` | no |
| `include_query_string` | decides whether to include the query string in the redirected Url | `bool` | `false` | no |

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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.7 |

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
| <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities) | A list of existing User-Assigned Managed Identities, which Application Gateway uses to retrieve certificates from Key Vault.<br><br>These identities have to have at least `GET` access to Key Vault's secrets. Otherwise Application Gateway will not be able to use certificates stored in the Vault. | `list(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Application Gateway. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of an existing resource group. | `string` | n/a | yes |
| <a name="input_rules"></a> [rules](#input\_rules) | A map of rules for the Application Gateway. A rule combines listener, http settings and health check configuration. <br>A key is an application name that is used to prefix all components inside Application Gateway that are created for this application. <br><br>For maximum and minimum values for particular properties please refer to Microsoft documentation.<br><br>The following general properties are available:<br><br>* priority - (optional fot v1 gateways only) rule's priority<br>* listener - provides general listener setting like port, protocol, error pages, etc (for details see below)<br>* backend - (optional) complete http settings configuration (for details see below)<br>* probe - (optional) health check probe configuration (for details see below)<br>* redirect - (optional) mutually exclusive with backend and probe, creates a redirect rule (for details see below)<br><br>Details on each of the properties can be found [here](#rules-property-explained). | `any` | n/a | yes |
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

<!-- BEGIN_TF_DOCS -->
# Palo Alto Networks Application Gateway Module for Azure

A terraform module for deploying a Application Gateway v2 and its components required for the VM-Series firewalls in Azure.

## Usage

In order to use module `appgw`, you need to deploy `azurerm_resource_group` and use module `vnet` as prerequisites.
Then you can use below code as an example of calling module to create Application Gateway:

```hcl
# Create Application Gateay
module "appgw" {
  source = "../../modules/appgw"

  for_each = var.appgws

  name                = each.value.name
  public_ip           = each.value.public_ip
  resource_group_name = local.resource_group.name
  location            = var.location
  subnet_id           = module.vnet[each.value.vnet_key].subnet_ids[each.value.subnet_key]

  managed_identities = each.value.managed_identities
  capacity           = each.value.capacity
  waf                = each.value.waf
  enable_http2       = each.value.enable_http2
  zones              = each.value.zones

  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  listeners                      = each.value.listeners
  backend_pool                   = each.value.backend_pool
  backends                       = each.value.backends
  probes                         = each.value.probes
  rewrites                       = each.value.rewrites
  rules                          = each.value.rules
  redirects                      = each.value.redirects
  url_path_maps                  = each.value.url_path_maps

  ssl_global   = each.value.ssl_global
  ssl_profiles = each.value.ssl_profiles

  tags       = var.tags
  depends_on = [module.vnet]
}
```

The examples below are meant to show most common use cases and to serve as a base for more complex
application gateways definitions.

### Example 1

Application Gateway with:
* new public IP
* HTTP listener
* static capacity
* rewriting HTTP headers

```hcl
appgws = {
  "public-http-minimum" = {
    name = "appgw-http-minimum"
    public_ip = {
      name = "pip-http-minimum"
    }
    vnet_key   = "transit"
    subnet_key = "appgw"
    zones      = ["1", "2", "3"]
    capacity = {
      static = 2
    }
    listeners = {
      minimum = {
        name = "minimum-listener"
        port = 80
      }
    }
    rewrites = {
      minimum = {
        name = "minimum-set"
        rules = {
          "xff-strip-port" = {
            name     = "minimum-xff-strip-port"
            sequence = 100
            request_headers = {
              "X-Forwarded-For" = "{var_add_x_forwarded_for_proxy}"
            }
          }
        }
      }
    }
    rules = {
      minimum = {
        name     = "minimum-rule"
        priority = 1
        backend  = "minimum"
        listener = "minimum"
        rewrite  = "minimum"
      }
    }
  }
}
```

### Example 2

Application Gateway with:
* existing public IP
* HTTP listener
* static capacity
* rewriting HTTP headers

```hcl
appgws = {
  "public-http-existing" = {
    name = "appgw-http-existing"
    public_ip = {
      name   = "pip-existing"
      create = false
    }
    vnet_key   = "transit"
    subnet_key = "appgw"
    zones      = ["1", "2", "3"]
    capacity = {
      static = 2
    }
    backends = {
      existing = {
        name                  = "http-backend"
        port                  = 80
        protocol              = "Http"
        timeout               = 60
        cookie_based_affinity = "Enabled"
      }
    }
    listeners = {
      existing = {
        name = "existing-listener"
        port = 80
      }
    }
    rewrites = {
      existing = {
        name = "existing-set"
        rules = {
          "xff-strip-port" = {
            name     = "existing-xff-strip-port"
            sequence = 100
            request_headers = {
              "X-Forwarded-For" = "{var_add_x_forwarded_for_proxy}"
            }
          }
        }
      }
    }
    rules = {
      existing = {
        name     = "existing-rule"
        priority = 1
        backend  = "existing"
        listener = "existing"
        rewrite  = "existing"
      }
    }
  }
}
```

### Example 3

Application Gateway with:
* new public IP
* HTTP listener
* autoscaling

```hcl
appgws = {
  "public-http-autoscale" = {
    name = "appgw-http-autoscale"
    public_ip = {
      name = "pip-http-autoscale"
    }
    vnet_key   = "transit"
    subnet_key = "appgw"
    zones      = ["1", "2", "3"]
    capacity = {
      autoscale = {
        min = 2
        max = 20
      }
    }
    backends = {
      http = {
        name                  = "http-backend"
        port                  = 80
        protocol              = "Http"
        timeout               = 60
        cookie_based_affinity = "Enabled"
      }
    }
    listeners = {
      http = {
        name = "http-listener"
        port = 80
      }
    }
    rules = {
      http = {
        name     = "http-rule"
        priority = 1
        backend  = "http"
        listener = "http"
      }
    }
  }
}
```

### Example 4

Application Gateway with:
* new public IP
* WAF enabled
* HTTP listener
* static capacity
* rewriting HTTP headers

```hcl
appgws = {
  "public-waf" = {
    name = "appgw-waf"
    public_ip = {
      name = "pip-waf"
    }
    vnet_key   = "transit"
    subnet_key = "appgw"
    zones      = ["1", "2", "3"]
    capacity = {
      static = 2
    }
    waf = {
      prevention_mode  = true
      rule_set_type    = "OWASP"
      rule_set_version = "3.2"
    }
    backends = {
      waf = {
        name                  = "waf-backend"
        port                  = 80
        protocol              = "Http"
        timeout               = 60
        cookie_based_affinity = "Enabled"
      }
    }
    listeners = {
      waf = {
        name = "waf-listener"
        port = 80
      }
    }
    rewrites = {
      waf = {
        name = "waf-set"
        rules = {
          "xff-strip-port" = {
            name     = "waf-xff-strip-port"
            sequence = 100
            request_headers = {
              "X-Forwarded-For" = "{var_add_x_forwarded_for_proxy}"
            }
          }
        }
      }
    }
    rules = {
      minimum = {
        name     = "waf-rule"
        priority = 1
        backend  = "waf"
        listener = "waf"
        rewrite  = "waf"
      }
    }
  }
}
```

### Prerequisites for example 5 and 6

If you need to test example for Application Gateway with SSL, you need to created directory files
and create keys and certs using commands:

1. Create CA private key and certificate:
```bash
   openssl genrsa 2048 > ca-key1.pem
   openssl req -new -x509 -nodes -days 365000 -key ca-key1.pem -out ca-cert1.pem
   openssl genrsa 2048 > ca-key2.pem
   openssl req -new -x509 -nodes -days 365000 -key ca-key2.pem -out ca-cert2.pem
```
2. Create server certificate:
```bash
   openssl req -newkey rsa:2048 -nodes -keyout test1.key -x509 -days 365 -CA ca-cert1.pem -CAkey ca-key1.pem -out test1.crt
   openssl req -newkey rsa:2048 -nodes -keyout test2.key -x509 -days 365 -CA ca-cert2.pem -CAkey ca-key2.pem -out test2.crt
```
3. Create PFX file with key and certificate:
```bash
   openssl pkcs12 -inkey test1.key -in test1.crt -export -out test1.pfx
   openssl pkcs12 -inkey test2.key -in test2.crt -export -out test2.pfx
```

### Example 5

Application Gateway with:
* new public IP
* multi site HTTPS listener (many host names on port 443)
* static capacity
* rewriting HTTPS headers

```hcl
appgws = {
  "public-ssl-predefined" = {
    name = "appgw-ssl-predefined"
    public_ip = {
      name = "pip-ssl-predefined"
    }
    vnet_key   = "transit"
    subnet_key = "appgw"
    zones      = ["1", "2", "3"]
    capacity = {
      static = 2
    }
    ssl_global = {
      ssl_policy_type = "Predefined"
      ssl_policy_name = "AppGwSslPolicy20170401"
    }
    ssl_profiles = {
      profile1 = {
        name            = "appgw-ssl-profile1"
        ssl_policy_name = "AppGwSslPolicy20170401S"
      }
    }
    frontend_ip_configuration_name = "public_ipconfig"
    listeners = {
      https1 = {
        name                 = "https1-listener"
        port                 = 443
        protocol             = "Https"
        ssl_profile_name     = "appgw-ssl-profile1"
        ssl_certificate_path = "./files/test1.pfx"
        ssl_certificate_pass = ""
        host_names           = ["test1.appgw.local"]
      }
      https2 = {
        name                 = "https2-listener"
        port                 = 443
        protocol             = "Https"
        ssl_certificate_path = "./files/test2.pfx"
        ssl_certificate_pass = ""
        host_names           = ["test2.appgw.local"]
      }
    }
    backend_pool = {
      name = "vmseries-pool"
    }
    backends = {
      https1 = {
        name                  = "https1-settings"
        port                  = 481
        protocol              = "Https"
        timeout               = 60
        cookie_based_affinity = "Enabled"
        hostname_from_backend = false
        hostname              = "test1.appgw.local"
        root_certs = {
          test = {
            name = "https-application-test1"
            path = "./files/ca-cert1.pem"
          }
        }
      }
      https2 = {
        name                  = "https2-settings"
        port                  = 482
        protocol              = "Https"
        timeout               = 60
        cookie_based_affinity = "Enabled"
        hostname_from_backend = false
        hostname              = "test2.appgw.local"
        root_certs = {
          test = {
            name = "https-application-test2"
            path = "./files/ca-cert2.pem"
          }
        }
      }
    }
    rewrites = {
      https1 = {
        name = "https1-set"
        rules = {
          "xff-strip-port" = {
            name     = "https1-xff-strip-port"
            sequence = 100
            conditions = {
              "http_resp_X-Forwarded-Proto" = {
                pattern     = "https"
                ignore_case = true
                negate      = true
              }
            }
            request_headers = {
              "X-Forwarded-For"   = "{var_add_x_forwarded_for_proxy}"
              "X-Forwarded-Proto" = "https"
            }
          }
        }
      }
      https2 = {
        name = "https2-set"
        rules = {
          "xff-strip-port" = {
            name     = "https2-xff-strip-port"
            sequence = 100
            conditions = {
              "http_resp_X-Forwarded-Proto" = {
                pattern     = "https"
                ignore_case = true
                negate      = true
              }
            }
            request_headers = {
              "X-Forwarded-For"   = "{var_add_x_forwarded_for_proxy}"
              "X-Forwarded-Proto" = "https"
            }
          }
        }
      }
    }
    rules = {
      https1 = {
        name     = "https1-rule"
        priority = 2
        backend  = "https1"
        listener = "https1"
        rewrite  = "https1"
      }
      https2 = {
        name     = "https2-rule"
        priority = 3
        backend  = "https2"
        listener = "https2"
        rewrite  = "https2"
      }
    }
  }
}
```

### Example 6

Application Gateway with:
* new public IP
* multiple listener:
  * HTTP
  * multi site HTTPS (many host names on port 443)
  * redirect
  * path based
* static capacity
* rewriting HTTP and HTTPS headers
* custom SSL profiles and policies
* custom health probes
* rewrites

```hcl
appgws = {
  "public-ssl-custom" = {
    name = "appgw-ssl-custom"
    public_ip = {
      name = "pip-ssl-custom"
    }
    vnet_key   = "transit"
    subnet_key = "appgw"
    zones      = ["1", "2", "3"]
    capacity = {
      static = 2
    }
    ssl_global = {
      ssl_policy_type                 = "Custom"
      ssl_policy_min_protocol_version = "TLSv1_0"
      ssl_policy_cipher_suites = ["TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA", "TLS_DHE_DSS_WITH_AES_128_CBC_SHA",
        "TLS_DHE_DSS_WITH_AES_128_CBC_SHA256", "TLS_DHE_DSS_WITH_AES_256_CBC_SHA", "TLS_DHE_DSS_WITH_AES_256_CBC_SHA256",
        "TLS_DHE_RSA_WITH_AES_128_CBC_SHA", "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_DHE_RSA_WITH_AES_256_CBC_SHA",
        "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA", "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256",
        "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA",
        "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
        "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA", "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256", "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
        "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA", "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
        "TLS_RSA_WITH_3DES_EDE_CBC_SHA", "TLS_RSA_WITH_AES_128_CBC_SHA", "TLS_RSA_WITH_AES_128_CBC_SHA256",
        "TLS_RSA_WITH_AES_128_GCM_SHA256", "TLS_RSA_WITH_AES_256_CBC_SHA", "TLS_RSA_WITH_AES_256_CBC_SHA256",
      "TLS_RSA_WITH_AES_256_GCM_SHA384"]
    }
    ssl_profiles = {
      profile1 = {
        name                            = "appgw-ssl-profile1"
        ssl_policy_min_protocol_version = "TLSv1_1"
        ssl_policy_cipher_suites = ["TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA", "TLS_DHE_DSS_WITH_AES_128_CBC_SHA",
          "TLS_DHE_DSS_WITH_AES_128_CBC_SHA256", "TLS_DHE_DSS_WITH_AES_256_CBC_SHA", "TLS_DHE_DSS_WITH_AES_256_CBC_SHA256",
          "TLS_DHE_RSA_WITH_AES_128_CBC_SHA", "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_DHE_RSA_WITH_AES_256_CBC_SHA",
          "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA",
          "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
          "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384",
          "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
          "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256", "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA",
        "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"]
      }
      profile2 = {
        name                            = "appgw-ssl-profile2"
        ssl_policy_min_protocol_version = "TLSv1_2"
        ssl_policy_cipher_suites = ["TLS_RSA_WITH_3DES_EDE_CBC_SHA", "TLS_RSA_WITH_AES_128_CBC_SHA",
          "TLS_RSA_WITH_AES_128_CBC_SHA256", "TLS_RSA_WITH_AES_128_GCM_SHA256", "TLS_RSA_WITH_AES_256_CBC_SHA",
        "TLS_RSA_WITH_AES_256_CBC_SHA256", "TLS_RSA_WITH_AES_256_GCM_SHA384"]
      }
    }
    frontend_ip_configuration_name = "public_ipconfig"
    listeners = {
      http = {
        name = "http-listener"
        port = 80
      }
      https1 = {
        name                 = "https1-listener"
        port                 = 443
        protocol             = "Https"
        ssl_profile_name     = "appgw-ssl-profile1"
        ssl_certificate_path = "./files/test1.pfx"
        ssl_certificate_pass = ""
        host_names           = ["test1.appgw.local"]
      }
      https2 = {
        name                 = "https2-listener"
        port                 = 443
        protocol             = "Https"
        ssl_profile_name     = "appgw-ssl-profile2"
        ssl_certificate_path = "./files/test2.pfx"
        ssl_certificate_pass = ""
        host_names           = ["test2.appgw.local"]
      }
      redirect_listener = {
        name = "redirect-listener-listener"
        port = 521
      }
      redirect_url = {
        name = "redirect-url-listener"
        port = 522
      }
      path_based_backend = {
        name = "path-backend-listener"
        port = 641
      }
      path_based_redirect_listener = {
        name = "path-redirect-listener-listener"
        port = 642
      }
      path_based_redirect_url = {
        name = "path-redirect-rul-listener"
        port = 643
      }
    }
    backend_pool = {
      name = "vmseries-pool"
    }
    backends = {
      http = {
        name                  = "http-settings"
        port                  = 80
        protocol              = "Http"
        timeout               = 60
        cookie_based_affinity = "Enabled"
      }
      https1 = {
        name                  = "https1-settings"
        port                  = 481
        protocol              = "Https"
        timeout               = 60
        cookie_based_affinity = "Enabled"
        hostname_from_backend = false
        hostname              = "test1.appgw.local"
        root_certs = {
          test = {
            name = "https-application-test1"
            path = "./files/ca-cert1.pem"
          }
        }
        probe = "https1"
      }
      https2 = {
        name                  = "https2-settings"
        port                  = 482
        protocol              = "Https"
        timeout               = 60
        cookie_based_affinity = "Enabled"
        hostname_from_backend = false
        hostname              = "test2.appgw.local"
        root_certs = {
          test = {
            name = "https-application-test2"
            path = "./files/ca-cert2.pem"
          }
        }
        probe = "https2"
      }
    }
    probes = {
      https1 = {
        name     = "https-probe1"
        path     = "/"
        protocol = "Https"
        timeout  = 10
      }
      https2 = {
        name     = "https-probe2"
        path     = "/"
        protocol = "Https"
        timeout  = 10
      }
    }
    rewrites = {
      http = {
        name = "http-set"
        rules = {
          "xff-strip-port" = {
            name     = "http-xff-strip-port"
            sequence = 100
            request_headers = {
              "X-Forwarded-For" = "{var_add_x_forwarded_for_proxy}"
            }
          }
        }
      }
      https1 = {
        name = "https1-set"
        rules = {
          "xff-strip-port" = {
            name     = "https1-xff-strip-port"
            sequence = 100
            conditions = {
              "http_resp_X-Forwarded-Proto" = {
                pattern     = "https"
                ignore_case = true
                negate      = true
              }
            }
            request_headers = {
              "X-Forwarded-For"   = "{var_add_x_forwarded_for_proxy}"
              "X-Forwarded-Proto" = "https"
            }
          }
        }
      }
      https2 = {
        name = "https2-set"
        rules = {
          "xff-strip-port" = {
            name     = "https2-xff-strip-port"
            sequence = 100
            conditions = {
              "http_resp_X-Forwarded-Proto" = {
                pattern     = "https"
                ignore_case = true
                negate      = true
              }
            }
            request_headers = {
              "X-Forwarded-For"   = "{var_add_x_forwarded_for_proxy}"
              "X-Forwarded-Proto" = "https"
            }
          }
        }
      }
    }
    rules = {
      http = {
        name     = "http-rule"
        priority = 1
        backend  = "http"
        listener = "http"
        rewrite  = "http"
      }
      https1 = {
        name     = "https1-rule"
        priority = 2
        backend  = "https1"
        listener = "https1"
        rewrite  = "https1"
      }
      https2 = {
        name     = "https2-rule"
        priority = 3
        backend  = "https2"
        listener = "https2"
        rewrite  = "https2"
      }
      redirect_listener = {
        name     = "redirect-listener-rule"
        priority = 4
        listener = "redirect_listener"
        redirect = "redirect_listener"
      }
      redirect_url = {
        name     = "redirect-url-rule"
        priority = 5
        listener = "redirect_url"
        redirect = "redirect_url"
      }
      path_based_backend = {
        name         = "path-based-backend-rule"
        priority     = 6
        listener     = "path_based_backend"
        url_path_map = "path_based_backend"
      }
      path_based_redirect_listener = {
        name         = "path-redirect-listener-rule"
        priority     = 7
        listener     = "path_based_redirect_listener"
        url_path_map = "path_based_redirect_listener"
      }
      path_based_redirect_url = {
        name         = "path-redirect-rul-rule"
        priority     = 8
        listener     = "path_based_redirect_url"
        url_path_map = "path_based_redirect_url"
      }
    }
    redirects = {
      redirect_listener = {
        name                 = "listener-redirect"
        type                 = "Permanent"
        target_listener      = "http"
        include_path         = true
        include_query_string = true
      }
      redirect_url = {
        name                 = "url-redirect"
        type                 = "Temporary"
        target_url           = "http://example.com"
        include_path         = true
        include_query_string = true
      }
    }
    url_path_maps = {
      path_based_backend = {
        name    = "backend-map"
        backend = "http"
        path_rules = {
          http = {
            paths   = ["/plaintext"]
            backend = "http"
          }
          https = {
            paths   = ["/secure"]
            backend = "https1"
          }
        }
      }
      path_based_redirect_listener = {
        name    = "redirect-listener-map"
        backend = "http"
        path_rules = {
          http = {
            paths    = ["/redirect"]
            redirect = "redirect_listener"
          }
        }
      }
      path_based_redirect_url = {
        name    = "redirect-url-map"
        backend = "http"
        path_rules = {
          http = {
            paths    = ["/redirect"]
            redirect = "redirect_url"
          }
        }
      }
    }
  }
}
```

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`name`](#name) | `string` | The name of the Application Gateway.
[`resource_group_name`](#resource_group_name) | `string` | The name of the Resource Group to use.
[`location`](#location) | `string` | The name of the Azure region to deploy the resources in.
[`public_ip`](#public_ip) | `object` | Public IP address.
[`subnet_id`](#subnet_id) | `string` | An ID of a subnet that will host the Application Gateway.
[`ssl_profiles`](#ssl_profiles) | `map` | A map of SSL profiles.
[`listeners`](#listeners) | `map` | A map of listeners for the Application Gateway.
[`probes`](#probes) | `map` | A map of probes for the Application Gateway.
[`rewrites`](#rewrites) | `map` | A map of rewrites for the Application Gateway.
[`rules`](#rules) | `map` | A map of rules for the Application Gateway.
[`redirects`](#redirects) | `map` | A map of redirects for the Application Gateway.
[`url_path_maps`](#url_path_maps) | `map` | A map of URL path maps for the Application Gateway.


## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`tags`](#tags) | `map` | The map of tags to assign to all created resources.
[`zones`](#zones) | `list` | A list of zones the Application Gateway should be available in.
[`domain_name_label`](#domain_name_label) | `string` | Label for the Domain Name.
[`enable_http2`](#enable_http2) | `bool` | Enable HTTP2 on the Application Gateway.
[`waf`](#waf) | `object` | Object sets only the SKU and provide basic WAF (Web Application Firewall) configuration for Application Gateway.
[`capacity`](#capacity) | `object` | Capacity configuration for Application Gateway.
[`managed_identities`](#managed_identities) | `list` | A list of existing User-Assigned Managed Identities.
[`ssl_global`](#ssl_global) | `object` | Global SSL settings.
[`frontend_ip_configuration_name`](#frontend_ip_configuration_name) | `string` | Frontend IP configuration name.
[`backend_pool`](#backend_pool) | `object` | Backend pool.
[`backends`](#backends) | `map` | A map of backend settings for the Application Gateway.



## Module's Outputs

Name |  Description
--- | ---
`public_ip` | A public IP assigned to the Application Gateway.
`public_domain_name` | Public domain name assigned to the Application Gateway.
`backend_pool_id` | The identifier of the Application Gateway backend address pool.

## Module's Nameplate


Requirements needed by this module:

- `terraform`, version: >= 1.3, < 2.0
- `azurerm`, version: ~> 3.25


Providers used in this module:

- `azurerm`, version: ~> 3.25




Resources used in this module:

- `application_gateway` (managed)
- `public_ip` (managed)
- `public_ip` (data)

## Inputs/Outpus details

### Required Inputs


#### name

The name of the Application Gateway.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>

#### resource_group_name

The name of the Resource Group to use.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>

#### location

The name of the Azure region to deploy the resources in.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>



#### public_ip

Public IP address.

Type: 

```hcl
object({
    name           = string
    resource_group = optional(string)
    create         = optional(bool, true)
  })
```


<sup>[back to list](#modules-required-inputs)</sup>






#### subnet_id

An ID of a subnet that will host the Application Gateway.

Keep in mind that this subnet can contain only AppGWs and only of the same type.


Type: string

<sup>[back to list](#modules-required-inputs)</sup>


#### ssl_profiles

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


Type: 

```hcl
map(object({
    name                            = string
    ssl_policy_name                 = optional(string)
    ssl_policy_min_protocol_version = optional(string)
    ssl_policy_cipher_suites        = optional(list(string))
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>


#### listeners

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


Type: 

```hcl
map(object({
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
```


<sup>[back to list](#modules-required-inputs)</sup>



#### probes

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


Type: 

```hcl
map(object({
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
```


<sup>[back to list](#modules-required-inputs)</sup>

#### rewrites

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


Type: 

```hcl
map(object({
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
```


<sup>[back to list](#modules-required-inputs)</sup>

#### rules

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


Type: 

```hcl
map(object({
    name         = string
    priority     = number
    backend      = optional(string)
    listener     = string
    rewrite      = optional(string)
    url_path_map = optional(string)
    redirect     = optional(string)
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>

#### redirects

A map of redirects for the Application Gateway.

Every redirect contains attributes:
- `name`                 - (`string`, required) The name of redirect.
- `type`                 - (`string`, required) The type of redirect.
                           Possible values are Permanent, Temporary, Found and SeeOther
- `target_listener`      - (`string`, optional) The name of the listener to redirect to.
- `target_url`           - (`string`, optional) The URL to redirect the request to.
- `include_path`         - (`bool`, optional) Whether or not to include the path in the redirected URL.
- `include_query_string` - (`bool`, optional) Whether or not to include the query string in the redirected URL.


Type: 

```hcl
map(object({
    name                 = string
    type                 = string
    target_listener      = optional(string)
    target_url           = optional(string)
    include_path         = optional(bool, false)
    include_query_string = optional(bool, false)
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>

#### url_path_maps

A map of URL path maps for the Application Gateway.

Every URL path map contains attributes:
- `name`         - (`string`, required) The name of redirect.
- `backend`      - (`string`, required) The default backend for redirect.
- `path_rules`   - (`map`, optional) The map of rules, where every object has attributes:
    - `paths`    - (`list`, required) List of paths
    - `backend`  - (`string`, optional) Backend's key
    - `redirect` - (`string`, optional) Redirect's key


Type: 

```hcl
map(object({
    name    = string
    backend = string
    path_rules = optional(map(object({
      paths    = list(string)
      backend  = optional(string)
      redirect = optional(string)
    })))
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>



### Optional Inputs





#### tags

The map of tags to assign to all created resources.

Type: map(string)

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### zones

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


Type: list(string)

Default value: `[1 2 3]`

<sup>[back to list](#modules-optional-inputs)</sup>


#### domain_name_label

Label for the Domain Name.

Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created
for the public IP in the Microsoft Azure DNS system."


Type: string

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### enable_http2

Enable HTTP2 on the Application Gateway.

Type: bool

Default value: `false`

<sup>[back to list](#modules-optional-inputs)</sup>

#### waf

Object sets only the SKU and provide basic WAF (Web Application Firewall) configuration for Application Gateway.

This module does not support WAF rules configuration and advanced WAF settings.
Only below attributes are allowed:
- `prevention_mode`    - (`bool`, required) `true` if WAF mode is Prevention, `false` for Detection mode
- `rule_set_type`    - (`string`, optional, defaults to `OWASP`) The Type of the Rule Set used for this Web Application Firewall
- `rule_set_version` - (`string`, optional) The Version of the Rule Set used for this Web Application Firewall


Type: 

```hcl
object({
    prevention_mode  = bool
    rule_set_type    = optional(string, "OWASP")
    rule_set_version = optional(string)
  })
```


Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### capacity

Capacity configuration for Application Gateway.

Object defines static or autoscale configuration using attributes:
- `static`    - (`number`, optional) A static number of Application Gateway instances. A value bewteen 1 and 125
                or null, if autoscale configuration is provided
- `autoscale` - (`object`, optional) Autoscaling configuration (used only, if static is null) with attributes:
  - `min`     - (`number`, optional) Minimum capacity for autoscaling.
  - `max`     - (`number`, optional) Maximum capacity for autoscaling.


Type: 

```hcl
object({
    static = optional(number)
    autoscale = optional(object({
      min = optional(number)
      max = optional(number)
    }))
  })
```


Default value: `map[static:2]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### managed_identities

A list of existing User-Assigned Managed Identities.

Application Gateway uses Managed Identities to retrieve certificates from Key Vault.
These identities have to have at least `GET` access to Key Vault's secrets.
Otherwise Application Gateway will not be able to use certificates stored in the Vault.


Type: list(string)

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>


#### ssl_global

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


Type: 

```hcl
object({
    ssl_policy_type                 = string
    ssl_policy_name                 = optional(string)
    ssl_policy_min_protocol_version = optional(string)
    ssl_policy_cipher_suites        = optional(list(string))
  })
```


Default value: `map[ssl_policy_cipher_suites:[] ssl_policy_min_protocol_version:<nil> ssl_policy_name:AppGwSslPolicy20220101S ssl_policy_type:Predefined]`

<sup>[back to list](#modules-optional-inputs)</sup>


#### frontend_ip_configuration_name

Frontend IP configuration name

Type: string

Default value: `public_ipconfig`

<sup>[back to list](#modules-optional-inputs)</sup>


#### backend_pool

Backend pool.

Object contains attributes:
- `name`         - (`string`, required) name of the backend pool.
- `vmseries_ips` - (`list`, optional, defaults to `[]`) IP addresses of VMSeries' interfaces that will serve as backends
                   for the Application Gateway.


Type: 

```hcl
object({
    name         = string
    vmseries_ips = optional(list(string), [])
  })
```


Default value: `map[name:vmseries]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### backends

A map of backend settings for the Application Gateway.

Every backend contains attributes:
- `name`                  - (`string`, optional) The name of the backend settings
- `path`                  - (`string`, optional) The Path which should be used as a prefix for all HTTP requests.
- `hostname_from_backend` - (`bool`, optional) Whether host header should be picked from the host name of the backend server.
- `hostname`              - (`string`, optional) Host header to be sent to the backend servers.
- `port`                  - (`number`, optional) The port which should be used for this Backend HTTP Settings Collection.
- `protocol`              - (`string`, optional) The Protocol which should be used. Possible values are Http and Https.
- `timeout`               - (`number`, optional) The request timeout in seconds, which must be between 1 and 86400 seconds.
- `cookie_based_affinity` - (`string`, optional) Is Cookie-Based Affinity enabled? Possible values are Enabled and Disabled.
- `affinity_cookie_name`  - (`string`, optional) The name of the affinity cookie.
- `probe`                 - (`string`, optional) Probe's key.
- `root_certs`            - (`map`, optional) A list of trusted_root_certificate names.


Type: 

```hcl
map(object({
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
```


Default value: `map[minimum:map[name:minimum]]`

<sup>[back to list](#modules-optional-inputs)</sup>







<!-- END_TF_DOCS -->
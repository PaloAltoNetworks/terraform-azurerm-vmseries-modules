# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "appgw-example"
name_prefix         = "sczech-"
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}


# --- VNET PART --- #
vnets = {
  transit = {
    name                    = "transit"
    address_space           = ["10.0.0.0/24"]
    network_security_groups = {}
    route_tables = {
      "rt" = {
        name = "rt"
        routes = {
          "udr" = {
            name           = "udr"
            address_prefix = "10.0.0.0/8"
            next_hop_type  = "None"
          }
        }
      }
    }
    subnets = {
      "appgw" = {
        name             = "appgw"
        address_prefixes = ["10.0.0.0/25"]
        route_table_key  = "rt"
      }
    }
  }
}

# --- APPGW PART --- #

appgws = {
  "public" = {
    name           = "appgw"
    public_ip_name = "pip"
    vnet_key       = "transit"
    subnet_key     = "appgw"
    zones          = ["1", "2", "3"]
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
  "public-http" = {
    name           = "appgw-http"
    public_ip_name = "pip-http"
    vnet_key       = "transit"
    subnet_key     = "appgw"
    zones          = ["1", "2", "3"]
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
  # If you test example for Application Gateway with SSL, you need to created directory files and create keys and certs using commands:
  # 1. Create CA private key and certificate:
  #    openssl genrsa 2048 > ca-key1.pem
  #    openssl req -new -x509 -nodes -days 365000 -key ca-key1.pem -out ca-cert1.pem
  #    openssl genrsa 2048 > ca-key2.pem
  #    openssl req -new -x509 -nodes -days 365000 -key ca-key2.pem -out ca-cert2.pem
  # 2. Create server certificate:
  #    openssl req -newkey rsa:2048 -nodes -keyout test1.key -x509 -days 365 -CA ca-cert1.pem -CAkey ca-key1.pem -out test1.crt
  #    openssl req -newkey rsa:2048 -nodes -keyout test2.key -x509 -days 365 -CA ca-cert2.pem -CAkey ca-key2.pem -out test2.crt
  # 3. Create PFX file with key and certificate:
  #    openssl pkcs12 -inkey test1.key -in test1.crt -export -out test1.pfx
  #    openssl pkcs12 -inkey test2.key -in test2.crt -export -out test2.pfx
  "public-ssl" = {
    name           = "appgw-ssl"
    public_ip_name = "pip-ssl"
    vnet_key       = "transit"
    subnet_key     = "appgw"
    zones          = ["1", "2", "3"]
    capacity = {
      static = 2
    }
    ssl_policy_type                 = "Custom"
    ssl_policy_min_protocol_version = "TLSv1_0"
    ssl_policy_cipher_suites        = ["TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA", "TLS_DHE_DSS_WITH_AES_128_CBC_SHA", "TLS_DHE_DSS_WITH_AES_128_CBC_SHA256", "TLS_DHE_DSS_WITH_AES_256_CBC_SHA", "TLS_DHE_DSS_WITH_AES_256_CBC_SHA256", "TLS_DHE_RSA_WITH_AES_128_CBC_SHA", "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_DHE_RSA_WITH_AES_256_CBC_SHA", "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA", "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA", "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256", "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA", "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_RSA_WITH_3DES_EDE_CBC_SHA", "TLS_RSA_WITH_AES_128_CBC_SHA", "TLS_RSA_WITH_AES_128_CBC_SHA256", "TLS_RSA_WITH_AES_128_GCM_SHA256", "TLS_RSA_WITH_AES_256_CBC_SHA", "TLS_RSA_WITH_AES_256_CBC_SHA256", "TLS_RSA_WITH_AES_256_GCM_SHA384"]
    ssl_profiles = {
      profile1 = {
        name                            = "appgw-ssl-profile1"
        ssl_policy_type                 = "Custom"
        ssl_policy_min_protocol_version = "TLSv1_1"
        ssl_policy_cipher_suites        = ["TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA", "TLS_DHE_DSS_WITH_AES_128_CBC_SHA", "TLS_DHE_DSS_WITH_AES_128_CBC_SHA256", "TLS_DHE_DSS_WITH_AES_256_CBC_SHA", "TLS_DHE_DSS_WITH_AES_256_CBC_SHA256", "TLS_DHE_RSA_WITH_AES_128_CBC_SHA", "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_DHE_RSA_WITH_AES_256_CBC_SHA", "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA", "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA", "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256", "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA", "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"]
      }
      profile2 = {
        name                            = "appgw-ssl-profile2"
        ssl_policy_type                 = "Custom"
        ssl_policy_min_protocol_version = "TLSv1_2"
        ssl_policy_cipher_suites        = ["TLS_RSA_WITH_3DES_EDE_CBC_SHA", "TLS_RSA_WITH_AES_128_CBC_SHA", "TLS_RSA_WITH_AES_128_CBC_SHA256", "TLS_RSA_WITH_AES_128_GCM_SHA256", "TLS_RSA_WITH_AES_256_CBC_SHA", "TLS_RSA_WITH_AES_256_CBC_SHA256", "TLS_RSA_WITH_AES_256_GCM_SHA384"]
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

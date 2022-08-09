locals {
  # Calculate a map of unique frontend ports based on the `listener.port` values defined in `rules` map.
  # A unque set of ports will be created upfront and then referenced in the listener's config.
  front_ports_list = distinct([for k, v in var.rules : v.listener.port])
  front_ports_map  = { for v in local.front_ports_list : "${v}-front-port" => v }

  # Calculate a flat map of all backend's trusted root certificates.
  # Root certs are created upfront and then referenced in a single list in the http setting's config.
  root_certs_flat_list = flatten([
    for k, v in var.rules : [
      for name, path in v.backend.root_certs : {
        name = "${k}-${name}"
        path = path
      }
    ] if can(v.backend.root_certs)
  ])

  root_certs_map = { for v in local.root_certs_flat_list : v.name => v.path }
}

resource "azurerm_public_ip" "this" {
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.waf_enabled ? "WAF_v2" : "Standard_v2"
    tier     = var.waf_enabled ? "WAF_v2" : "Standard_v2"
    capacity = var.capacity_min == null ? var.capacity : null
  }

  dynamic "autoscale_configuration" {
    for_each = try(var.capacity_min, null) != null ? [1] : []

    content {
      min_capacity = var.capacity_min
      max_capacity = try(var.capacity_max, null)
    }
  }

  dynamic "identity" {
    for_each = var.managed_identities != null ? [1] : []

    content {
      type         = "UserAssigned"
      identity_ids = var.managed_identities
    }
  }

  gateway_ip_configuration {
    name      = "appgw_ip_config"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "frontend_ipconfig"
    public_ip_address_id = azurerm_public_ip.this.id
  }

  # There is only a single backend - the VMSeries private IPs assigned to untrusted NICs
  backend_address_pool {
    name         = "vmseries"
    ip_addresses = var.vmseries_ips
  }

  ssl_policy {
    policy_name          = var.ssl_policy_type == "Predefined" ? var.ssl_policy_name : null
    policy_type          = var.ssl_policy_type
    min_protocol_version = var.ssl_policy_min_protocol_version
    cipher_suites        = var.ssl_policy_cipher_suites
  }

  # The following block is supported only in v2 Application Gateways.
  dynamic "ssl_profile" {
    for_each = var.ssl_profiles

    content {
      name = ssl_profile.key
      ssl_policy {
        policy_name          = var.ssl_policy_type == "Predefined" ? var.ssl_policy_name : null
        policy_type          = ssl_profile.value.ssl_policy_type
        min_protocol_version = ssl_profile.value.ssl_policy_min_protocol_version
        cipher_suites        = ssl_profile.value.ssl_policy_cipher_suites
      }
    }
  }

  dynamic "frontend_port" {
    for_each = local.front_ports_map
    content {
      name = frontend_port.key
      port = frontend_port.value
    }
  }

  dynamic "probe" {
    for_each = { for k, v in var.rules : k => v if can(v.probe.path) }

    content {
      name                                      = "${probe.key}-probe"
      path                                      = probe.value.probe.path
      protocol                                  = try(probe.value.backend.protocol, "Http")
      host                                      = try(probe.value.probe.host, null)
      pick_host_name_from_backend_http_settings = !can(probe.value.probe.host)
      port                                      = try(probe.value.probe.port, null)
      interval                                  = try(probe.value.probe.interval, 5)
      timeout                                   = try(probe.value.probe.timeout, 30)
      unhealthy_threshold                       = try(probe.value.probe.threshold, 2)

      dynamic "match" {
        for_each = can(probe.value.probe.match_code) ? [1] : []

        content {
          status_code = probe.value.probe.match_code
          body        = try(probe.value.probe.match_body, null)
        }
      }
    }
  }

  # Trust root certs for use with backends. Only for v2 version.
  dynamic "trusted_root_certificate" {
    for_each = local.root_certs_map

    content {
      name = trusted_root_certificate.key
      data = filebase64(trusted_root_certificate.value)
    }
  }

  dynamic "backend_http_settings" {
    for_each = { for k, v in var.rules : k => v if !can(v.redirect.type) }

    content {
      name                                = "${backend_http_settings.key}-httpsettings"
      port                                = try(backend_http_settings.value.backend.port, 80)
      protocol                            = try(backend_http_settings.value.backend.protocol, "Http")
      pick_host_name_from_backend_address = try(backend_http_settings.value.backend.hostname_from_backend, null)
      host_name                           = try(backend_http_settings.value.backend.hostname, null)
      path                                = try(backend_http_settings.value.backend.path, null)
      request_timeout                     = try(backend_http_settings.value.backend.timeout, 60)
      probe_name                          = can(backend_http_settings.value.probe.path) ? "${backend_http_settings.key}-probe" : null
      cookie_based_affinity               = try(backend_http_settings.value.backend.cookie_based_affinity, "Enabled")
      affinity_cookie_name                = try(backend_http_settings.value.backend.affinity_cookie_name, null)
      trusted_root_certificate_names = can(backend_http_settings.value.backend.root_certs) ? (
      [for k, v in backend_http_settings.value.backend.root_certs : "${backend_http_settings.key}-${k}"]) : null
    }
  }

  dynamic "ssl_certificate" {
    for_each = { for k, v in var.rules : k => v if try(v.listener.ssl_certificate_path, v.listener.ssl_certificate_vault_id, null) != null }

    content {
      name                = "${ssl_certificate.key}-ssl-cert"
      data                = try(filebase64(ssl_certificate.value.listener.ssl_certificate_path), null)
      password            = try(ssl_certificate.value.listener.ssl_certificate_pass, null)
      key_vault_secret_id = try(ssl_certificate.value.listener.ssl_certificate_vault_id, null)
    }
  }

  dynamic "http_listener" {
    for_each = var.rules

    content {
      name                           = "${http_listener.key}-listener"
      frontend_ip_configuration_name = "frontend_ipconfig"
      frontend_port_name             = "${http_listener.value.listener.port}-front-port"
      protocol                       = try(http_listener.value.listener.protocol, "Http")
      host_names                     = try(http_listener.value.listener.host_names, null)
      ssl_certificate_name           = try(http_listener.value.listener.ssl_certificate_path, http_listener.value.listener.ssl_certificate_vault_id, null) != null ? "${http_listener.key}-ssl-cert" : null
      ssl_profile_name               = try(http_listener.value.ssl_profile_name, null)

      dynamic "custom_error_configuration" {
        for_each = try(http_listener.value.listener.custom_error_pages, {})

        content {
          status_code           = custom_error_configuration.key
          custom_error_page_url = custom_error_configuration.value
        }
      }
    }
  }

  dynamic "redirect_configuration" {
    for_each = { for k, v in var.rules : k => v if can(v.redirect.type) }

    content {
      name                 = "${redirect_configuration.key}-redirect"
      redirect_type        = redirect_configuration.value.redirect.type
      target_listener_name = try(redirect_configuration.value.redirect.target_listener_name, null)
      target_url           = try(redirect_configuration.value.redirect.target_url, null)
      include_path         = try(redirect_configuration.value.redirect.include_path, null)
      include_query_string = try(redirect_configuration.value.redirect.include_query_string, null)
    }
  }

  dynamic "rewrite_rule_set" {
    for_each = { for k, v in var.rules : k => v if can(v.rewrite_sets) }

    content {
      name = "${rewrite_rule_set.key}-rewrite-set"

      dynamic "rewrite_rule" {
        for_each = rewrite_rule_set.value.rewrite_sets

        content {
          name          = rewrite_rule.key
          rule_sequence = rewrite_rule.value.sequence

          dynamic "condition" {
            for_each = can(rewrite_rule.value.condition) ? [1] : []
            content {
              variable    = rewrite_rule.value.condition.variable
              pattern     = rewrite_rule.value.condition.pattern
              ignore_case = try(rewrite_rule.value.condition.ignore_case, null)
              negate      = try(rewrite_rule.value.condition.negate, null)
            }
          }

          dynamic "request_header_configuration" {
            for_each = can(rewrite_rule.value.request_header) ? [1] : []
            content {
              header_name  = rewrite_rule.value.request_header.name
              header_value = rewrite_rule.value.request_header.value
            }
          }

          dynamic "response_header_configuration" {
            for_each = can(rewrite_rule.value.response_header) ? [1] : []
            content {
              header_name  = rewrite_rule.value.response_header.name
              header_value = rewrite_rule.value.response_header.value
            }
          }
        }
      }
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.rules

    content {
      name      = "${request_routing_rule.key}-rule"
      rule_type = "Basic"
      priority  = try(request_routing_rule.value.priority, null)

      http_listener_name = "${request_routing_rule.key}-listener"

      backend_address_pool_name  = can(request_routing_rule.value.redirect.type) ? null : "vmseries"
      backend_http_settings_name = can(request_routing_rule.value.redirect.type) ? null : "${request_routing_rule.key}-httpsettings"

      redirect_configuration_name = can(request_routing_rule.value.redirect.type) ? "${request_routing_rule.key}-redirect" : null

      rewrite_rule_set_name = can(request_routing_rule.value.rewrite_sets) ? "${request_routing_rule.key}-rewrite-set" : null
    }
  }

}

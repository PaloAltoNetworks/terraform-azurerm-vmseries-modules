locals {
  # Calculate a map of unique frontend ports based on the `listener.port` values defined in `rules` map.
  # A unique set of ports will be created upfront and then referenced in the listener's config.
  front_ports_list = distinct([for k, v in var.listeners : v.port])
  front_ports_map  = { for v in local.front_ports_list : v => v }

  # Calculate a flat map of all backend's trusted root certificates.
  # Root certs are created upfront and then referenced in a single list in the http setting's config.
  root_certs_flat_list = flatten([
    for k, v in var.backends : [
      for key, root_cert in v.root_certs : root_cert
    ]
  ])
  root_certs_map = { for v in local.root_certs_flat_list : v.name => v.path }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip
data "azurerm_public_ip" "this" {
  count = var.application_gateway.public_ip.create ? 0 : 1

  name                = var.application_gateway.public_ip.name
  resource_group_name = coalesce(var.application_gateway.public_ip.resource_group_name, var.resource_group_name)
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
resource "azurerm_public_ip" "this" {
  count = var.application_gateway.public_ip.create ? 1 : 0

  name                = var.application_gateway.public_ip.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku               = "Standard"
  allocation_method = "Static"
  domain_name_label = var.application_gateway.domain_name_label
  zones             = var.application_gateway.zones
  tags              = var.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway
resource "azurerm_application_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.application_gateway.zones
  enable_http2        = var.application_gateway.enable_http2
  tags                = var.tags

  sku {
    name     = var.application_gateway.waf != null ? "WAF_v2" : "Standard_v2"
    tier     = var.application_gateway.waf != null ? "WAF_v2" : "Standard_v2"
    capacity = var.application_gateway.capacity.autoscale == null ? var.application_gateway.capacity.static : null
  }

  dynamic "waf_configuration" {
    for_each = var.application_gateway.waf != null ? [1] : []

    content {
      enabled          = true
      firewall_mode    = var.application_gateway.waf.prevention_mode ? "Prevention" : "Detection"
      rule_set_type    = var.application_gateway.waf.rule_set_type
      rule_set_version = var.application_gateway.waf.rule_set_version
    }
  }

  dynamic "autoscale_configuration" {
    for_each = var.application_gateway.capacity.autoscale != null ? [1] : []

    content {
      min_capacity = var.application_gateway.capacity.autoscale.min
      max_capacity = var.application_gateway.capacity.autoscale.max
    }
  }

  dynamic "identity" {
    for_each = var.application_gateway.managed_identities != null ? [1] : []

    content {
      type         = "UserAssigned"
      identity_ids = var.application_gateway.managed_identities
    }
  }

  gateway_ip_configuration {
    name      = "ip_config"
    subnet_id = var.application_gateway.subnet_id
  }

  frontend_ip_configuration {
    name                 = var.application_gateway.frontend_ip_configuration_name
    public_ip_address_id = try(azurerm_public_ip.this[0].id, data.azurerm_public_ip.this[0].id)
  }

  # There is only a single backend - the VMSeries private IPs assigned to untrusted NICs
  # REFACTOR: APPGW : check if we can add NICs as backends, not only IPs
  backend_address_pool {
    name         = var.application_gateway.backend_pool.name
    ip_addresses = var.application_gateway.backend_pool.vmseries_ips
  }

  ssl_policy {
    policy_name          = var.application_gateway.global_ssl_policy.type == "Predefined" ? var.application_gateway.global_ssl_policy.name : null
    policy_type          = var.application_gateway.global_ssl_policy.type
    min_protocol_version = var.application_gateway.global_ssl_policy.min_protocol_version
    cipher_suites        = var.application_gateway.global_ssl_policy.cipher_suites
  }

  # The following block is supported only in v2 Application Gateways.
  dynamic "ssl_profile" {
    for_each = var.ssl_profiles

    content {
      name = ssl_profile.value.name
      ssl_policy {
        policy_name          = var.application_gateway.global_ssl_policy.type == "Predefined" ? ssl_profile.value.ssl_policy_name : null
        policy_type          = var.application_gateway.global_ssl_policy.type
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
    for_each = var.probes

    content {
      name                                      = probe.value.name
      path                                      = probe.value.path
      protocol                                  = probe.value.protocol
      host                                      = probe.value.host
      pick_host_name_from_backend_http_settings = probe.value.host == null
      port                                      = probe.value.port
      interval                                  = probe.value.interval
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.threshold

      dynamic "match" {
        for_each = probe.value.match_code != null ? [1] : []

        content {
          status_code = probe.value.match_code
          body        = probe.value.match_body
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
    for_each = var.backends

    content {
      name                                = backend_http_settings.value.name
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      pick_host_name_from_backend_address = backend_http_settings.value.hostname_from_backend
      host_name                           = backend_http_settings.value.hostname
      path                                = backend_http_settings.value.path
      request_timeout                     = backend_http_settings.value.timeout
      probe_name = (backend_http_settings.value.probe_key != null && var.probes != null ?
      var.probes[backend_http_settings.value.probe_key].name : null)
      cookie_based_affinity          = backend_http_settings.value.use_cookie_based_affinity ? "Enabled" : "Disabled"
      affinity_cookie_name           = backend_http_settings.value.affinity_cookie_name
      trusted_root_certificate_names = [for k, v in backend_http_settings.value.root_certs : v.name]
    }
  }

  dynamic "ssl_certificate" {
    for_each = { for k, v in var.listeners : k => v if try(v.ssl_certificate_path, v.ssl_certificate_vault_id, null) != null }

    content {
      name                = ssl_certificate.key
      data                = filebase64(ssl_certificate.value.ssl_certificate_path)
      password            = ssl_certificate.value.ssl_certificate_pass
      key_vault_secret_id = ssl_certificate.value.ssl_certificate_vault_id
    }
  }

  dynamic "http_listener" {
    for_each = var.listeners

    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = var.application_gateway.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.port
      protocol                       = http_listener.value.protocol
      host_names                     = http_listener.value.host_names
      ssl_certificate_name = (try(http_listener.value.ssl_certificate_path,
      http_listener.value.ssl_certificate_vault_id, null) != null ? http_listener.key : null)
      ssl_profile_name = http_listener.value.ssl_profile_name

      dynamic "custom_error_configuration" {
        for_each = http_listener.value.custom_error_pages

        content {
          status_code           = custom_error_configuration.key
          custom_error_page_url = custom_error_configuration.value
        }
      }
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.redirects

    content {
      name          = redirect_configuration.value.name
      redirect_type = redirect_configuration.value.type
      target_listener_name = (redirect_configuration.value.target_listener_key != null ?
      var.listeners[redirect_configuration.value.target_listener_key].name : null)
      target_url           = redirect_configuration.value.target_url
      include_path         = redirect_configuration.value.include_path
      include_query_string = redirect_configuration.value.include_query_string
    }
  }

  dynamic "rewrite_rule_set" {
    for_each = var.rewrites

    content {
      name = rewrite_rule_set.value.name

      dynamic "rewrite_rule" {
        for_each = rewrite_rule_set.value.rules

        content {
          name          = rewrite_rule.value.name
          rule_sequence = rewrite_rule.value.sequence

          dynamic "condition" {
            for_each = rewrite_rule.value.conditions
            content {
              variable    = condition.key
              pattern     = condition.value.pattern
              ignore_case = condition.value.ignore_case
              negate      = condition.value.negate
            }
          }

          dynamic "request_header_configuration" {
            for_each = rewrite_rule.value.request_headers
            content {
              header_name  = request_header_configuration.key
              header_value = request_header_configuration.value
            }
          }

          dynamic "response_header_configuration" {
            for_each = rewrite_rule.value.response_headers
            content {
              header_name  = response_header_configuration.key
              header_value = response_header_configuration.value
            }
          }
        }
      }
    }
  }

  dynamic "url_path_map" {
    for_each = var.url_path_maps

    content {
      name                               = url_path_map.value.name
      default_backend_address_pool_name  = var.application_gateway.backend_pool.name
      default_backend_http_settings_name = var.backends[url_path_map.value.backend_key].name

      dynamic "path_rule" {
        for_each = url_path_map.value.path_rules

        content {
          name                        = path_rule.key
          paths                       = path_rule.value.paths
          backend_address_pool_name   = path_rule.value.backend_key != null ? var.application_gateway.backend_pool.name : null
          backend_http_settings_name  = path_rule.value.backend_key != null ? var.backends[path_rule.value.backend_key].name : null
          redirect_configuration_name = path_rule.value.redirect_key != null ? var.redirects[path_rule.value.redirect_key].name : null
        }
      }
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.rules

    content {
      name      = request_routing_rule.value.name
      rule_type = request_routing_rule.value.url_path_map_key != null ? "PathBasedRouting" : "Basic"
      priority  = request_routing_rule.value.priority

      http_listener_name = var.listeners[request_routing_rule.value.listener_key].name
      backend_address_pool_name = (
        request_routing_rule.value.backend_key != null ? var.application_gateway.backend_pool.name : null
      )
      backend_http_settings_name = (
        request_routing_rule.value.backend_key != null ? var.backends[request_routing_rule.value.backend_key].name : null
      )
      redirect_configuration_name = (
        request_routing_rule.value.redirect_key != null ? var.redirects[request_routing_rule.value.redirect_key].name : null
      )
      rewrite_rule_set_name = (
        request_routing_rule.value.rewrite_key != null ? var.rewrites[request_routing_rule.value.rewrite_key].name : null
      )
      url_path_map_name = (
        request_routing_rule.value.url_path_map_key != null ? var.url_path_maps[request_routing_rule.value.url_path_map_key].name : null
      )
    }
  }

  lifecycle {
    precondition {
      condition = var.probes != null ? alltrue(flatten([
        for k, probe in var.probes : probe.host != null || alltrue(flatten([
          for b, backend in var.backends : backend.probe_key == k ? backend.hostname != null || backend.hostname_from_backend : true
        ]))
      ])) : true
      error_message = <<EOF
      Custom health probes needs to have defined host or backend settings needs to
      contain overriden host name or enabled option to pick host name from backend target.
      EOF
    }
  }
}

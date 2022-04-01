locals {
  # We set the public IP properties based on AppGW tier as they have to match.
  pip_sku = length(regexall(".*_v2$", var.sku.tier)) > 0 ? "Standard" : "Basic"

  # The allocation method has to match PIP's SKU as well.
  pip_allocation_method = local.pip_sku == "Basic" ? "Dynamic" : "Static"

  # Calculate a map of unique frontend ports based on the `listener_port` values defined in `rules` map.
  # A unque set of ports will be created upfront and then referenced in the listener's config.
  front_ports_list = distinct([for k, v in var.rules : v.listener_port])
  front_ports_map  = { for v in local.front_ports_list : "${v}-front-port" => v }

  # Calculate a flat map of all backend's trusted root certificates.
  # Root certs are created upfront and then referenced in a single list in the http setting's config.
  root_certs_flat_list = flatten([
    for k, v in var.rules : [
      for name, path in v.backend_root_certs : {
        name = "${k}-${name}"
        path = path
      }
    ] if try(v.backend_root_certs, null) != null
  ])

  root_certs_map = { for v in local.root_certs_flat_list : v.name => v.path }
}

resource "azurerm_public_ip" "this" {
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = local.pip_sku
  allocation_method   = local.pip_allocation_method
}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.sku.name
    tier     = var.sku.tier
    capacity = var.sku.capacity
  }

  gateway_ip_configuration {
    name      = "appgw_ip_config"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "frontend_ipconfig"
    public_ip_address_id = azurerm_public_ip.this.id
  }

  # There is only a single backend - the VMSeries private IPs assigned tu untrusted NICs
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
    for_each = contains(["Standard_v2", "WAF_v2"], var.sku.tier) ? var.ssl_profiles : {}

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
    for_each = { for k, v in var.rules : k => v if try(v.probe_path, null) != null }

    content {
      name                                      = "${probe.key}-probe"
      path                                      = probe.value.probe_path
      protocol                                  = try(probe.value.backend_protocol, "http")
      host                                      = try(probe.value.probe_host, null)
      pick_host_name_from_backend_http_settings = try(probe.value.probe_host, null) == null ? true : false
      port                                      = contains(["Standard_v2", "WAF_v2"], var.sku.tier) ? try(probe.value.probe_port, null) : null
      interval                                  = try(probe.value.probe_interval, 5)
      timeout                                   = try(probe.value.probe_timeout, 30)
      unhealthy_threshold                       = try(probe.value.probe_treshold, 2)

      dynamic "match" {
        for_each = try(probe.value.probe_match_code, null) != null ? { 1 = 1 } : {}

        content {
          status_code = probe.value.probe_match_code
          body        = try(probe.value.probe_match_body, null)
        }
      }
    }
  }

  # Trust root certs for use with backends. Only for v2 version.
  dynamic "trusted_root_certificate" {
    for_each = contains(["Standard_v2", "WAF_v2"], var.sku.tier) ? local.root_certs_map : {}

    content {
      name = trusted_root_certificate.key
      data = filebase64(trusted_root_certificate.value)
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.rules

    content {
      name                                = "${backend_http_settings.key}-httpsettings"
      port                                = try(backend_http_settings.value.backend_port, 80)
      protocol                            = try(backend_http_settings.value.backend_protocol, "http")
      pick_host_name_from_backend_address = try(backend_http_settings.value.backend_hostname_from_backend, null)
      host_name                           = try(backend_http_settings.value.backend_hostname, null)
      path                                = try(backend_http_settings.value.backend_path, null)
      request_timeout                     = try(backend_http_settings.value.backend_timeout, 60)
      probe_name                          = try(backend_http_settings.value.probe_path, null) != null ? "${backend_http_settings.key}-probe" : null
      cookie_based_affinity               = try(backend_http_settings.value.cookie_based_affinity, "Enabled")
      affinity_cookie_name                = try(backend_http_settings.value.affinity_cookie_name, null)
      trusted_root_certificate_names = contains(["Standard_v2", "WAF_v2"], var.sku.tier) && try(backend_http_settings.value.backend_root_certs, null) != null ? (
        [
          for k, v in backend_http_settings.value.backend_root_certs : "${backend_http_settings.key}-${k}"
        ]) : (
        null
      )
    }
  }

  dynamic "ssl_certificate" {
    for_each = { for k, v in var.rules : k => v if try(v.ssl_certificate_path, null) != null }

    content {
      name     = "${ssl_certificate.key}-ssl-cert"
      data     = filebase64(ssl_certificate.value.ssl_certificate_path)
      password = ssl_certificate.value.ssl_certificate_pass
    }
  }

  dynamic "http_listener" {
    for_each = var.rules

    content {
      name                           = "${http_listener.key}-listener"
      frontend_ip_configuration_name = "frontend_ipconfig"
      frontend_port_name             = "${http_listener.value.listener_port}-front-port"
      protocol                       = try(http_listener.value.listener_protocol, "http")
      host_name                      = ! contains(["Standard_v2", "WAF_v2"], var.sku.tier) ? try(http_listener.value.host_names[0], null) : null
      host_names                     = contains(["Standard_v2", "WAF_v2"], var.sku.tier) ? try(http_listener.value.host_names, null) : null
      ssl_certificate_name           = try(http_listener.value.ssl_certificate_path, null) != null ? "${http_listener.key}-ssl-cert" : null
      ssl_profile_name               = contains(["Standard_v2", "WAF_v2"], var.sku.tier) ? try(http_listener.value.ssl_profile_name, null) : null

      dynamic "custom_error_configuration" {
        for_each = try(http_listener.value.custom_error_pages, null) != null ? http_listener.value.custom_error_pages : {}

        content {
          status_code           = custom_error_configuration.key
          custom_error_page_url = custom_error_configuration.value
        }
      }
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.rules

    content {
      name                       = "${request_routing_rule.key}-rule"
      rule_type                  = "Basic"
      http_listener_name         = "${request_routing_rule.key}-listener"
      backend_address_pool_name  = "vmseries"
      backend_http_settings_name = "${request_routing_rule.key}-httpsettings"
      priority                   = contains(["Standard_v2", "WAF_v2"], var.sku.tier) ? try(request_routing_rule.value.priority, null) : null
    }
  }
}

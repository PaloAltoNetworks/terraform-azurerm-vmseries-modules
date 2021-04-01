resource "random_id" "storage_account" {
  byte_length = 2
}

resource "azurerm_public_ip" "appgw" {
  name                = "appgw"
  location            = var.location
  resource_group_name = var.resource_group_name
  domain_name_label   = "appgw-${lower(random_id.storage_account.hex)}"
  allocation_method   = "Dynamic"
  tags                = var.tags
}

resource "azurerm_application_gateway" "appgw" {
  name                = var.appgw_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "WAF_Medium"
    tier     = "WAF"
    capacity = 2
  }

  waf_configuration {
    enabled          = "true"
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"
  }

  gateway_ip_configuration {
    name      = "appgw"
    subnet_id = var.appgw_subnet_id
  }

  frontend_port {
    name = var.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  backend_address_pool {
    name         = var.backend_address_pool_name
    ip_addresses = var.fw_private_ips

  }

  http_listener {
    name                           = var.listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
  }

  backend_http_settings {
    name                  = var.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  request_routing_rule {
    name                       = var.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = var.listener_name
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.http_setting_name
  }
}

output appgw_publicip {
  value = azurerm_public_ip.appgw.ip_address
  description = "Public address IP for application gateway listener."
}

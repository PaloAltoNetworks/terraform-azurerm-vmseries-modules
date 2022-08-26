output "backend_pool_id" {
  description = "The identifier of the backend pool."
  value       = azurerm_lb_backend_address_pool.lb_backend.id
}

output "frontend_ip_configs" {
  description = "Map of IP addresses, one per each entry of `frontend_ips` input. Contains public IP address for the frontends that have it, private IP address otherwise."
  value       = local.output_ips
}

output "frontend_combined_rules" {
  description = <<-EOF
  Map of all rules of all load balancer's frontends combined.
  The map entries are intended to be easily convertible into NSG rules, hence each entry
  contains `port`, `protocol`,  `frontend_ip`, and numerical sequential `index`.
  The `frontend_ip` is the same as returned by output `frontend_ip_configs`.

  Full example:

  ```
  {
    "frontend01-balancessh" = {
      fipkey       = "frontend01"
      frontend_ip  = "34.34.34.34"
      hash16       = 45991
      index        = 0
      nsg_priority = null
      port         = 22
      protocol     = "tcp"
      rulekey      = "balancessh"
    }
  }
  ```
  EOF
  value       = local.output_rules
}

output "health_probe" {
  description = "The health probe object."
  value       = azurerm_lb_probe.probe
}

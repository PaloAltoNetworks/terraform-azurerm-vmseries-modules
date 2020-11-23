output "loadbalancer-id" {
  value = {
    for l in azurerm_lb.azlb :
    l.name => l.id
  }
}

output "pools" {
  value = {
    for l in azurerm_lb_backend_address_pool.lbback :
    l.name => l.id
  }
}

resource_group_name  = "appgw-rg"
location             = "East US"
virtual_network_name = "appgw-vnet"
address_space        = ["10.0.0.0/24"]
network_security_groups = {
  "network_security_group_1" = {
    rules = {}
  }
}
route_tables = {
  "route_table_1" = {
    routes = {}
  }
}
subnets = {
  "appgw" = {
    address_prefixes = ["10.0.0.0/26"]
  }
}

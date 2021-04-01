resource_group_name = "example_rg"
location            = "East US"
tags                = { "ENV" : "exampe" }
appgw_name          = "appgw_example"
appgw_subnet_id     = "/subscriptions/xxxxxxxxxxxxxxxxx/resourceGroups/example_rg/providers/Microsoft.Network/virtualNetworks/example_rg-vnet/subnets/appgw-subnet"
fw_private_ips      = [ "10.1.40.132" ]

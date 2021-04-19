resource_group_name  = "example-rg"
location             = "East US"
virtual_network_name = "example-vnet"
address_space        = ["10.112.0.0/16"]
network_security_groups = {
  "network_security_group_1" = {
    location = "East US"
    rules = {
      "AllOutbound" = {
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "AllowSSH" = {
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
    }
  },
  "network_security_group_2" = {
    rules = {}
  },
  "network_security_group_3" = {
    rules = {
      "AllOutbound" = {
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
    }
  },
}
route_tables = {
  "route_table_1" = {
    routes = {
      "route_1" = {
        address_prefix = "10.110.0.0/16"
        next_hop_type  = "vnetlocal"
      },
      "route_2" = {
        address_prefix = "10.111.0.0/16"
        next_hop_type  = "vnetlocal"
      },
    }
  },
  "route_table_2" = {
    routes = {},
  },
  "route_table_3" = {
    routes = {
      "route_3" = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.112.0.100"
      },
    }
  },
}
subnets = {
  "management" = {
    address_prefixes       = ["10.112.255.0/24"]
    network_security_group = "network_security_group_1"
    route_table            = "route_table_1"
  },
  "private" = {
    address_prefixes       = ["10.112.0.0/24"]
    network_security_group = "network_security_group_2"
    route_table            = "route_table_2"
  },
  "public" = {
    address_prefixes       = ["10.112.129.0/24"]
    network_security_group = "network_security_group_3"
    route_table            = "route_table_3"
  },
}
tags = {
  env      = "example",
  provider = "terraform"
}

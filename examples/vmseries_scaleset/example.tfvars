resource_group_name = "vmss-example-rg"
location            = "East US"
name_prefix         = "vmssexample"
vmseries_count      = 1

public_frontend_ips = {
  pip-existing = {
    create_public_ip = true
    rules = {
      HTTP = {
        port         = 80
        protocol     = "Tcp"
        backend_name = "backend1_name"
      }
    }
  }
}

private_frontend_ips = {
  internal_fe = {
    subnet_id                     = ""
    private_ip_address_allocation = "Dynamic" // Dynamic or Static
    private_ip_address            = ""
    rules = {
      HA_PORTS = {
        port         = 0
        protocol     = "All"
        backend_name = "backend3_name"
      }
    }
  }
}
olb_private_ip = "10.112.1.100"

files = {
  "files/authcodes.sample"    = "license/authcodes"
  "files/init-cfg.sample.txt" = "config/init-cfg.txt"
}

storage_account_name = "vmssexample20210406"
virtual_network_name = "vmss-example-vnet"
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
}

route_tables = {
  "route_table_1" = {
    routes = {
    }
  },
  "route_table_2" = {
    routes = {},
  },
  "route_table_3" = {
    routes = {
    }
  },
}

subnets = {
  "management" = {
    address_prefixes       = ["10.112.0.0/24"]
    network_security_group = "network_security_group_1"
    route_table            = "route_table_1"
  },
  "private" = {
    address_prefixes       = ["10.112.1.0/24"]
    network_security_group = "network_security_group_1"
    route_table            = "route_table_2"
  },
  "public" = {
    address_prefixes       = ["10.112.2.0/24"]
    network_security_group = "network_security_group_1"
    route_table            = "route_table_3"
  },
}

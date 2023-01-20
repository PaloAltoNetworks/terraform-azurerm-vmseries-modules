virtual_network_name = "vnet-vmseries"
address_space        = ["10.110.0.0/16"]

network_security_groups = {
  "sg-mgmt" = {
    rules = {
      vmseries_mgmt_allow_inbound = {
        priority  = 100
        direction = "Inbound"
        access    = "Allow"
        protocol  = "Tcp"
        # source_address_prefixes    = ["x.x.x.x"] # TODO add public from which you will connect to management interface
        source_address_prefixes    = ["134.238.135.14/32"] # TODO add public from which you will connect to management interface
        source_port_range          = "*"
        destination_address_prefix = "10.110.255.0/24"
        destination_port_ranges    = ["22", "443"]
      }
    }
  }
  "sg-private" = {}
  "sg-public"  = {}
}

route_tables = {
  private_route_table = {
    routes = {
      default = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.110.0.21"
      }
    }
  }
}

subnets = {
  "subnet-mgmt" = {
    address_prefixes       = ["10.110.255.0/24"]
    network_security_group = "sg-mgmt"
  }
  "subnet-private" = {
    address_prefixes       = ["10.110.0.0/24"]
    network_security_group = "sg-private"
    route_table            = "private_route_table"
  }
  "subnet-public" = {
    address_prefixes       = ["10.110.129.0/24"]
    network_security_group = "sg-public"
  }
}

load_balancers = {
  "lb-public" = {
    network_security_group_name = "sg-public"
    # network_security_allow_source_ips = ["x.x.x.x"] # TODO add public IPs from which you will connect to the public Load Balancer
    network_security_allow_source_ips = ["134.238.135.14/32"] # TODO add public IPs from which you will connect to the public Load Balancer
    avzones                           = ["1", "2", "3"]

    frontend_ips = {
      "palo-lb-app1-pip" = {
        create_public_ip = true
        rules = {
          "balanceHttp" = {
            protocol = "Tcp"
            port     = 80
          }
          "balanceHttps" = {
            protocol = "Tcp"
            port     = 443
          }
        }
      }
    }
  }
  "lb-private" = {
    frontend_ips = {
      "ha-ports" = {
        subnet_name        = "subnet-private"
        private_ip_address = "10.110.0.21"
        rules = {
          HA_PORTS = {
            port     = 0
            protocol = "All"
          }
        }
      }
    }
  }
}

vmseries_version = "10.2.0"
vmseries_vm_size = "Standard_DS3_v2"
vmseries_sku     = "byol"
vmseries = {
  "vmseries-1" = {
    bootstrap_options = "type=dhcp-client" # TODO add your bootstrap settings here
    avzone            = 1
    interfaces = [
      {
        name        = "mgmt"
        subnet_name = "subnet-mgmt"
        create_pip  = true
      },
      {
        name                 = "public"
        subnet_name          = "subnet-public"
        backend_pool_lb_name = "lb-public"
        create_pip           = true
      },
      {
        name                 = "private"
        subnet_name          = "subnet-private"
        backend_pool_lb_name = "lb-private"
      },
    ]
  }
  "vmseries-2" = {
    bootstrap_options = "type=dhcp-client" # TODO add your bootstrap settings here
    avzone            = 2
    interfaces = [
      {
        name        = "mgmt"
        subnet_name = "subnet-mgmt"
        create_pip  = true
      },
      {
        name                 = "public"
        subnet_name          = "subnet-public"
        backend_pool_lb_name = "lb-public"
        create_pip           = true
      },
      {
        name                 = "private"
        subnet_name          = "subnet-private"
        backend_pool_lb_name = "lb-private"
      },
    ]
  }
}

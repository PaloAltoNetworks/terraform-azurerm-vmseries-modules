location             = "East US 2"
virtual_network_name = "vnet-vmseries"
address_space        = ["10.110.0.0/16"]
network_security_groups = {
  "sg-mgmt" = {
    rules = {
      "vmseries-allowall-outbound" = {
        access                     = "Allow"
        direction                  = "Outbound"
        priority                   = 100
        protocol                   = "*"
        source_port_range          = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        destination_port_range     = "*"
      }
      "vmseries-mgmt-inbound" = {
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 101
        protocol                   = "*"
        source_port_range          = "*"
        source_address_prefix      = "10.255.0.0/24" // External peering access
        destination_address_prefix = "*"
        destination_port_range     = "*"
      }
      "vm-management-rules" = {
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 100
        protocol                   = "TCP"
        source_port_range          = "*"
        source_address_prefix      = "199.199.199.199"
        destination_address_prefix = "*"
        destination_port_range     = "*"
      }
    }
  }
  "sg-allowall" = {
    rules = {
      "public-allowall-inbound" = {
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 100
        protocol                   = "*"
        source_port_range          = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        destination_port_range     = "*"
      }
      "public-allowall-outbound" = {
        access                     = "Allow"
        direction                  = "Outbound"
        priority                   = 101
        protocol                   = "*"
        source_port_range          = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        destination_port_range     = "*"
      }
    }
  }
}
route_tables = {
  "udr-private" = {
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
    network_security_group = "sg-allowall"
    route_table            = "udr-private"
  }
  "subnet-public" = {
    address_prefixes       = ["10.110.129.0/24"]
    network_security_group = "sg-allowall"
  }
}

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

vmseries = {
  "fw00" = { avzone = 1 }
  "fw01" = { avzone = 2 }
}

common_vmseries_version = "9.1.3"
common_vmseries_sku     = "bundle1"
storage_account_name    = "pantfstorage"
storage_share_name      = "ibbootstrapshare"

files = {
  "files/authcodes.sample"    = "license/authcodes"
  "files/init-cfg.sample.txt" = "config/init-cfg.txt"
}

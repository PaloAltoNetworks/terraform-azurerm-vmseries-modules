location             = "East US 2"
resource_group_name  = "example-rg"
virtual_network_name = "vnet-vmseries"
address_space        = ["10.110.0.0/16"]

network_security_groups = {
  "sg-mgmt"    = {}
  "sg-private" = {}
  "sg-public"  = {}
}

allow_inbound_mgmt_ips = [
  "191.191.191.191", # Put your own public IP address here
  "10.255.0.0/24",   # Example Panorama access
]

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
    network_security_group = "sg-private"
    route_table            = "udr-private"
  }
  "subnet-public" = {
    address_prefixes       = ["10.110.129.0/24"]
    network_security_group = "sg-public"
  }
}

frontend_ips = {
  "frontend01" = {
    create_public_ip = true
    rules = {
      "balancessh" = {
        protocol = "Tcp"
        port     = 22
      }
    }
  }
}

vmseries = {
  "fw00" = { avzone = 1 }
  "fw01" = { avzone = 2 }
}

common_vmseries_version = "9.1.6"
common_vmseries_sku     = "bundle2"
storage_account_name    = "pantfstorage"
storage_share_name      = "ibbootstrapshare"

files = {
  "files/authcodes"    = "license/authcodes" # authcode is required only with common_vmseries_sku = "byol"
  "files/init-cfg.txt" = "config/init-cfg.txt"
}

spoke_resource_group_name  = "example_spoke_rg"
spoke_virtual_network_name = "example_spoke_vnet"
spoke_address_space        = ["10.113.0.0/16"]

spoke_subnets = {
  "private" = {
    address_prefixes       = ["10.113.0.0/24"]
    network_security_group = "sg-allowall"
    route_table            = "route_table_spoke"
  },
}

vmspoke = {
  "spoke00" = { avzone = 1 }
}

spoke_route_tables = {
  "route_table_spoke" = {
    routes = {
      "route_4" = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.112.0.100"
      },
    },
  },
}

peering_spoke_name  = "spoke_peering_example"
peering_common_name = "common_peering_example"
spoke_vm_size       = "Standard_DS1_v2"
spoke_vm_version    = "latest"
spoke_vm_sku        = "18.04-LTS"
spoke_vm_offer      = "UbuntuServer"
spoke_vm_publisher  = "Canonical"

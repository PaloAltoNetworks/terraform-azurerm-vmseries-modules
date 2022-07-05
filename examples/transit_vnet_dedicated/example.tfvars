location             = "East US 2"
resource_group_name  = "example-rg"
virtual_network_name = "vnet-vmseries"
address_space        = ["10.110.0.0/16"]
enable_zones         = true

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

inbound_vmseries = {
  "inboundfw00" = { avzone = 1 }
  "inboundfw01" = { avzone = 2 }
}

inbound_vmseries_version = "10.0.4"
inbound_vmseries_vm_size = "Standard_D3_v2"

outbound_vmseries = {
  "outboundfw00" = { avzone = 1 }
  "outboundfw01" = { avzone = 2 }
}

outbound_vmseries_version = "10.0.4"
outbound_vmseries_vm_size = "Standard_D3_v2"

common_vmseries_sku         = "bundle1"
storage_account_name        = "pantfstorage"
inbound_storage_share_name  = "ibbootstrapshare"
outbound_storage_share_name = "obbootstrapshare"

inbound_files = {
  "inbound_files/authcodes"    = "license/authcodes" # this line is only needed for common_vmseries_sku  = "byol"
  "inbound_files/init-cfg.txt" = "config/init-cfg.txt"
}

outbound_files = {
  "outbound_files/authcodes"    = "license/authcodes" # this line is only needed for common_vmseries_sku  = "byol"
  "outbound_files/init-cfg.txt" = "config/init-cfg.txt"
}

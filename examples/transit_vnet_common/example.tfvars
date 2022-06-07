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

olb_private_ip = "10.110.0.21"

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

vmseries = {
  "fw00" = { avzone = 1 }
  "fw01" = { avzone = 2 }
}

common_vmseries_version = "9.1.3"
common_vmseries_sku     = "bundle1"
storage_account_name    = "pantfstorage"
storage_share_name      = "bootstrapshare"

files = {
  "files/authcodes"    = "license/authcodes" # authcode is required only with common_vmseries_sku = "byol"
  "files/init-cfg.txt" = "config/init-cfg.txt"
}

avzones = ["1", "2", "3"]
location                     = "East US"
inbound_resource_group_name  = "example-vmss-inbound"
outbound_resource_group_name = "example-vmss-outbound"
virtual_network_name         = "vmss-transit-vnet"
name_prefix                  = "vmseries-"
inbound_name_prefix          = "inbound-"
outbound_name_prefix         = "outbound-"
outbound_lb_name             = "outbound-private-ilb"
inbound_lb_name              = "inbound-public-elb"
name_scale_set               = "VMSS" # the suffix

tags = {}

address_space = ["10.110.0.0/16"]

network_security_groups = {
  sg_mgmt         = {}
  sg_private      = {}
  sg_pub_inbound  = {}
  sg_pub_outbound = {}
}

allow_inbound_mgmt_ips = [
  "191.191.191.191", # Put your own public IP address here, visit "https://ifconfig.me/"
  "10.255.0.0/24",   # Example Panorama access
]

allow_inbound_data_ips = []

route_tables = {
  private_route_table = {
    routes = {
      default = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.110.1.21"
      }
    }
  }
}

subnets = {
  "management" = {
    address_prefixes       = ["10.110.255.0/24"]
    network_security_group = "sg_mgmt"
  },
  "inbound_private" = {
    address_prefixes       = ["10.110.0.0/24"]
    network_security_group = "sg_private"
    route_table            = "private_route_table"
  },
  "inbound_public" = {
    address_prefixes       = ["10.110.129.0/24"]
    network_security_group = "sg_pub_inbound"
  },
  "outbound_private" = {
    address_prefixes       = ["10.110.1.0/24"] # confirm Ref-Arch scheme
    network_security_group = "sg_private"
    route_table            = "private_route_table"
  },
  "outbound_public" = {
    address_prefixes       = ["10.110.130.0/24"]
    network_security_group = "sg_pub_outbound"
  },
}

public_frontend_ips = {
  frontend01 = {
    create_public_ip = true
    rules = {
      balancehttp = {
        port     = 80
        protocol = "Tcp"
      }
      balancessh = {
        port     = 22
        protocol = "Tcp"
      }
    }
  }
}

olb_private_ip = "10.110.1.21"

inbound_vmseries_version  = "10.0.6"
inbound_vmseries_vm_size  = "Standard_D3_v2"
outbound_vmseries_version = "10.0.6"
outbound_vmseries_vm_size = "Standard_D3_v2"
common_vmseries_sku       = "bundle1"

inbound_count_minimum  = 2
inbound_count_maximum  = 5
outbound_count_minimum = 2
outbound_count_maximum = 5

autoscale_metrics = {
  "DataPlaneCPUUtilizationPct" = {
    scaleout_threshold = 80
    scalein_threshold  = 20
  }
  "panSessionUtilization" = {
    scaleout_threshold = 80
    scalein_threshold  = 20
  }
  "panSessionThroughputKbps" = {
    scaleout_threshold = 1800000 # >80 percent of 2.2G
    scalein_threshold  = 40000
  }
  # # For an easy trigger testing:
  # "panSessionThroughputPps" = {
  #   scaleout_threshold = 1000
  #   scalein_threshold  = 100
  # }
}

# Autoscaling grows:
scaleout_statistic        = "Average"
scaleout_time_aggregation = "Average"
scaleout_window_minutes   = 10
scaleout_cooldown_minutes = 30

# Autoscaling shrinks:
scalein_statistic        = "Max"
scalein_time_aggregation = "Average"
scalein_window_minutes   = 60
scalein_cooldown_minutes = 10080

storage_account_name        = "vmssexample20210406"
inbound_storage_share_name  = "ibbootstrapshare"
outbound_storage_share_name = "obbootstrapshare"

inbound_files = {
  # "inbound_files/authcodes"    = "license/authcodes" # this line is only needed for common_vmseries_sku  = "byol"
  "inbound_files/init-cfg.txt" = "config/init-cfg.txt"
}

outbound_files = {
  # "outbound_files/authcodes"    = "license/authcodes" # this line is only needed for common_vmseries_sku  = "byol"
  "outbound_files/init-cfg.txt" = "config/init-cfg.txt"
}

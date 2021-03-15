# Priority map of security rules for your management IP addresses.
# Each key is the public IP, and the number is the priority it gets in the relevant network security groups (NSGs).
resource_group_name = "pantf-example-rg"
management_ips = {
  "199.199.199.199" : 100,
}

# Optional Load Balancer (LB) rules
# These will automatically create a public Azure IP and associate to LB configuration.
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

vnets = {
  "vnet-panorama-mgmt" = {
    address_space = ["10.255.0.0/16"]
  }
  "vnet-vmseries" = {
    address_space = ["10.110.0.0/16"]
  }
}
network_security_groups = {
  "sg-panorama-mgmt" = {
    rules = {
      "inter-vnet-rule" = {
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 200
        protocol                   = "*"
        source_port_range          = "*"
        source_address_prefix      = "10.110.255.0/24"
        destination_address_prefix = "*"
        destination_port_range     = "*"
      }
      "panorama-allowall-outbound" = {
        access                     = "Allow"
        direction                  = "Outbound"
        priority                   = 100
        protocol                   = "*"
        source_port_range          = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        destination_port_range     = "*"
      }
      "management-rules" = {
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
        source_address_prefix      = "10.255.0.0/24"
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
      "outside-allowall-inbound" = {
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 100
        protocol                   = "*"
        source_port_range          = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        destination_port_range     = "*"
      }
      "outside-allowall-outbound" = {
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
  "udr-inside" = {
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
  "subnet-panorama-mgmt" = {
    address_prefixes       = ["10.255.0.0/24"]
    network_security_group = "sg-panorama-mgmt"
    virtual_network_name   = "vnet-panorama-mgmt"
  }
  "subnet_mgmt" = {
    address_prefixes       = ["10.110.255.0/24"]
    network_security_group = "sg-mgmt"
    virtual_network_name   = "vnet-vmseries"
  }
  "subnet-inside" = {
    address_prefixes       = ["10.110.0.0/24"]
    network_security_group = "sg-allowall"
    route_table            = "udr-inside"
    virtual_network_name   = "vnet-vmseries"
  }
  "subnet-outside" = {
    address_prefixes       = ["10.110.129.0/24"]
    network_security_group = "sg-allowall"
    virtual_network_name   = "vnet-vmseries"
  }
}
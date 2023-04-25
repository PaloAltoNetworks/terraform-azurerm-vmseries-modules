# --- GENERAL --- #
location              = "North Europe"
resource_group_name   = "panorama"
name_prefix           = "example-"
create_resource_group = true
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}
enable_zones = false



# --- VNET PART --- #
vnets = {
  "vnet" = {
    name          = "panorama-vnet"
    address_space = ["10.1.0.0/27"]
    network_security_groups = {
      "panorama" = {
        name = "panorama-nsg"
        rules = {
          vmseries_mgmt_allow_inbound = {
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_address_prefixes    = ["130.41.247.149", "130.41.247.15"]
            source_port_range          = "*"
            destination_address_prefix = "10.1.0.0/24"
            destination_port_ranges    = ["22", "443"]
          }
        }
      }
    }
    subnets = {
      "panorama" = {
        name                   = "panorama-snet"
        address_prefixes       = ["10.1.0.0/28"]
        network_security_group = "panorama"
      }
    }
  }
}


panorama_version = "10.2.3"

panoramas = {
  "pn-1" = {
    name     = "panorama01"
    vnet_key = "vnet"
    interfaces = [
      {
        name               = "management"
        subnet_key         = "panorama"
        private_ip_address = "10.1.0.10"
        create_pip         = true
      },
    ]
  }
}

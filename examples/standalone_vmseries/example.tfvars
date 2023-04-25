# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "vmseries-standalone"
name_prefix         = "example-"
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}
enable_zones = false


# --- VNET PART --- #
vnets = {
  "transit" = {
    name          = "transit"
    address_space = ["10.0.0.0/25"]
    network_security_groups = {
      "management" = {
        name = "mgmt-nsg"
        rules = {
          vmseries_mgmt_allow_inbound = {
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_address_prefixes    = ["134.238.135.137", "130.41.247.15"]
            source_port_range          = "*"
            destination_address_prefix = "10.0.0.0/28"
            destination_port_ranges    = ["22", "443"]
          }
        }
      }
    }
    subnets = {
      "management" = {
        name                   = "mgmt-snet"
        address_prefixes       = ["10.0.0.0/28"]
        network_security_group = "management"
      }
    }
  }
}


# --- VMSERIES PART --- #
vmseries_version = "10.2.3"
vmseries_vm_size = "Standard_DS3_v2"
vmseries = {
  "vm01" = {
    name              = "firewall01"
    bootstrap_options = "type=dhcp-client"
    vnet_key          = "transit"
    interfaces = [
      {
        name       = "mgmt"
        subnet_key = "management"
        create_pip = true
      },
    ]
  }
}

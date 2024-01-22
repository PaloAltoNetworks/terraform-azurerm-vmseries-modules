# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "vmseries-standalone"
name_prefix         = "example-"
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}

# --- VNET PART --- #
vnets = {
  "transit" = {
    name          = "transit"
    address_space = ["10.0.0.0/25"]
    network_security_groups = {
      "management" = {
        name = "mgmt-nsg"
        rules = {
          mgmt_inbound = {
            name                       = "vmseries-management-allow-inbound"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_address_prefixes    = ["1.2.3.4"]
            source_port_range          = "*"
            destination_address_prefix = "10.0.0.0/28"
            destination_port_ranges    = ["22", "443"]
          }
        }
      }
    }
    subnets = {
      "management" = {
        name                       = "mgmt-snet"
        address_prefixes           = ["10.0.0.0/28"]
        network_security_group_key = "management"
      }
    }
  }
}


# --- VMSERIES PART --- #
vmseries = {
  "fw-1" = {
    name = "firewall01"
    image = {
      version = "10.2.3"
    }
    virtual_machine = {
      bootstrap_options = "type=dhcp-client"
      vnet_key          = "transit"
      zone              = null
    }
    interfaces = [
      {
        name             = "vm-mgmt"
        subnet_key       = "management"
        create_public_ip = true
      }
    ]
  }
}

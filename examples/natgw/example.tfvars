# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "transit-vnet-common"
name_prefix         = "ac-"
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
            source_address_prefixes    = ["0.0.0.0/0"] # TODO: whitelist public IP addresses that will be used to manage the appliances
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


# --- NATGW PART --- #
natgws = {
  "natgw" = {
    create_natgw = true
    name         = "natgw"
    vnet_key     = "transit"
    subnet_keys  = ["management"]
    public_ip = {
      create = true
      name   = "natgw-pip"
    }
    public_ip_prefix = {
      create = true
      name   = "natgw-pip-prefix"
      length = 31
    }
  }
}
# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "transit-vnet-common"
name_prefix         = "fosix-"
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}


# --- VNET PART --- #
vnets = {
  empty = {
    name          = "empty"
    address_space = ["10.0.0.0/29"]
  }
  non-empty = {
    name          = "non-empty"
    address_space = ["8.0.0.0/5"]
    network_security_groups = {
      "nsg" = {
        name = "nsg"
        rules = {
          "a_rule" = {
            name                    = "a_rule_name"
            priority                = 100
            direction               = "Inbound"
            access                  = "Allow"
            protocol                = "Tcp"
            source_address_prefixes = ["1.2.3.4"] # TODO: whitelist public IP addresses that will be used to manage the appliances
            # source_port_range          = "*"
            source_port_ranges         = ["33", "44-55"]
            destination_address_prefix = "10.0.0.0/28"
            destination_port_ranges    = ["22", "443"]
          }
        }
      }
    }
    route_tables = {
      "rt" = {
        name = "a_udr"
        routes = {
          "udr" = {
            name           = "udr"
            address_prefix = "10.0.0.0/8"
            next_hop_type  = "None"
          }
        }
      }
    }
    subnets = {
      "some_subnet" = {
        name                       = "some-subnet"
        address_prefixes           = ["10.0.0.0/25"]
        network_security_group_key = "nsg"
        route_table_key            = "rt"
      }
    }
  }
}

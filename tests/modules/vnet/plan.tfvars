location            = "North Europe"
resource_group_name = "vnet-rg"
name_prefix         = "terratest-"
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terratest"
}

vnets = {
  empty = {
    name          = "empty"
    address_space = ["10.0.1.0/25"]
  }
  subnetted = {
    name          = "subnetted-vnet"
    address_space = ["10.0.2.0/25"]
    subnets = {
      subnet_a = {
        name             = "fosix-subnet_a"
        address_prefixes = ["10.0.2.0/26"]
      }
      subnet_b = {
        name             = "fosix-subnet_b"
        address_prefixes = ["10.0.2.64/26"]
      }
    }
  }
  non-empty = {
    name          = "non-empty"
    address_space = ["10.0.0.0/24"]
    network_security_groups = {
      "nsg" = {
        name = "nsg"
        rules = {
          "a_rule" = {
            name                       = "a_rule_name"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_address_prefixes    = ["1.2.3.4"]
            source_port_range          = "*"
            destination_address_prefix = "10.0.0.0/25"
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
        name                            = "some-subnet"
        address_prefixes                = ["10.0.0.0/25"]
        network_security_group_key      = "nsg"
        route_table_key                 = "rt"
        enable_storage_service_endpoint = true
      }
    }
  }
}

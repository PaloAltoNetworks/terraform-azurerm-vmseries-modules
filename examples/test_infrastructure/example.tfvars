# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "vmseries-test-infra"
name_prefix         = "example-"
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}


# --- VNET PART --- #
vnets = {
  "spoke_east" = {
    name          = "spoke-east"
    address_space = ["10.100.0.0/25"]
    # # Uncomment the lines below to enable peering between spokes created in this module and an existing transit VNET
    # hub_resource_group_name = "example-transit-vnet-dedicated" # TODO: replace with the name of transit VNET's Resource Group Name
    # hub_vnet_name = "example-transit" # TODO: replace with the name of the transit VNET
    route_tables = {
      nva = {
        name = "east2NVA"
        routes = {
          "2NVA" = {
            address_prefix         = "0.0.0.0/0"
            next_hop_type          = "VirtualAppliance"
            next_hop_in_ip_address = "10.0.0.30" # TODO: this by default matches the private IP of the private Load Balancer deployed in any of the examples; adjust if needed
          }
        }
      }
    }
    subnets = {
      "vms" = {
        name             = "vms"
        address_prefixes = ["10.100.0.0/26"]
        route_table      = "nva"
      }
      "bastion" = {
        name             = "AzureBastionSubnet"
        address_prefixes = ["10.100.0.64/26"]
      }
    }
  }
  "spoke_west" = {
    name          = "spoke-west"
    address_space = ["10.100.1.0/25"]
    # # Uncomment the lines below to enable peering between spokes created in this module and an existing transit VNET
    # hub_resource_group_name = "example-transit-vnet-dedicated" # TODO: replace with the name of transit VNET's Resource Group Name
    # hub_vnet_name = "example-transit" # TODO: replace with the name of the transit VNET
    route_tables = {
      nva = {
        name = "west2NVA"
        routes = {
          "2NVA" = {
            address_prefix         = "0.0.0.0/0"
            next_hop_type          = "VirtualAppliance"
            next_hop_in_ip_address = "10.0.0.30" # TODO: replace with IP address of the private Load Balancer in the transit VNET
          }
        }
      }
    }
    subnets = {
      "vms" = {
        name             = "vms"
        address_prefixes = ["10.100.1.0/26"]
        route_table      = "nva"
      }
      "bastion" = {
        name             = "AzureBastionSubnet"
        address_prefixes = ["10.100.1.64/26"]
      }
    }
  }
}


test_vms = {
  "east_vm" = {
    name       = "east-vm"
    vnet_key   = "spoke_east"
    subnet_key = "vms"
  }
  "west_vm" = {
    name       = "west-vm"
    vnet_key   = "spoke_west"
    subnet_key = "vms"
  }
}

bastions = {
  "bastion_east" = {
    name       = "east-bastion"
    vnet_key   = "spoke_east"
    subnet_key = "bastion"
  }
  "bastion_west" = {
    name       = "west-bastion"
    vnet_key   = "spoke_west"
    subnet_key = "bastion"
  }
}
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
          mgmt_inbound = {
            name                       = "vmseries-management-allow-inbound"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_address_prefixes    = ["0.0.0.0/0"] # TODO: whitelist public IP addresses that will be used to manage the appliances
            source_port_range          = "*"
            destination_address_prefix = "10.1.0.0/24"
            destination_port_ranges    = ["22", "443"]
          }
        }
      }
    }
    subnets = {
      "panorama" = {
        name                       = "panorama-snet"
        address_prefixes           = ["10.1.0.0/28"]
        network_security_group_key = "panorama"
      }
    }
  }
}

# --- PANORAMA PART --- #

panoramas = {
  "pn-1" = {
    name = "panorama01"
    authentication = {
      disable_password_authentication = false
      #ssh_keys                       = ["~/.ssh/id_rsa.pub"]
    }
    image = {
      version = "10.2.3"
    }
    virtual_machine = {
      vnet_key  = "vnet"
      size      = "Standard_D5_v2"
      zone      = null
      disk_name = "panorama-os-disk"
    }
    interfaces = [
      {
        name               = "management"
        subnet_key         = "panorama"
        private_ip_address = "10.1.0.10"
        create_public_ip   = true
      },
    ]
    logging_disks = {
      "datadisk1" = {
        name = "data-disk1"
        lun  = "0"
      }
    }
  }
}

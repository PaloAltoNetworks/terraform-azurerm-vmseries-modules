location             = "East US"
tags                 = { environment = "dev" }
panorama_name        = "example-panorama"
resource_group_name  = "example-rg"
storage_account_name = "examplestorage"
vnet_name            = "example-vnet"
enable_zones         = true
address_space        = ["10.112.0.0/16"]
panorama_version     = "10.1.5"

network_security_groups = {
  "network_security_group_1" = {
    location = "East US"
    rules = {
      "AllOutbound" = {
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "AllowSSH" = {
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
    }
  }
}

subnets = {
  "management" = {
    address_prefixes       = ["10.112.255.0/24"]
    network_security_group = "network_security_group_1"
  }
}

allow_inbound_mgmt_ips = [
  "199.199.199.199" # Put your own public IP address here, visit "https://ifconfig.me/"
]

avzones = ["1", "2", "3"]
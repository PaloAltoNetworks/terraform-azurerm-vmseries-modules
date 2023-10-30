# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "vng-example"
name_prefix         = "sczech-"
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}


# --- VNET PART --- #
vnets = {
  transit = {
    name                    = "transit"
    address_space           = ["10.0.0.0/24"]
    network_security_groups = {}
    route_tables = {
      "rt" = {
        name = "rt"
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
      "GatewaySubnet" = {
        name             = "GatewaySubnet"
        address_prefixes = ["10.0.0.0/25"]
        route_table_key  = "rt"
      }
    }
  }
}

# --- VNG PART --- #
virtual_network_gateways = {
  "vng" = {
    name          = "vng"
    type          = "Vpn"
    sku           = "VpnGw2AZ"
    generation    = "Generation2"
    active_active = true
    enable_bgp    = true
    zones         = ["1", "2", "3"]
    ip_configuration = [
      {
        name                   = "001"
        create_public_ip       = true
        public_ip_name         = "pip1"
        public_ip_standard_sku = true
        vnet_key               = "transit"
        subnet_name            = "GatewaySubnet"
      },
      {
        name                   = "002"
        create_public_ip       = true
        public_ip_name         = "pip2"
        public_ip_standard_sku = true
        vnet_key               = "transit"
        subnet_name            = "GatewaySubnet"
      }
    ]
    ipsec_shared_key = "test123"
    azure_bgp_peers_addresses = {
      primary_1   = "169.254.21.2"
      secondary_1 = "169.254.22.2"
    }
    local_bgp_settings = {
      asn = "65002"
      peering_addresses = {
        "001" = {
          apipa_addresses = ["primary_1"]
        },
        "002" = {
          apipa_addresses = ["secondary_1"]
        }
      }
    }
    local_network_gateways = {
      "lg1" = {
        local_ng_name   = "lg1"
        connection_name = "cn1"
        gateway_address = "8.8.8.8"
        remote_bgp_settings = [{
          asn                 = "65000"
          bgp_peering_address = "169.254.21.1"
        }]
        custom_bgp_addresses = [
          {
            primary   = "primary_1"
            secondary = "secondary_1"
          }
        ]
      },
      "lg2" = {
        local_ng_name   = "lg2"
        connection_name = "cn2"
        gateway_address = "4.4.4.4"
        remote_bgp_settings = [{
          asn                 = "65000"
          bgp_peering_address = "169.254.22.1"
        }]
        custom_bgp_addresses = [
          {
            primary   = "primary_1"
            secondary = "secondary_1"
          }
        ]
      }
    }
    connection_mode = "InitiatorOnly"
    ipsec_policies = [
      {
        dh_group         = "ECP384"
        ike_encryption   = "AES256"
        ike_integrity    = "SHA256"
        ipsec_encryption = "AES256"
        ipsec_integrity  = "SHA256"
        pfs_group        = "ECP384"
        sa_datasize      = "102400000"
        sa_lifetime      = "14400"
      }
    ]
  }
}
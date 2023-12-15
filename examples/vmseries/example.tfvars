# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "vmseries-refactor"
name_prefix         = "fosix-"
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
      management = {
        name                            = "mgmt-snet"
        address_prefixes                = ["10.0.0.0/28"]
        network_security_group_key      = "management"
        enable_storage_service_endpoint = true
      }
      public = {
        name                       = "public-snet"
        address_prefixes           = ["10.0.0.16/28"]
        network_security_group_key = "management"
      }
      private = {
        name                       = "private-snet"
        address_prefixes           = ["10.0.0.32/28"]
        network_security_group_key = "management"
      }
    }
  }
}

# load_balancers = {
#   lbe = {
#     name  = "lbe"
#     zones = null
#     frontend_ips = {
#       http = {
#         name             = "http"
#         create_public_ip = true
#         public_ip_name   = "fanci-lbe-pip"
#         in_rules = {
#           http = {
#             name     = "http"
#             protocol = "Tcp"
#             port     = 80
#           }
#         }
#         out_rules = {
#           "default_out" = {
#             name     = "default_out"
#             protocol = "All"
#           }
#         }
#       }
#     }
#   }
# }

availability_sets = {
  # aset = {
  #   name = "default_as"
  # }
}

bootstrap_storages = {
  "bootstrap" = {
    name = "fosixsmplbtstrp"
    file_shares_configuration = {
      vnet_key = "transit"
    }
    storage_network_security = {
      allowed_subnet_keys = ["management"]
    }
  }
}


# --- VMSERIES PART --- #
vmseries = {
  "fw-1" = {
    name = "firewall01"
    authentication = {
      disable_password_authentication = false
      # ssh_keys                        = ["~/.ssh/id_rsa.pub"]
    }
    image = {
      version = "10.2.3"
    }
    virtual_machine = {
      vnet_key          = "transit"
      size              = "Standard_DS3_v2"
      bootstrap_options = "type=dhcp-client"
      zone              = null
      avset_key         = "aset"
      disk_name         = "fancy-disk-name"
      bootstrap_storage = {
        bootstrap_key          = "bootstrap"
        static_files           = { "files/init-cfg.txt" = "config/init-cfg.txt" }
        template_bootstrap_xml = "templates/bootstrap_common.tmpl"
        bootstrap_package_path = "bootstrap_package"
        private_snet_key       = "private"
        public_snet_key        = "public"
      }
    }
    interfaces = [
      {
        name             = "mgmt"
        subnet_key       = "management"
        create_public_ip = true
        public_ip_name   = "fancy-pip-name"
      },
      {
        name       = "private"
        subnet_key = "private"
      },
      {
        name       = "public"
        subnet_key = "public"
        # load_balancer_key = "lbe"
      }
    ]
  }
}

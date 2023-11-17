# Common
name_prefix         = "example-"
location            = "East US"
resource_group_name = "vmseries-gwlb"
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}

# VNets
vnets = {
  security = {
    name          = "security"
    address_space = ["10.0.1.0/24"]
    subnets = {
      mgmt = {
        name                            = "vmseries-mgmt"
        address_prefixes                = ["10.0.1.0/28"]
        network_security_group          = "mgmt"
        enable_storage_service_endpoint = true
      }
      data = {
        name                   = "vmseries-data"
        address_prefixes       = ["10.0.1.16/28"]
        network_security_group = "data"
      }
    }
    network_security_groups = {
      mgmt = {
        name = "vmseries-mgmt"
        rules = {
          mgmt_inbound = {
            name                       = "vmseries-management-allow-inbound"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_address_prefixes    = ["191.191.191.191"] # Put your own public IP address here
            source_port_range          = "*"
            destination_address_prefix = "*"
            destination_port_ranges    = ["22", "443"]
          }
        }
      }
      data = {
        name = "vmseries-data"
      }
    }
    route_tables = {
      mgmt = {
        name = "vmseries-mgmt"
        routes = {
          data-blackhole = {
            name           = "data-blackhole-udr"
            address_prefix = "10.0.1.16/28"
            next_hop_type  = "None"
          }
        }
      }
      data = {
        name = "vmseries-data"
        routes = {
          mgmt-blackhole = {
            name           = "mgmt-blackhole-udr"
            address_prefix = "10.0.1.0/28"
            next_hop_type  = "None"
          }
        }
      }
    }
  }

  app1 = {
    name          = "app1-vnet"
    address_space = ["10.0.2.0/24"]
    subnets = {
      web = {
        name                   = "app1-web"
        address_prefixes       = ["10.0.2.0/28"]
        network_security_group = "web"
      }
    }
    network_security_groups = {
      web = {
        name = "app1-web"
        rules = {
          application-inbound = {
            name                       = "application-allow-inbound"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_address_prefixes    = ["191.191.191.191"] # Put your own public IP address here
            source_port_range          = "*"
            destination_address_prefix = "*"
            destination_port_ranges    = ["80", "443"]
          }
        }
      }
    }
  }
}

gateway_load_balancers = {
  gwlb = {
    name       = "vmseries-gwlb"
    vnet_key   = "security"
    subnet_key = "data"

    health_probe = {
      port = 80
    }

    backends = {
      ext-int = {
        tunnel_interfaces = {
          internal = {
            identifier = 800
            port       = 2000
            protocol   = "VXLAN"
            type       = "Internal"
          }
          external = {
            identifier = 801
            port       = 2001
            protocol   = "VXLAN"
            type       = "External"
          }
        }
      }
    }
  }
}

# VMseries
bootstrap_storages = {
  bootstrap = {
    name        = "vmseriesgwlbboostrap"
    storage_acl = true
    storage_allow_vnet_subnets = {
      management = {
        vnet_key   = "security"
        subnet_key = "mgmt"
      }
    }
  }
}

vmseries = {
  vms01 = {
    avzone = 1
    name   = "vmseries01"
    bootstrap_storage = {
      key                    = "bootstrap"
      static_files           = { "files/init-cfg.txt" = "config/init-cfg.txt" }
      template_bootstrap_xml = "templates/bootstrap-gwlb.tftpl"
    }
    interfaces = [
      {
        name             = "mgmt"
        subnet_key       = "mgmt"
        create_public_ip = true
      },
      {
        name                = "data"
        subnet_key          = "data"
        enable_backend_pool = true
        gwlb_key            = "gwlb"
        gwlb_backend_key    = "ext-int"
      }
    ]
  }
  vms02 = {
    avzone = 2
    name   = "vmseries02"
    bootstrap_storage = {
      key                    = "bootstrap"
      static_files           = { "files/init-cfg.txt" = "config/init-cfg.txt" }
      template_bootstrap_xml = "templates/bootstrap-gwlb.tftpl"
    }
    interfaces = [
      {
        name             = "mgmt"
        subnet_key       = "mgmt"
        create_public_ip = true
      },
      {
        name                = "data"
        subnet_key          = "data"
        enable_backend_pool = true
        gwlb_key            = "gwlb"
        gwlb_backend_key    = "ext-int"
      }
    ]
  }
}

vmseries_common = {
  username = "panadmin"
  ssh_keys = [] # Update here if required

  img_version = "10.2.3"
  img_sku     = "byol"
  vm_size     = "Standard_D3_v2"

  vnet_key = "security"
}

# Sample application
load_balancers = {
  app1 = {
    name = "app1-web"
    frontend_ips = {
      app1 = {
        name             = "app1"
        create_public_ip = true
        public_ip_name   = "lb-app1-pip"
        gwlb_key         = "gwlb"
        in_rules = {
          http = {
            name        = "HTTP"
            floating_ip = false
            port        = 80
            protocol    = "Tcp"
          }
          https = {
            name        = "HTTPs"
            floating_ip = false
            port        = 443
            protocol    = "Tcp"
          }
        }
        out_rules = {
          outbound = {
            name     = "tcp-outbound"
            protocol = "Tcp"
          }
        }
      }
    }
  }
}

appvms_common = {
  username    = "appadmin"
  custom_data = <<SCRIPT
#!/bin/sh
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
echo "Backend VM is $(hostname)" | sudo tee /var/www/html/index.html
SCRIPT
}

appvms = {
  app1vm01 = {
    name              = "app1-vm01"
    avzone            = "3"
    vnet_key          = "app1"
    subnet_key        = "web"
    load_balancer_key = "app1"
  }
}
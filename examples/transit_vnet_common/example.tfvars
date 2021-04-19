location = "East US 2"

# Priority map of security rules for your management IP addresses.
# Each key is the public IP, and the number is the priority it gets in the relevant network security groups (NSGs).
management_ips = {
  "199.199.199.199" : 100,
}

public_frontend_ips = {
  pip-existing = {
    create_public_ip = true
    rules = {
      HTTP = {
        port         = 80
        protocol     = "Tcp"
        backend_name = "backend1_name"
      }
    }
  }
}

private_frontend_ips = {
  internal_fe = {
    subnet_id                     = ""
    private_ip_address_allocation = "Dynamic" // Dynamic or Static
    private_ip_address            = ""
    rules = {
      HA_PORTS = {
        port         = 0
        protocol     = "All"
        backend_name = "backend3_name"
      }
    }
  }
}

vmseries = {
  "fw00" = { avzone = 1 }
  "fw01" = { avzone = 2 }
}

common_vmseries_version = "9.1.3"
common_vmseries_sku     = "bundle1"
storage_account_name    = "pantfstorage"
storage_share_name      = "ibbootstrapshare"

files = {
  "files/authcodes.sample"    = "license/authcodes"
  "files/init-cfg.sample.txt" = "config/init-cfg.txt"
}

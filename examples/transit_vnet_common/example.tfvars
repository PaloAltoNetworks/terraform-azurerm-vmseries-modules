location = "East US 2"

# Priority map of security rules for your management IP addresses.
# Each key is the public IP, and the number is the priority it gets in the relevant network security groups (NSGs).
management_ips = {
  "199.199.199.199" : 100,
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

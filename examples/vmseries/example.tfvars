location            = "Australia East"
resource_group_name = "example-rg"
common_vmseries_sku = "bundle1"
username            = "panadmin"
allow_inbound_mgmt_ips = [
  "191.191.191.191", # Put your own public IP address here, visit "https://ifconfig.me/"
  "10.255.0.0/24",   # Example Panorama access
]

vm_series_version = "10.1.5"

storage_account_name = "pantfstoragep"
storage_share_name   = "ibootstrapshare"
storage_acl          = false

files = {
  "files/authcodes"    = "license/authcodes" # authcode is required only with common_vmseries_sku = "byol"
  "files/init-cfg.txt" = "config/init-cfg.txt"
}

avzones = ["1", "2", "3"]
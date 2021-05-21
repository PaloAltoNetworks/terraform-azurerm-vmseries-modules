location            = "Australia East"
resource_group_name = "example-rg"
common_vmseries_sku = "bundle1"
username            = "panadmin"
allow_inbound_mgmt_ips = [
  "191.191.191.191", # Put your own public IP address here, visit "https://ifconfig.me/"
  "10.255.0.0/24",   # Example Panorama access
]

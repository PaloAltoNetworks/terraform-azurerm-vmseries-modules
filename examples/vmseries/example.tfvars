location            = "East US 2"
resource_group_name = "example-rg"
common_vmseries_sku = "bundle1"
username            = "panadmin"
allow_inbound_mgmt_ips = [
  "191.191.191.191", # Put your own public IP address here
  "10.255.0.0/24",   # Example Panorama access
  "208.184.44.128/27", "96.92.92.64/28", "84.207.227.0/28", "84.207.230.24/29", "213.208.209.160/30", "182.74.171.144/29",
  # "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16",
]


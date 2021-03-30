management_ips = {
  "199.199.199.199" : 100,
}

tags                = {}
vnet_name           = "example-vnet"
resource_group_name = "example-rg"
location            = "East US"
files = {
  "files/authcodes.sample"    = "license/authcodes"
  "files/init-cfg.sample.txt" = "config/init-cfg.txt"
}
resource_group_name  = "example-rg"
location             = "East US"
storage_account_name = "examplebootstrap"

files = {
  "files/authcodes.sample"    = "license/authcodes"
  "files/init-cfg.sample.txt" = "config/init-cfg.txt"
}

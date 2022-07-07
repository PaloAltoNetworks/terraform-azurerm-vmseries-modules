resource_group_name        = "example-rg"
location                   = "West US"
storage_account_name       = "examplebootstrap"
inbound_storage_share_name = "inboundbootstrap"
obew_storage_share_name    = "obewbootstrap"

inbound_files = {
  "inbound_files/authcodes.sample"    = "license/authcodes"
  "inbound_files/init-cfg.sample.txt" = "config/init-cfg.txt"
}

obew_files = {
  "obew_files/authcodes.sample"    = "license/authcodes"
  "obew_files/init-cfg.sample.txt" = "config/init-cfg.txt"
}

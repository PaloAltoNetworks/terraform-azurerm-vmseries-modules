# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "bootstrap-refactor"
name_prefix         = "fosix-"
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}

bootstrap_storages = {
  "empty-storage" = {
    name = "fosixemptystorage"
  }
  "bootstrap-storage" = {
    name = "fosixbootstrapstorage"
    file_shares_configuration = {
      access_tier = "Hot"
      quota       = 20
    }
    file_shares = {
      "vm01" = {
        name                   = "vm01"
        bootstrap_package_path = "bootstrap_package"
        bootstrap_files = {
          "files/init-cfg.txt"         = "config/init-cfg.txt"
          "files/nested/bootstrap.xml" = "config/bootstrap.xml"
        }
      }
      "vm02" = {
        name                   = "vm02"
        bootstrap_package_path = "./bootstrap_package/"
        quota                  = 1
      }
      "vm03" = {
        name        = "vm03"
        access_tier = "Cool"
        bootstrap_files = {
          "files/init-cfg.txt" = "config/init-cfg.txt"
        }
      }
    }
  }
  "secured-storage" = {
    name = "fosixsecurestorage"
    storage_network_security = {
      min_tls_version    = "TLS1_1"
      allowed_public_ips = ["134.238.135.14", "134.238.135.140"]
    }
    file_shares = {
      share = {
        name = "a-share"
      }
    }
  }
}
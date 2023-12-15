# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "bootstrap-refactor"
name_prefix         = "fosix-"
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}

# bootstrap_storages = {
#   "empty-storage" = {
#     name = "emptystorage"
#   }
#   "bootstrap-storage" = {
#     name = "bootstrapstorage"
#     file_shares_configuration = {
#       access_tier = "Hot"
#       quota       = 20
#     }
#     storage_network_security = {
#       min_tls_version    = "TLS1_1"
#       allowed_public_ips = ["134.238.135.14", "134.238.135.140"]
#     }
#     file_shares = {
#       "vm01" = {
#         name                   = "vm01"
#         bootstrap_package_path = "bootstrap_package"
#         bootstrap_files = {
#           "files/init-cfg.txt"         = "config/init-cfg.txt"
#           "files/nested/bootstrap.xml" = "config/bootstrap.xml"
#         }
#       }
#       "vm02" = {
#         name                   = "vm02"
#         bootstrap_package_path = "./bootstrap_package/"
#         quota                  = 1
#       }
#       "vm03" = {
#         name        = "vm03"
#         access_tier = "Cool"
#         bootstrap_files = {
#           "files/init-cfg.txt" = "config/init-cfg.txt"
#         }
#       }
#     }
#   }
#   "existing-storage" = {
#     name                   = "existingstorage"
#     create_storage_account = false
#     file_shares_configuration = {
#       create_file_shares            = false
#       disable_package_dirs_creation = true
#     }
#     file_shares = {
#       existing_share = {
#         name                   = "bootstrap"
#         bootstrap_package_path = "bootstrap_package"
#       }
#     }
#   }
# }
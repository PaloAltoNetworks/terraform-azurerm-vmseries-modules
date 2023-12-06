# output "bootstrap_storage_urls" {
#   value     = length(var.bootstrap_storage) > 0 ? { for k, v in module.bootstrap_share : k => v.storage_share.url } : null
#   sensitive = true
# }
# Setup all the networks required for the topology
module "net_panorama" {
  source = "../../modules/networking-panorama"

  location       = var.location
  management_ips = var.management_ips
  name_prefix    = var.name_prefix
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

module "panorama" {
  source = "../../modules/panorama"

  location    = var.location
  name_prefix = var.name_prefix
  subnet_mgmt = module.net_panorama.panorama_mgmt_subnet
  password    = random_password.password.result
}

output "panorama_url" {
  value = "https://${module.panorama.panorama-publicip}"
}

output "panorama_admin_password" {
  value = random_password.password.result
}

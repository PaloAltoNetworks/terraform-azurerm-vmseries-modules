output "panorama_url" {
  description = "Panorama instance URL."
  value       = "https://${module.panorama.mgmt_ip_address}"
}

output "panorama_admin_password" {
  description = "Panorama administrator's initial password."
  value       = random_password.this.result
}

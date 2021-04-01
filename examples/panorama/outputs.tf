output "panorama_url" {
  description = "Panorama instance URL."
  value       = "https://${module.panorama.panorama-publicips[0]}"
}

output "panorama_admin_password" {
  description = "Panorama administrator's initial password."
  value       = random_password.this.result
}

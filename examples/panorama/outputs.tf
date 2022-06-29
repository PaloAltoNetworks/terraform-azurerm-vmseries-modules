output "panorama_url" {
  description = "Panorama instance URL."
  value       = "https://${module.panorama.mgmt_ip_address}"
}

output "password" {
  description = "Panorama administrator's initial password."
  value       = random_password.this.result
  sensitive   = true
}

output "username" {
  description = "Panorama administrator's initial username."
  value       = var.username
}

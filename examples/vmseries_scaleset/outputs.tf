output "USERNAME" {
  description = "PAN Device username"
  value       = var.username
}

output "PASSWORD" {
  description = "PAN Device password"
  value       = random_password.this.result
}

output "PANORAMA-IP" {
  description = "The Public IP address of Panorama."
  value       = module.panorama.panorama-publicip
}

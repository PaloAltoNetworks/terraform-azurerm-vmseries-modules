output "USERNAME" {
  description = "PAN Device username"
  value       = var.username
}

output "PASSWORD" {
  description = "PAN Device password"
  value       = random_password.password
}

output "PANORAMA-IP" {
  description = "The Public IP address of Panorama."
  value = module.panorama.panorama-publicip
}
output "username" {
  description = "PAN Device username"
  value       = var.username
}

output "password" {
  description = "PAN Device password"
  value       = random_password.password.result
}

output "panorama_ip" {
  description = "The Public IP address of Panorama."
  value       = module.panorama.panorama-publicip
}

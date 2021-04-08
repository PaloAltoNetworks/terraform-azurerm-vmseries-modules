output "USERNAME" {
  description = "PAN Device username"
  value       = var.username
}

output "PASSWORD" {
  description = "PAN Device password"
  value       = random_password.this.result
}

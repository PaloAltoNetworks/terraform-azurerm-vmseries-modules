terraform {}

variable "time" {
  description = "The time value in minutes to be converted to string representation."
  type        = number
}

locals {
  minutes   = "${var.time % 60}M"
  hours     = "${floor(var.time / 60) % 24}H"
  days      = "${floor(var.time / (60 * 24))}D"
  t_string  = "T${local.hours != "0H" ? local.hours : ""}${local.minutes != "0M" ? local.minutes : ""}"
  dt_string = "P${local.days != "0D" ? local.days : ""}${local.t_string != "T" ? local.t_string : ""}"
}

output "dt_string" {
  description = "Azure string time representation."
  value       = local.dt_string
}
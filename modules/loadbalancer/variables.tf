variable "loadbalancer" {
  description = "Definition of the loadbalancers"
  default = []
}

variable "lbsku" {
  default = "Standard"
}

variable "load_distribution" {
  default = "SourceIPProtocol"
}

variable "idle_timeout" {
  default = 5
}

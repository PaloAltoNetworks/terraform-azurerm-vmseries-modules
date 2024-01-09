terraform {
  required_version = ">= 1.5, < 2.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

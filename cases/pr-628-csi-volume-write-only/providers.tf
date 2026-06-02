terraform {
  required_version = ">= 1.11.0"

  required_providers {
    nomad = {
      source = "hashicorp/nomad"
    }
  }
}

provider "nomad" {}

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    nomad = {
      source = "hashicorp/nomad"
    }
  }
}

data "terraform_remote_state" "bootstrap" {
  backend = "local"

  config = {
    path = "../../bootstrap/terraform.tfstate"
  }
}

provider "nomad" {
  secret_id = data.terraform_remote_state.bootstrap.outputs.token_secret_id
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    nomad = {
      source = "hashicorp/nomad"
    }
  }
}

provider "nomad" {}

variable "token_names" {
  description = "Existing Nomad ACL token name to reuse for Terraform test cases."
  type        = string
  default     = "tf-provider-testing"
}

data "nomad_acl_tokens" "all" {}

locals {
  accessor_id = one([
    for token in data.nomad_acl_tokens.all.acl_tokens :
    token.accessor_id if token.name == var.token_names
  ])
}

data "nomad_acl_token" "case" {
  accessor_id = local.accessor_id
}

output "token_accessor_id" {
  value = data.nomad_acl_token.case.accessor_id
}

output "token_secret_id" {
  value     = data.nomad_acl_token.case.secret_id
  sensitive = true
}

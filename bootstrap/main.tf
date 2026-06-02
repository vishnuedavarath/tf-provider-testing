terraform {
  required_version = ">= 1.5.0"

  required_providers {
    nomad = {
      source = "hashicorp/nomad"
    }
  }
}

provider "nomad" {}

variable "bootstrap_token_secret_id" {
  description = "Optional Nomad ACL token secret to reuse directly instead of resolving a token by name."
  type        = string
  default     = null
  sensitive   = true
}

variable "token_name" {
  description = "Name for the Nomad ACL token used by test cases. Will be created if it doesn't exist."
  type        = string
  default     = "tf-provider-testing"
}

# ---------------------------------------------------------------------------
# Look up existing tokens to see if one with our name already exists
# ---------------------------------------------------------------------------

data "nomad_acl_tokens" "all" {
  count = nonsensitive(var.bootstrap_token_secret_id) == null ? 1 : 0
}

locals {
  # Find any existing token matching the desired name
  matching_accessor_ids = nonsensitive(var.bootstrap_token_secret_id) == null ? [
    for token in data.nomad_acl_tokens.all[0].acl_tokens :
    token.accessor_id if token.name == var.token_name
  ] : []

  token_exists = length(local.matching_accessor_ids) > 0
}

# Read existing token details if one was found
data "nomad_acl_token" "existing" {
  count       = nonsensitive(var.bootstrap_token_secret_id) == null && local.token_exists ? 1 : 0
  accessor_id = local.matching_accessor_ids[0]
}

# ---------------------------------------------------------------------------
# Create a management token if one doesn't already exist
# ---------------------------------------------------------------------------

resource "nomad_acl_token" "testing" {
  count = nonsensitive(var.bootstrap_token_secret_id) == null && !local.token_exists ? 1 : 0

  name = var.token_name
  type = "management"
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

locals {
  # Resolve the final token values from whichever source is available:
  # 1. Explicit secret_id passed via variable
  # 2. Pre-existing token found by name
  # 3. Newly created management token
  resolved_accessor_id = (
    nonsensitive(var.bootstrap_token_secret_id) != null ? null :
    local.token_exists ? data.nomad_acl_token.existing[0].accessor_id :
    nomad_acl_token.testing[0].accessor_id
  )

  resolved_secret_id = (
    nonsensitive(var.bootstrap_token_secret_id) != null ? var.bootstrap_token_secret_id :
    local.token_exists ? data.nomad_acl_token.existing[0].secret_id :
    nomad_acl_token.testing[0].secret_id
  )
}

output "token_accessor_id" {
  value = local.resolved_accessor_id
}

output "token_secret_id" {
  value     = local.resolved_secret_id
  sensitive = true
}

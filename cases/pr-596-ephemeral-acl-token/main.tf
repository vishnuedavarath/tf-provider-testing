resource "nomad_acl_policy" "ephemeral" {
  name        = var.policy_name
  description = "ACL policy used by the PR 596 ephemeral ACL token case."
  rules_hcl   = <<-EOT
    namespace "default" {
      policy       = "read"
      capabilities = ["submit-job"]
    }
  EOT
}

resource "nomad_acl_role" "ephemeral" {
  name        = var.role_name
  description = "ACL role used by the PR 596 ephemeral ACL token case."

  policy {
    name = nomad_acl_policy.ephemeral.name
  }
}

resource "nomad_acl_token" "ephemeral" {
  name           = var.token_name
  type           = "client"
  policies       = [nomad_acl_policy.ephemeral.name]
  expiration_ttl = var.expiration_ttl

  role {
    id = nomad_acl_role.ephemeral.id
  }
}

ephemeral "nomad_acl_token" "ephemeral" {
  accessor_id = nomad_acl_token.ephemeral.accessor_id
}

locals {
  ephemeral_role_ids   = toset([for role in ephemeral.nomad_acl_token.ephemeral.roles : role.id])
  ephemeral_role_names = toset([for role in ephemeral.nomad_acl_token.ephemeral.roles : role.name])
}

resource "terraform_data" "ephemeral_token_files" {
  triggers_replace = [
    nomad_acl_token.ephemeral.accessor_id,
    var.expiration_ttl,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      cat > "$SUMMARY_FILE" <<EOF
      {
        "accessor_id": "$ACCESSOR_ID",
        "name": "$TOKEN_NAME",
        "type": "$TOKEN_TYPE",
        "global": $TOKEN_GLOBAL,
        "expiration_ttl": "$EXPIRATION_TTL",
        "policies": $POLICIES,
        "roles": $ROLES,
        "secret_id_length": $SECRET_ID_LENGTH
      }
      EOF
      printf '%s\n' "$TOKEN_SECRET_ID" > "$SECRET_FILE"
    EOT

    environment = {
      SUMMARY_FILE   = "${path.module}/ephemeral_acl_token_summary.json"
      SECRET_FILE    = "${path.module}/ephemeral_acl_token.secret_id"
      ACCESSOR_ID    = ephemeral.nomad_acl_token.ephemeral.accessor_id
      TOKEN_NAME     = ephemeral.nomad_acl_token.ephemeral.name
      TOKEN_TYPE     = ephemeral.nomad_acl_token.ephemeral.type
      TOKEN_GLOBAL   = jsonencode(ephemeral.nomad_acl_token.ephemeral.global)
      EXPIRATION_TTL = ephemeral.nomad_acl_token.ephemeral.expiration_ttl
      POLICIES       = jsonencode(sort(tolist(ephemeral.nomad_acl_token.ephemeral.policies)))
      ROLES = jsonencode([for role in ephemeral.nomad_acl_token.ephemeral.roles : {
        id   = role.id
        name = role.name
      }])
      TOKEN_SECRET_ID  = ephemeral.nomad_acl_token.ephemeral.secret_id
      SECRET_ID_LENGTH = tostring(length(nonsensitive(ephemeral.nomad_acl_token.ephemeral.secret_id)))
    }
  }
}

check "ephemeral_acl_token_round_trip" {
  assert {
    condition     = ephemeral.nomad_acl_token.ephemeral.accessor_id == nomad_acl_token.ephemeral.accessor_id
    error_message = "Expected the ephemeral ACL token lookup to return the accessor ID from the managed ACL token resource."
  }

  assert {
    condition     = length(nonsensitive(ephemeral.nomad_acl_token.ephemeral.secret_id)) > 10
    error_message = "Expected the ephemeral ACL token lookup to return a non-empty secret_id."
  }

  assert {
    condition     = ephemeral.nomad_acl_token.ephemeral.name == var.token_name && ephemeral.nomad_acl_token.ephemeral.type == "client"
    error_message = "Expected the ephemeral ACL token lookup to expose the created token name and type."
  }

  assert {
    condition     = contains(ephemeral.nomad_acl_token.ephemeral.policies, nomad_acl_policy.ephemeral.name)
    error_message = "Expected the ephemeral ACL token lookup to expose the attached ACL policy name."
  }

  assert {
    condition     = contains(local.ephemeral_role_ids, nomad_acl_role.ephemeral.id) && contains(local.ephemeral_role_names, nomad_acl_role.ephemeral.name)
    error_message = "Expected the ephemeral ACL token lookup to expose the attached ACL role metadata."
  }

  assert {
    condition     = ephemeral.nomad_acl_token.ephemeral.expiration_ttl == var.expiration_ttl && ephemeral.nomad_acl_token.ephemeral.create_time != "" && ephemeral.nomad_acl_token.ephemeral.expiration_time != ""
    error_message = "Expected the ephemeral ACL token lookup to expose create_time, expiration_ttl, and expiration_time."
  }
}

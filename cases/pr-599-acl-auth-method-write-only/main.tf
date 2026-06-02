resource "tls_private_key" "client_assertion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "client_assertion" {
  private_key_pem = tls_private_key.client_assertion.private_key_pem

  subject {
    common_name  = "nomadproject.io"
    organization = "HashiCorp"
  }

  validity_period_hours = 1
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

data "external" "runtime_env" {
  program = [
    "sh",
    "-c",
    "printf '{\"nomad_addr\":\"%s\"}' \"$NOMAD_ADDR\"",
  ]
}

locals {
  nomad_api_address            = trimspace(coalesce(var.nomad_address, try(data.external.runtime_env.result.nomad_addr, "")))
  nomad_ui_base_address        = trimspace(coalesce(var.nomad_ui_address, local.nomad_api_address))
  nomad_ui_settings_tokens_uri = "${trimsuffix(local.nomad_ui_base_address, "/")}/ui/settings/tokens"
}

resource "nomad_acl_auth_method" "write_only" {
  name              = var.auth_method_name
  type              = "OIDC"
  token_locality    = "global"
  token_name_format = "$${auth_method_type}-$${value.email}"
  max_token_ttl     = "8h"
  default           = true

  config {
    oidc_discovery_url            = var.dex_issuer_url
    oidc_client_id                = var.dex_client_id
    oidc_client_secret_wo         = var.client_secret
    oidc_client_secret_wo_version = var.client_secret_version
    oidc_disable_userinfo         = true
    oidc_enable_pkce              = true
    oidc_scopes                   = ["openid", "profile", "email"]
    bound_audiences               = [var.dex_client_id]
    allowed_redirect_uris = [
      "http://localhost:4649/oidc/callback",
      local.nomad_ui_settings_tokens_uri,
    ]
    claim_mappings = {
      email              = "email"
      preferred_username = "username"
    }
    list_claim_mappings = {
      groups = "groups"
    }
  }
}

resource "nomad_acl_binding_rule" "role" {
  description = var.role_binding_rule_description
  auth_method = nomad_acl_auth_method.write_only.name
  selector    = "engineering in list.roles"
  bind_type   = "role"
  bind_name   = var.role_binding_rule_name
}

resource "nomad_acl_binding_rule" "management" {
  description = var.management_binding_rule_description
  auth_method = nomad_acl_auth_method.write_only.name
  selector    = "value.email == \"${var.oidc_admin_email}\""
  bind_type   = "management"
}

resource "terraform_data" "summary_file" {
  triggers_replace = [
    nomad_acl_auth_method.write_only.id,
    nomad_acl_binding_rule.role.id,
    nomad_acl_binding_rule.management.id,
    tostring(var.client_secret_version),
    tostring(var.private_key_version),
  ]

  provisioner "local-exec" {
    command = <<-EOT
      cat > "$SUMMARY_FILE" <<EOF
      {
        "auth_method_name": "$AUTH_METHOD_NAME",
        "role_binding_rule_id": "$ROLE_BINDING_RULE_ID",
        "management_binding_rule_id": "$MANAGEMENT_BINDING_RULE_ID",
        "role_binding_name": "$ROLE_BINDING_NAME",
        "client_secret_version": $CLIENT_SECRET_VERSION,
        "private_key_version": $PRIVATE_KEY_VERSION,
        "client_secret_persisted_in_state": $CLIENT_SECRET_PERSISTED,
        "pkce_enabled": $PKCE_ENABLED,
        "scopes": $OIDC_SCOPES,
        "management_bind_name_is_empty": $MANAGEMENT_BIND_NAME_EMPTY
      }
      EOF
    EOT

    environment = {
      SUMMARY_FILE                = "${path.module}/auth_method_write_only_summary.json"
      AUTH_METHOD_NAME            = nomad_acl_auth_method.write_only.name
      ROLE_BINDING_RULE_ID        = nomad_acl_binding_rule.role.id
      MANAGEMENT_BINDING_RULE_ID  = nomad_acl_binding_rule.management.id
      ROLE_BINDING_NAME           = nomad_acl_binding_rule.role.bind_name
      CLIENT_SECRET_VERSION       = tostring(var.client_secret_version)
      PRIVATE_KEY_VERSION         = tostring(var.private_key_version)
      CLIENT_SECRET_PERSISTED     = jsonencode(try(nomad_acl_auth_method.write_only.config.oidc_client_secret, null) != null)
      PKCE_ENABLED                = jsonencode(try(nomad_acl_auth_method.write_only.config.oidc_enable_pkce, false))
      OIDC_SCOPES                 = jsonencode(try(nomad_acl_auth_method.write_only.config.oidc_scopes, []))
      MANAGEMENT_BIND_NAME_EMPTY  = jsonencode(try(nomad_acl_binding_rule.management.bind_name, "") == "")
    }
  }
}

check "write_only_auth_method_state" {
  assert {
    condition     = nomad_acl_auth_method.write_only.name == var.auth_method_name
    error_message = "Expected the write-only ACL auth method resource to retain the configured name."
  }

  assert {
    condition     = try(nomad_acl_auth_method.write_only.config.oidc_client_secret, null) == null
    error_message = "Expected config.oidc_client_secret to remain absent from state when oidc_client_secret_wo is used."
  }

  assert {
    condition     = nomad_acl_auth_method.write_only.config.oidc_discovery_url == var.dex_issuer_url
    error_message = "Expected the auth method to use the configured local Dex issuer URL."
  }

  assert {
    condition     = nomad_acl_auth_method.write_only.config.oidc_client_id == var.dex_client_id
    error_message = "Expected the auth method to keep the configured Dex client ID."
  }

  assert {
    condition     = try(nomad_acl_auth_method.write_only.config.oidc_enable_pkce, false) && try(nomad_acl_auth_method.write_only.config.oidc_disable_userinfo, false)
    error_message = "Expected the auth method to enable PKCE and disable UserInfo for the local Dex setup."
  }
}

check "binding_rules_reference_auth_method" {
  assert {
    condition     = nomad_acl_binding_rule.role.auth_method == nomad_acl_auth_method.write_only.name
    error_message = "Expected the role binding rule to target the write-only ACL auth method."
  }

  assert {
    condition     = nomad_acl_binding_rule.role.bind_name == var.role_binding_rule_name
    error_message = "Expected the role binding rule to retain the configured bind_name."
  }

  assert {
    condition     = nomad_acl_binding_rule.management.auth_method == nomad_acl_auth_method.write_only.name
    error_message = "Expected the management binding rule to target the write-only ACL auth method."
  }

  assert {
    condition     = nomad_acl_binding_rule.management.selector == "value.email == \"${var.oidc_admin_email}\""
    error_message = "Expected the management binding rule to grant access to the configured Dex admin email."
  }

  assert {
    condition     = try(nomad_acl_binding_rule.management.bind_name, "") == ""
    error_message = "Expected the management binding rule to keep bind_name unset."
  }
}
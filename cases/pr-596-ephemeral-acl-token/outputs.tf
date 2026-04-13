output "ephemeral_acl_token_artifacts" {
  description = "Artifacts written from the PR 596 ephemeral ACL token lookup during apply."
  value = {
    accessor_id       = nomad_acl_token.ephemeral.accessor_id
    token_name        = var.token_name
    policy_name       = nomad_acl_policy.ephemeral.name
    role_id           = nomad_acl_role.ephemeral.id
    role_name         = nomad_acl_role.ephemeral.name
    expiration_ttl    = var.expiration_ttl
    secret_file_path  = "${path.module}/ephemeral_acl_token.secret_id"
    summary_file_path = "${path.module}/ephemeral_acl_token_summary.json"
  }
}

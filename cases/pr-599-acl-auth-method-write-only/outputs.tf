output "acl_auth_method_write_only_metadata" {
  description = "Metadata for the PR 599 write-only ACL auth method case."
  value = {
    auth_method_name               = nomad_acl_auth_method.write_only.name
    role_binding_rule_id           = nomad_acl_binding_rule.role.id
    management_binding_rule_id     = nomad_acl_binding_rule.management.id
    role_binding_rule_name         = nomad_acl_binding_rule.role.bind_name
    client_secret_version          = var.client_secret_version
    private_key_version            = var.private_key_version
    summary_file_path              = "${path.module}/auth_method_write_only_summary.json"
  }
}
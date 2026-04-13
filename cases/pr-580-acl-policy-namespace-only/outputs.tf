output "namespace_only_policy" {
  value = {
    id          = nomad_acl_policy.namespace_only.id
    name        = nomad_acl_policy.namespace_only.name
    description = nomad_acl_policy.namespace_only.description
    rules_hcl   = nomad_acl_policy.namespace_only.rules_hcl
    job_acl     = nomad_acl_policy.namespace_only.job_acl[0]
    api_rules   = data.nomad_acl_policy.namespace_only.rules
  }
}

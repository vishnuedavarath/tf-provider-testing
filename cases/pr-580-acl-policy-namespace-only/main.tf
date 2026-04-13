locals {
  policy_rules_hcl = <<-EOT
    namespace "default" {
      policy       = "read"
      capabilities = ["submit-job"]
    }
  EOT
}

resource "nomad_acl_policy" "namespace_only" {
  name        = var.policy_name
  description = "PR 580 namespace-only job_acl coverage"
  rules_hcl   = local.policy_rules_hcl

  job_acl {
    namespace = "default"
  }
}

data "nomad_acl_policy" "namespace_only" {
  name = nomad_acl_policy.namespace_only.name
}

check "namespace_only_job_acl" {
  assert {
    condition     = nomad_acl_policy.namespace_only.job_acl[0].namespace == "default"
    error_message = "Expected job_acl namespace to be default."
  }

  assert {
    condition     = nomad_acl_policy.namespace_only.job_acl[0].job_id == ""
    error_message = "Expected job_acl job_id to remain empty for namespace-wide policy application."
  }

  assert {
    condition     = data.nomad_acl_policy.namespace_only.rules == local.policy_rules_hcl
    error_message = "Expected ACL policy rules read back from Nomad to match the configured rules_hcl."
  }
}

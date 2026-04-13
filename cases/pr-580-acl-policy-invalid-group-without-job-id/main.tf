resource "nomad_acl_policy" "invalid_group_dependency" {
  name        = "pr-580-invalid-group-without-job-id"
  description = "PR 580 validation coverage: group requires job_id"
  rules_hcl   = <<-EOT
    namespace "default" {
      policy = "read"
    }
  EOT

  job_acl {
    namespace = "default"
    group     = "web"
  }
}

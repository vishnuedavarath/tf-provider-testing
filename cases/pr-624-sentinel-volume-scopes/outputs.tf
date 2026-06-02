output "submit_job_policy_name" {
  description = "Name of the submit-job scoped policy."
  value       = nomad_sentinel_policy.submit_job.name
}

output "submit_host_volume_policy_name" {
  description = "Name of the submit-host-volume scoped policy."
  value       = nomad_sentinel_policy.submit_host_volume.name
}

output "submit_csi_volume_policy_name" {
  description = "Name of the submit-csi-volume scoped policy."
  value       = nomad_sentinel_policy.submit_csi_volume.name
}

output "all_scopes" {
  description = "All scopes that were successfully created."
  value = [
    nomad_sentinel_policy.submit_job.scope,
    nomad_sentinel_policy.submit_host_volume.scope,
    nomad_sentinel_policy.submit_csi_volume.scope,
  ]
}

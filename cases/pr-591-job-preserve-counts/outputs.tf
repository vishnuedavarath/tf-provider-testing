output "preserve_counts_summary" {
  description = "Summary of the PR 591 preserve_counts test case after the current apply."
  value = {
    job_id                    = nomad_job.preserve_counts.id
    group_name                = local.resource_group.name
    preserve_counts           = var.preserve_counts
    scale_live_group_count    = var.scale_live_group_count
    priority                  = nomad_job.preserve_counts.priority
    expected_task_group_count = local.expected_task_group_count
    resource_task_group_count = local.resource_group.count
    data_task_group_count     = local.data_group.count
  }
}

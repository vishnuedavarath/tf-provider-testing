output "service_effective_update_summary" {
  description = "Summary of the PR 585 task group update_strategy fields exposed on the nomad_job resource and data source."
  value = {
    resource = {
      job_id          = nomad_job.service_effective_update.id
      update_strategy = nomad_job.service_effective_update.update_strategy[0]
      task_group      = local.service_resource_group_update
    }
    data_source = {
      job_id          = data.nomad_job.service_effective_update.id
      update_strategy = data.nomad_job.service_effective_update.update_strategy[0]
      task_group      = local.service_data_group_update
    }
  }
}

output "periodic_config_summary" {
  description = "Summary of the PR 585 periodic_config fields exposed on the nomad_job resource and data source."
  value = {
    resource    = local.periodic_resource_config
    data_source = local.periodic_data_config
  }
}

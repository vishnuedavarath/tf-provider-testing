output "parsed_job_summary" {
  description = "Selected values from the parsed job JSON after applying HCL2 variables."
  value = {
    id          = local.parsed_job.ID
    datacenters = local.parsed_job.Datacenters
    group_name  = local.parsed_job.TaskGroups[0].Name
    task_name   = local.first_task.Name
    image       = local.first_task.Config.image
    cpu         = local.first_task.Resources.CPU
    memory_mb   = local.first_task.Resources.MemoryMB
  }
}

output "parsed_job_json" {
  description = "Full JSON returned by nomad_job_parser."
  value       = data.nomad_job_parser.with_variables.json
}

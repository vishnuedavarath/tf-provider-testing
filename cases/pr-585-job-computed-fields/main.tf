resource "nomad_job" "service_effective_update" {
  # detach           = true
  purge_on_destroy = true

  jobspec = <<-EOT
    job "pr585-service-effective-update" {
      datacenters = ["dc1"]
      type        = "service"

      update {
        stagger           = "30s"
        max_parallel      = 3
        health_check      = "checks"
        min_healthy_time  = "11s"
        healthy_deadline  = "6m"
        progress_deadline = "11m"
        auto_revert       = true
        auto_promote      = true
        canary            = 2
      }

      group "api" {
        update {
          min_healthy_time  = "12s"
          progress_deadline = "12m"
        }

        task "server" {
          driver = "raw_exec"

          config {
            command = "/bin/sleep"
            args    = ["60"]
          }

          resources {
            cpu    = 100
            memory = 64
          }

          logs {
            max_files     = 1
            max_file_size = 1
          }
        }
      }
    }
  EOT
}

data "nomad_job" "service_effective_update" {
  job_id = nomad_job.service_effective_update.id
}

resource "nomad_job" "periodic_config" {
  purge_on_destroy = true

  jobspec = <<-EOT
    job "pr585-periodic-config" {
      datacenters = ["dc1"]
      type        = "batch"

      periodic {
        cron             = "*/10 * * * * *"
        prohibit_overlap = true
        time_zone        = "UTC"
      }

      group "runner" {
        task "echo" {
          driver = "raw_exec"

          config {
            command = "/bin/echo"
            args    = ["pr-585"]
          }

          resources {
            cpu    = 100
            memory = 32
          }

          logs {
            max_files     = 1
            max_file_size = 1
          }
        }
      }
    }
  EOT
}

data "nomad_job" "periodic_config" {
  job_id = nomad_job.periodic_config.id
}

locals {
  service_resource_group_update = one(nomad_job.service_effective_update.task_groups).update_strategy[0]
  service_data_group_update     = one(data.nomad_job.service_effective_update.task_groups).update_strategy[0]

  periodic_resource_config = one(nomad_job.periodic_config.periodic_config)
  periodic_data_config     = one(data.nomad_job.periodic_config.periodic_config)
}

check "service_job_task_group_update_strategy_is_exposed" {
  assert {
    condition     = nomad_job.service_effective_update.update_strategy[0].max_parallel == 2
    error_message = "Expected job-level update_strategy to be exposed on the nomad_job resource."
  }

  assert {
    condition     = local.service_resource_group_update.stagger == "30s"
    error_message = "Expected task group update_strategy to inherit stagger from the job-level update block."
  }

  assert {
    condition     = local.service_resource_group_update.max_parallel == 2
    error_message = "Expected task group update_strategy to inherit max_parallel from the job-level update block."
  }

  assert {
    condition     = local.service_resource_group_update.min_healthy_time == "12s"
    error_message = "Expected task group update_strategy to preserve task-group-specific min_healthy_time overrides."
  }

  assert {
    condition     = local.service_resource_group_update.healthy_deadline == "6m0s"
    error_message = "Expected task group update_strategy to inherit healthy_deadline from the job-level update block."
  }

  assert {
    condition     = local.service_resource_group_update.auto_revert
    error_message = "Expected task group update_strategy to expose inherited auto_revert and auto_promote values."
  }

  assert {
    condition     = local.service_resource_group_update.canary == 2
    error_message = "Expected task group update_strategy to expose the inherited canary value."
  }
}

check "service_job_data_source_update_strategy_is_exposed" {
  assert {
    condition     = data.nomad_job.service_effective_update.update_strategy[0].max_parallel == 2
    error_message = "Expected job-level update_strategy to be exposed on the nomad_job data source."
  }

  assert {
    condition     = local.service_data_group_update.stagger == "30s"
    error_message = "Expected task group update_strategy to be exposed on the nomad_job data source."
  }

  assert {
    condition     = local.service_data_group_update.min_healthy_time == "12s"
    error_message = "Expected data.nomad_job to expose effective task group update_strategy values."
  }

  assert {
    condition     = local.service_data_group_update.auto_revert && local.service_data_group_update.canary == 1
    error_message = "Expected data.nomad_job to expose inherited task group canary and auto-* values."
  }
}

check "periodic_config_is_exposed_on_resource_and_data_source" {
  assert {
    condition     = local.periodic_resource_config.enabled && local.periodic_data_config.enabled
    error_message = "Expected periodic_config.enabled to be exposed on both the resource and data source."
  }

  assert {
    condition     = local.periodic_resource_config.spec == "*/15 * * * * *" && local.periodic_data_config.spec == "*/15 * * * * *"
    error_message = "Expected periodic_config.spec to be exposed on both the resource and data source."
  }

  assert {
    condition     = local.periodic_resource_config.spec_type == "cron" && local.periodic_data_config.spec_type == "cron"
    error_message = "Expected periodic_config.spec_type to be exposed on both the resource and data source."
  }

  assert {
    condition     = local.periodic_resource_config.prohibit_overlap && local.periodic_data_config.prohibit_overlap
    error_message = "Expected periodic_config.prohibit_overlap to be exposed on both the resource and data source."
  }

  assert {
    condition     = local.periodic_resource_config.timezone == "UTC" && local.periodic_data_config.timezone == "UTC"
    error_message = "Expected periodic_config.timezone to be exposed on both the resource and data source."
  }
}

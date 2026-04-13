resource "terraform_data" "scale_live_group" {
  count = var.scale_live_group_count ? 1 : 0

  triggers_replace = {
    job_id           = var.job_id
    group_name       = var.group_name
    live_group_count = tostring(var.live_group_count)
  }

  provisioner "local-exec" {
    command = "nomad job scale -detach=false -verbose -count='${var.live_group_count}' '${var.job_id}' '${var.group_name}'"

    environment = {
      NOMAD_ADDR  = var.nomad_address
      NOMAD_TOKEN = nonsensitive(data.terraform_remote_state.bootstrap.outputs.token_secret_id)
    }
  }
}

resource "nomad_job" "preserve_counts" {
  depends_on = [terraform_data.scale_live_group]

  detach           = false
  purge_on_destroy = true
  preserve_counts  = var.preserve_counts

  jobspec = <<-EOT
    job "${var.job_id}" {
      datacenters = ["dc1"]
      type        = "service"
      priority    = ${var.priority}

      group "${var.group_name}" {
        count = 1

        task "server" {
          driver = "raw_exec"

          config {
            command = "/bin/sleep"
            args    = ["60"]
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

data "nomad_job" "preserve_counts" {
  job_id = nomad_job.preserve_counts.id
}

locals {
  expected_task_group_count = var.scale_live_group_count && var.preserve_counts ? var.live_group_count : 1

  resource_group = one(nomad_job.preserve_counts.task_groups)
  data_group     = one(data.nomad_job.preserve_counts.task_groups)
}

check "job_priority_update_applies" {
  assert {
    condition     = nomad_job.preserve_counts.priority == var.priority
    error_message = "Expected nomad_job.priority to reflect the configured update used by the PR 591 case."
  }

  assert {
    condition     = data.nomad_job.preserve_counts.priority == var.priority
    error_message = "Expected data.nomad_job.priority to reflect the configured update used by the PR 591 case."
  }
}

check "task_group_count_matches_expected_behavior" {
  assert {
    condition     = local.resource_group.count == local.expected_task_group_count
    error_message = "Expected the nomad_job resource task group count to match either the jobspec count or the preserved live count."
  }

  assert {
    condition     = local.data_group.count == local.expected_task_group_count
    error_message = "Expected the nomad_job data source task group count to match either the jobspec count or the preserved live count."
  }
}

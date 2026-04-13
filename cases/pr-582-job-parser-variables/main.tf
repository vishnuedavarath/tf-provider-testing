locals {
  jobspec_hcl = <<-EOT
    variable "datacenter" {
      type = string
    }

    variable "image" {
      type = string
    }

    job "example" {
      datacenters = [var.datacenter]

      group "cache" {
        task "redis" {
          driver = "docker"

          config {
            image = var.image
          }

          resources {
            cpu    = 500
            memory = 256
          }
        }
      }
    }
  EOT

  parser_variables = <<-EOT
    datacenter = "${var.datacenter}"
    image = "${var.image}"
  EOT
}

data "nomad_job_parser" "with_variables" {
  hcl       = local.jobspec_hcl
  variables = local.parser_variables
}

locals {
  parsed_job = jsondecode(data.nomad_job_parser.with_variables.json)
  first_task = local.parsed_job.TaskGroups[0].Tasks[0]
}

check "job_parser_variables_are_applied" {
  assert {
    condition     = local.parsed_job.ID == "example"
    error_message = "Expected parsed job ID to be example."
  }

  assert {
    condition     = local.parsed_job.Datacenters[0] == var.datacenter
    error_message = "Expected datacenter variable to be applied in parsed job JSON."
  }

  assert {
    condition     = local.first_task.Config.image == var.image
    error_message = "Expected image variable to be applied in parsed job JSON."
  }

  assert {
    condition     = local.first_task.Resources.CPU == 500 && local.first_task.Resources.MemoryMB == 256
    error_message = "Expected parser to preserve static task resource values."
  }
}

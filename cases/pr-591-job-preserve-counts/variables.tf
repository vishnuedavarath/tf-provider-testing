variable "job_id" {
  description = "Nomad job ID used by the PR 591 preserve_counts test case."
  type        = string
  default     = "pr591-preserve-counts"
}

variable "group_name" {
  description = "Task group name used by the PR 591 preserve_counts test case."
  type        = string
  default     = "api"
}

variable "nomad_address" {
  description = "Nomad API address used by the helper scale step in phase 2."
  type        = string
  default     = "http://127.0.0.1:4646"
}

variable "priority" {
  description = "Job priority used to force an update between phase 1 and phase 2."
  type        = number
  default     = 50
}

variable "preserve_counts" {
  description = "Whether nomad_job should preserve the live task group count during registration."
  type        = bool
  default     = false
}

variable "scale_live_group_count" {
  description = "Whether to scale the live task group out-of-band before the job update runs."
  type        = bool
  default     = false
}

variable "live_group_count" {
  description = "Live task group count set by the helper scale step in phase 2."
  type        = number
  default     = 3
}

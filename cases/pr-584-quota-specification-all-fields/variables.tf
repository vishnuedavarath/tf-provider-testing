variable "quota_name" {
  description = "Quota specification name for the PR 584 all-fields test case."
  type        = string
  default     = "pr-584-all-fields-quota"
}

variable "region" {
  description = "Nomad region for the quota limit block."
  type        = string
  default     = "global"
}

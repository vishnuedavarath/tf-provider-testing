variable "namespace" {
  description = "Nomad namespace where the CSI volume is managed."
  type        = string
  default     = "default"
}

variable "volume_id" {
  description = "CSI volume ID used by the PR 628 write-only case."
  type        = string
  default     = "pr-628-write-only-volume"
}

variable "volume_name" {
  description = "Display name for the CSI volume."
  type        = string
  default     = "pr-628-write-only-volume"
}

variable "plugin_id" {
  description = "CSI plugin ID. This plugin must be available in the target Nomad cluster."
  type        = string
  default     = "hostpath"
}

variable "capacity_min" {
  description = "Requested minimum capacity for the CSI volume."
  type        = string
  default     = "10MiB"
}

variable "secrets" {
  description = "Write-only CSI secrets map encoded into secrets_wo."
  type        = map(string)
  default = {
    access_key = "pr-628-access"
    secret_key = "pr-628-secret"
  }
  sensitive = true
}

variable "secrets_wo_version" {
  description = "Manual version marker for secrets_wo updates. Increment to force secret refreshes."
  type        = number
  default     = 1
}

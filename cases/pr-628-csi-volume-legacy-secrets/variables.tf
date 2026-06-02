variable "namespace" {
  description = "Nomad namespace where the CSI volume is managed."
  type        = string
  default     = "default"
}

variable "volume_id" {
  description = "CSI volume ID used by the PR 628 legacy secrets case."
  type        = string
  default     = "pr-628-legacy-secrets-volume"
}

variable "volume_name" {
  description = "Display name for the CSI volume."
  type        = string
  default     = "pr-628-legacy-secrets-volume"
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
  description = "Legacy secrets map (deprecated, stored in state)."
  type        = map(string)
  default = {
    access_key  = "pr-628-legacy-access"
    secret_key  = "pr-628-legacy-secret"
    test_secret = "pr-628-legacy-test"
  }
  sensitive = true
}

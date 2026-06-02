variable "namespace" {
  description = "Nomad namespace where the CSI volume registration is managed."
  type        = string
  default     = "default"
}

variable "volume_id" {
  description = "CSI volume ID used by the PR 628 legacy secrets case."
  type        = string
  default     = "pr-628-legacy-secrets-registration"
}

variable "volume_name" {
  description = "Display name for the registered CSI volume."
  type        = string
  default     = "pr-628-legacy-secrets-registration"
}

variable "plugin_id" {
  description = "CSI plugin ID. This plugin must be available in the target Nomad cluster."
  type        = string
  default     = "hostpath"
}

variable "external_id" {
  description = "External storage provider ID for registration mode."
  type        = string
  default     = "pr-628-legacy-external-id"
}

variable "capacity_min" {
  description = "Requested minimum capacity for the registered CSI volume."
  type        = string
  default     = "10MiB"
}

variable "secrets" {
  description = "Legacy secrets map (deprecated, stored in state)."
  type        = map(string)
  default = {
    access_key = "pr-628-legacy-access"
    secret_key = "pr-628-legacy-secret"
  }
  sensitive = true
}

variable "deregister_on_destroy" {
  description = "Whether to deregister the CSI volume when this Terraform resource is destroyed."
  type        = bool
  default     = true
}

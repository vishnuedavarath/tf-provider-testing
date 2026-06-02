variable "namespace" {
  description = "Nomad namespace where the CSI volume registration is managed."
  type        = string
  default     = "default"
}

variable "volume_id" {
  description = "CSI volume ID used by the PR 628 registration write-only case."
  type        = string
  default     = "pr-628-write-only-registration"
}

variable "volume_name" {
  description = "Display name for the registered CSI volume."
  type        = string
  default     = "pr-628-write-only-registration"
}

variable "plugin_id" {
  description = "CSI plugin ID. This plugin must be available in the target Nomad cluster."
  type        = string
  default     = "hostpath"
}

variable "external_id" {
  description = "External storage provider ID for registration mode."
  type        = string
  default     = "pr-628-external-id"
}

variable "capacity_min" {
  description = "Requested minimum capacity for the registered CSI volume."
  type        = string
  default     = "10MiB"
}

variable "secrets" {
  description = "Write-only CSI secrets map encoded into secrets_wo for registration."
  type        = map(string)
  default = {
    registration_key = "pr-628-registration"
    registration_sig = "pr-628-signature"
  }
  sensitive = true
}

variable "secrets_wo_version" {
  description = "Manual version marker for registration secrets_wo updates."
  type        = number
  default     = 1
}

variable "deregister_on_destroy" {
  description = "Whether to deregister the CSI volume when this Terraform resource is destroyed."
  type        = bool
  default     = true
}

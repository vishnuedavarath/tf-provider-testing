variable "auth_method_name" {
  description = "ACL auth method name used by the PR 599 write-only case."
  type        = string
  default     = "local-dex"
}

variable "nomad_address" {
  description = "Optional Nomad API/UI address override used for the OIDC UI redirect URI. If unset, this case reads NOMAD_ADDR from the environment."
  type        = string
  default     = null
  nullable    = true
}

variable "nomad_ui_address" {
  description = "Optional Nomad UI base address used for the OIDC UI redirect URI. If unset, this case falls back to nomad_address/NOMAD_ADDR."
  type        = string
  default     = "http://192.168.2.79:4646"
}

variable "role_binding_rule_name" {
  description = "Bind name used for the role binding rule."
  type        = string
  default     = "engineering-read-only"
}

variable "role_binding_rule_description" {
  description = "Description used for the role binding rule."
  type        = string
  default     = "PR 599 role binding rule"
}

variable "management_binding_rule_description" {
  description = "Description used for the management binding rule."
  type        = string
  default     = "PR 599 management binding rule"
}

variable "client_secret" {
  description = "OIDC client secret passed through the new write-only auth method attribute."
  type        = string
  default     = "8cyXgTgBymOiiHqKMNLmOuFUgTOUCeTC"
  sensitive   = true
}

variable "dex_issuer_url" {
  description = "Issuer URL for the local Dex deployment."
  type        = string
  default     = "http://192.168.2.1:5556/dex"
}

variable "dex_client_id" {
  description = "OIDC client ID configured in Dex for Nomad."
  type        = string
  default     = "nomad-local"
}

variable "oidc_admin_email" {
  description = "Dex user email that should receive a Nomad management token."
  type        = string
  default     = "nomad-admin@example.com"
}

variable "client_secret_version" {
  description = "Version marker for config.oidc_client_secret_wo. Increment to force a new write-only payload."
  type        = number
  default     = 1
}

variable "private_key_version" {
  description = "Version marker for private_key.pem_key_wo. Increment to force a new write-only payload."
  type        = number
  default     = 1
}
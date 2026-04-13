variable "policy_name" {
  description = "ACL policy name used by the PR 596 ephemeral ACL token case."
  type        = string
  default     = "pr596-ephemeral-policy"
}

variable "role_name" {
  description = "ACL role name used by the PR 596 ephemeral ACL token case."
  type        = string
  default     = "pr596-ephemeral-role"
}

variable "token_name" {
  description = "ACL token name used by the PR 596 ephemeral ACL token case."
  type        = string
  default     = "pr596-ephemeral-token"
}

variable "expiration_ttl" {
  description = "TTL assigned to the created ACL token."
  type        = string
  default     = "5m0s"
}

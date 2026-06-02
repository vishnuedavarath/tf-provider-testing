variable "policy_prefix" {
  description = "Prefix for sentinel policy names."
  type        = string
  default     = "pr-624-test"
}

variable "enforcement_level" {
  description = "Enforcement level for the test policies."
  type        = string
  default     = "advisory"
}

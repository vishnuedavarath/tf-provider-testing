variable "namespace" {
  description = "Nomad namespace where the variable should be managed."
  type        = string
  default     = "default"
}

variable "variable_path" {
  description = "Path for the Nomad variable used to test PR 598."
  type        = string
  default     = "pr-598/write-only-variable"
}

variable "variable_value" {
  description = "Write-only value for test_key. Change this with variable_version to test updates."
  type        = string
  default     = "test_value"
  sensitive   = true
}

variable "secondary_value" {
  description = "Write-only value for second_key."
  type        = string
  default     = "second_value"
  sensitive   = true
}

variable "variable_version" {
  description = "Version marker for items_wo. Increment this when variable_value changes."
  type        = number
  default     = 1
}

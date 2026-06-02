variable "variable_path" {
  description = "Nomad variable path used to reproduce PR #625 panic behavior."
  type        = string
  default     = "example/test"
}

variable "secret_value" {
  description = "Secret value written into the Nomad variable items map."
  type        = string
  default     = "abc"
  sensitive   = true
}

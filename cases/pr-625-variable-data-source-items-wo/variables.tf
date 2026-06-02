variable "variable_path" {
  description = "Nomad variable path used for write-only plus data-source-read scenario."
  type        = string
  default     = "example/test-items-wo"
}

variable "secret_value" {
  description = "Secret value written via items_wo and verified through data source read."
  type        = string
  default     = "abc"
  sensitive   = true
}

variable "items_wo_version" {
  description = "Monotonic write-only version used by nomad_variable.items_wo."
  type        = number
  default     = 1
}

variable "node_filter" {
  description = "Filter expression for the nomad_nodes query."
  type        = string
  default     = "Status == \"ready\""
}

variable "node_prefix" {
  description = "Optional prefix filter for node IDs."
  type        = string
  default     = ""
}

variable "node_name" {
  description = "Node name to scope the Nomad client introduction token to."
  type        = string
  default     = "pr595-client"
}

variable "node_pool" {
  description = "Node pool to scope the Nomad client introduction token to."
  type        = string
  default     = "default"
}

variable "ttl" {
  description = "Requested TTL for the Nomad client introduction token."
  type        = string
  default     = "15m"
}

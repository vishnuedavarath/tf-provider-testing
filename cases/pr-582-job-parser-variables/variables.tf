variable "datacenter" {
  description = "HCL2 variable value passed to nomad_job_parser."
  type        = string
  default     = "dc1"
}

variable "image" {
  description = "Container image passed to nomad_job_parser."
  type        = string
  default     = "redis:7.0"
}

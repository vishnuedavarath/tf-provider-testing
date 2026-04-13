output "quota_specification_summary" {
  description = "Summary of the PR 584 quota specification all-fields configuration."
  value = {
    id          = nomad_quota_specification.all_fields.id
    name        = nomad_quota_specification.all_fields.name
    description = nomad_quota_specification.all_fields.description
    region      = local.quota_limit.region
    region_limit = {
      cpu           = local.region_limit.cpu
      cores         = local.region_limit.cores
      memory_mb     = local.region_limit.memory_mb
      memory_max_mb = local.region_limit.memory_max_mb
      devices       = local.region_limit.devices
      storage       = local.region_limit.storage
      node_pools    = local.region_limit.node_pools
    }
  }
}

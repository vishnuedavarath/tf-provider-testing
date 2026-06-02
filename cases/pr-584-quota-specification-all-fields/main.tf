resource "nomad_quota_specification" "all_fields" {
  name        = var.quota_name
  description = "PR 584 quota specification with all QuotaResources fields"

  limits {
    region = var.region

    region_limit {
      cpu           = 2500
      cores         = 4
      memory_mb     = 2048
      memory_max_mb = 4096

      devices {
        name  = "gpu"
        count = 2
      }

      node_pools {
        node_pool     = "batch"
        cpu           = 800
        cores         = 2
        memory_mb     = 1024
        memory_max_mb = 2048

        devices {
          name  = "fpga"
          count = 1
        }

        storage {
          variables_mb    = 30
          host_volumes_mb = 50
        }
      }

      storage {
        variables_mb    = 100
        host_volumes_mb = 500
      }
    }
  }
}

locals {
  quota_limit       = one(nomad_quota_specification.all_fields.limits)
  region_limit      = one(local.quota_limit.region_limit)
  region_storage    = one(local.region_limit.storage)
  node_pool_limit   = one(local.region_limit.node_pools)
  node_pool_storage = one(local.node_pool_limit.storage)
  region_device     = one(local.region_limit.devices)
  node_pool_device  = one(local.node_pool_limit.devices)
}

check "quota_specification_all_fields_round_trip" {
  assert {
    condition     = local.quota_limit.region == var.region
    error_message = "Expected the quota limit region to round-trip correctly."
  }

  assert {
    condition     = local.region_limit.cpu == 2500 && local.region_limit.cores == 4
    error_message = "Expected cpu and cores to be populated in region_limit."
  }

  assert {
    condition     = local.region_limit.memory_mb == 2048 && local.region_limit.memory_max_mb == 4096
    error_message = "Expected memory limits to be populated in region_limit."
  }

  assert {
    condition     = local.region_device.name == "gpu" && local.region_device.count == 2
    error_message = "Expected region-level device quota to round-trip correctly."
  }

  assert {
    condition     = local.region_storage.variables_mb == 100 && local.region_storage.host_volumes_mb == 500
    error_message = "Expected region-level storage quota to round-trip correctly."
  }

  assert {
    condition     = local.node_pool_limit.node_pool == "batch"
    error_message = "Expected node pool quota to target the batch node pool."
  }

  assert {
    condition     = local.node_pool_limit.cpu == 800 && local.node_pool_limit.cores == 2
    error_message = "Expected node-pool cpu and cores to round-trip correctly."
  }

  assert {
    condition     = local.node_pool_limit.memory_mb == 1024 && local.node_pool_limit.memory_max_mb == 2048
    error_message = "Expected node-pool memory limits to round-trip correctly."
  }

  assert {
    condition     = local.node_pool_device.name == "fpga" && local.node_pool_device.count == 1
    error_message = "Expected node-pool device quota to round-trip correctly."
  }

  assert {
    condition     = local.node_pool_storage.variables_mb == 25 && local.node_pool_storage.host_volumes_mb == 50
    error_message = "Expected node-pool storage quota to round-trip correctly."
  }
}

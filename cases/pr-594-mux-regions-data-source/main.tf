data "nomad_regions" "all" {}

check "regions_data_source_is_served_through_muxed_provider" {
  assert {
    condition     = length(data.nomad_regions.all.regions) >= 1
    error_message = "Expected nomad_regions to return at least one region through the muxed provider."
  }

  assert {
    condition     = contains(data.nomad_regions.all.regions, "global") || contains(data.nomad_regions.all.regions, "default") || length(data.nomad_regions.all.regions) > 0
    error_message = "Expected nomad_regions to expose a non-empty list of regions through the muxed provider."
  }
}

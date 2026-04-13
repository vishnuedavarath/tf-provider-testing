output "regions_summary" {
  description = "Summary of the SDKv2 nomad_regions data source being served by the muxed provider introduced in PR 594."
  value = {
    region_count = length(data.nomad_regions.all.regions)
    regions      = data.nomad_regions.all.regions
  }
}

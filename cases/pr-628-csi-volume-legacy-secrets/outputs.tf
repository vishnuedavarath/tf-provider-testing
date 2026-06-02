output "csi_volume_legacy_secrets_metadata" {
  description = "Metadata for the PR 628 nomad_csi_volume legacy secrets case."
  value = {
    id         = nomad_csi_volume.legacy_secrets.id
    namespace  = nomad_csi_volume.legacy_secrets.namespace
    volume_id  = nomad_csi_volume.legacy_secrets.volume_id
    name       = nomad_csi_volume.legacy_secrets.name
    plugin_id  = nomad_csi_volume.legacy_secrets.plugin_id
  }
}

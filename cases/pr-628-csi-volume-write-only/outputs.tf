output "csi_volume_write_only_metadata" {
  description = "Metadata for the PR 628 nomad_csi_volume write-only secrets case."
  value = {
    id                 = nomad_csi_volume.write_only.id
    namespace          = nomad_csi_volume.write_only.namespace
    volume_id          = nomad_csi_volume.write_only.volume_id
    name               = nomad_csi_volume.write_only.name
    plugin_id          = nomad_csi_volume.write_only.plugin_id
    secrets_wo_version = nomad_csi_volume.write_only.secrets_wo_version
  }
}

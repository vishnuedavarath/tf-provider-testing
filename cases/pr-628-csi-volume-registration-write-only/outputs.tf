output "csi_volume_registration_write_only_metadata" {
  description = "Metadata for the PR 628 nomad_csi_volume_registration write-only secrets case."
  value = {
    id          = nomad_csi_volume_registration.write_only.id
    namespace   = nomad_csi_volume_registration.write_only.namespace
    volume_id   = nomad_csi_volume_registration.write_only.volume_id
    name        = nomad_csi_volume_registration.write_only.name
    plugin_id   = nomad_csi_volume_registration.write_only.plugin_id
    external_id = nomad_csi_volume_registration.write_only.external_id
    # secrets_wo_version    = nomad_csi_volume_registration.write_only.secrets_wo_version
    deregister_on_destroy = nomad_csi_volume_registration.write_only.deregister_on_destroy
  }
}

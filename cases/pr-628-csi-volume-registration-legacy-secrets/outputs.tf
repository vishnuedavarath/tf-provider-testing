output "csi_volume_registration_legacy_secrets_metadata" {
  description = "Metadata for the PR 628 nomad_csi_volume_registration legacy secrets case."
  value = {
    id                    = nomad_csi_volume_registration.legacy_secrets.id
    namespace             = nomad_csi_volume_registration.legacy_secrets.namespace
    volume_id             = nomad_csi_volume_registration.legacy_secrets.volume_id
    name                  = nomad_csi_volume_registration.legacy_secrets.name
    plugin_id             = nomad_csi_volume_registration.legacy_secrets.plugin_id
    external_id           = nomad_csi_volume_registration.legacy_secrets.external_id
    deregister_on_destroy = nomad_csi_volume_registration.legacy_secrets.deregister_on_destroy
  }
}

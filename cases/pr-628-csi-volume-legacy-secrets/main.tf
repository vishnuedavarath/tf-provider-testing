resource "nomad_csi_volume" "legacy_secrets" {
  namespace    = var.namespace
  volume_id    = var.volume_id
  name         = var.volume_name
  plugin_id    = var.plugin_id
  capacity_min = var.capacity_min
  secrets      = var.secrets

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

check "csi_volume_legacy_secrets_state" {
  assert {
    condition     = nomad_csi_volume.legacy_secrets.volume_id == var.volume_id
    error_message = "Expected nomad_csi_volume.volume_id to retain the configured value."
  }

  assert {
    condition     = nomad_csi_volume.legacy_secrets.name == var.volume_name
    error_message = "Expected nomad_csi_volume.name to retain the configured value."
  }

  assert {
    condition     = nomad_csi_volume.legacy_secrets.secrets != null
    error_message = "Expected legacy secrets to be persisted in state (deprecated behavior)."
  }
}

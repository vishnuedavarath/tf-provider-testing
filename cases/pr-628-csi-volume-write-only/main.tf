resource "nomad_csi_volume" "write_only" {
  namespace          = var.namespace
  volume_id          = var.volume_id
  name               = var.volume_name
  plugin_id          = var.plugin_id
  capacity_min       = var.capacity_min
  secrets_wo         = jsonencode(var.secrets)
  secrets_wo_version = var.secrets_wo_version

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

check "csi_volume_write_only_state" {
  assert {
    condition     = nomad_csi_volume.write_only.volume_id == var.volume_id
    error_message = "Expected nomad_csi_volume.volume_id to retain the configured value."
  }

  assert {
    condition     = nomad_csi_volume.write_only.name == var.volume_name
    error_message = "Expected nomad_csi_volume.name to retain the configured value."
  }

  assert {
    condition     = nomad_csi_volume.write_only.secrets_wo_version == var.secrets_wo_version
    error_message = "Expected nomad_csi_volume.secrets_wo_version to track the configured version."
  }
}

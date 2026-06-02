resource "nomad_sentinel_policy" "submit_job" {
  name              = "${var.policy_prefix}-submit-job"
  description       = "Test existing submit-job scope"
  policy            = "main = rule { true }"
  scope             = "submit-job"
  enforcement_level = var.enforcement_level
}

resource "nomad_sentinel_policy" "submit_host_volume" {
  name              = "${var.policy_prefix}-submit-host-volume"
  description       = "Test new submit-host-volume scope (PR 624)"
  policy            = "main = rule { true }"
  scope             = "submit-host-volume"
  enforcement_level = var.enforcement_level
}

resource "nomad_sentinel_policy" "submit_csi_volume" {
  name              = "${var.policy_prefix}-submit-csi-volume"
  description       = "Test new submit-csi-volume scope (PR 624)"
  policy            = "main = rule { true }"
  scope             = "submit-csi-volume"
  enforcement_level = var.enforcement_level
}


check "sentinel_scopes_created" {
  assert {
    condition     = nomad_sentinel_policy.submit_job.scope == "submit-job"
    error_message = "Expected submit-job scope to be accepted."
  }

  assert {
    condition     = nomad_sentinel_policy.submit_host_volume.scope == "submit-host-volume"
    error_message = "Expected submit-host-volume scope to be accepted."
  }

  assert {
    condition     = nomad_sentinel_policy.submit_csi_volume.scope == "submit-csi-volume"
    error_message = "Expected submit-csi-volume scope to be accepted."
  }
}

check "sentinel_enforcement_levels" {
  assert {
    condition     = nomad_sentinel_policy.submit_job.enforcement_level == var.enforcement_level
    error_message = "Expected submit-job policy to retain the configured enforcement level."
  }

  assert {
    condition     = nomad_sentinel_policy.submit_host_volume.enforcement_level == var.enforcement_level
    error_message = "Expected submit-host-volume policy to retain the configured enforcement level."
  }

  assert {
    condition     = nomad_sentinel_policy.submit_csi_volume.enforcement_level == var.enforcement_level
    error_message = "Expected submit-csi-volume policy to retain the configured enforcement level."
  }
}

check "sentinel_descriptions" {
  assert {
    condition     = nomad_sentinel_policy.submit_host_volume.description == "Test new submit-host-volume scope (PR 624)"
    error_message = "Expected submit-host-volume policy to retain its description."
  }

  assert {
    condition     = nomad_sentinel_policy.submit_csi_volume.description == "Test new submit-csi-volume scope (PR 624)"
    error_message = "Expected submit-csi-volume policy to retain its description."
  }
}

# This configuration should fail at plan time with a validation error.
# The scope "invalid-scope" is not in the allowed set:
#   ["submit-job", "submit-host-volume", "submit-csi-volume"]
#
# Expected error:
#   expected scope to be one of ["submit-job" "submit-host-volume" "submit-csi-volume"],
#   got invalid-scope

resource "nomad_sentinel_policy" "bad_scope" {
  name              = "pr-624-invalid-scope"
  description       = "This should be rejected by validation"
  policy            = "main = rule { true }"
  scope             = "invalid-scope"
  enforcement_level = "advisory"
}

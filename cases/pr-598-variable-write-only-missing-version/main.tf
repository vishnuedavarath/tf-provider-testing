resource "nomad_variable" "missing_version" {
  path = "pr-598/write-only-missing-version"

  items_wo = jsonencode({
    test_key = "test_value"
  })
}

resource "nomad_variable" "missing_version" {
  path = "pr-598/write-only-missing-version"
  items_wo = jsonencode({
    test_key   = "test_value_2"
    second_key = "second_value_2"
  })
  items_wo_version = 3
}

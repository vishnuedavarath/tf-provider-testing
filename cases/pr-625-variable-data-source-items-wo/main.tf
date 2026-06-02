resource "nomad_variable" "test" {
  path             = var.variable_path
  items_wo         = jsonencode({ secret = var.secret_value })
  items_wo_version = var.items_wo_version
}

data "nomad_variable" "test" {
  path       = var.variable_path
  depends_on = [nomad_variable.test]
}

check "data_source_reads_write_only_value" {
  assert {
    condition     = try(data.nomad_variable.test.items["secret"], null) == var.secret_value
    error_message = "Expected data.nomad_variable.test.items.secret to match the write-only input value."
  }

  assert {
    condition     = try(nomad_variable.test.items, null) == null
    error_message = "Expected managed resource state to keep items absent when items_wo is used."
  }
}

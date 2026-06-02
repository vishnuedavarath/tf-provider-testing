resource "nomad_variable" "test" {
  path = var.variable_path
  items = {
    secret = var.secret_value
  }
}

data "nomad_variable" "test" {
  path       = var.variable_path
  depends_on = [nomad_variable.test]
}

check "data_source_reads_items_without_panic" {
  assert {
    condition     = try(data.nomad_variable.test.items["secret"], null) == var.secret_value
    error_message = "Expected the data source read to return items.secret without crashing."
  }
}

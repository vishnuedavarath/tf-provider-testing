resource "nomad_variable" "write_only" {
  namespace = var.namespace
  path      = var.variable_path
  items_wo = jsonencode({
    test_key   = var.variable_value
    second_key = var.secondary_value
  })
  items_wo_version = var.variable_version
}



locals {
  write_only_variable_id_parts = split("@", nomad_variable.write_only.id)
}

ephemeral "nomad_variable" "write_only" {
  path      = local.write_only_variable_id_parts[0]
  namespace = local.write_only_variable_id_parts[1]
}

resource "terraform_data" "ephemeral_summary_file" {
  triggers_replace = [
    nomad_variable.write_only.id,
    tostring(var.variable_version),
  ]

  provisioner "local-exec" {
    command = <<-EOT
      cat > "$SUMMARY_FILE" <<EOF
      {
        "namespace": "$NAMESPACE",
        "path": "$VARIABLE_PATH",
        "item_keys": $ITEM_KEYS,
        "items": $ITEMS,
        "values_match_inputs": $VALUES_MATCH_INPUTS
      }
      EOF
    EOT

    environment = {
      SUMMARY_FILE  = "${path.module}/ephemeral_variable_summary.json"
      NAMESPACE     = ephemeral.nomad_variable.write_only.namespace
      VARIABLE_PATH = ephemeral.nomad_variable.write_only.path
      ITEM_KEYS     = jsonencode(sort(keys(nonsensitive(ephemeral.nomad_variable.write_only.items))))
      ITEMS         = jsonencode(nonsensitive(ephemeral.nomad_variable.write_only.items))
      VALUES_MATCH_INPUTS = jsonencode(
        try(ephemeral.nomad_variable.write_only.items.test_key, null) == var.variable_value &&
        try(ephemeral.nomad_variable.write_only.items.second_key, null) == var.secondary_value
      )
    }
  }
}

check "write_only_variable_round_trip" {
  assert {
    condition     = try(ephemeral.nomad_variable.write_only.items.test_key, null) == var.variable_value
    error_message = "Expected the ephemeral variable read to return the write-only test_key value."
  }

  assert {
    condition     = try(ephemeral.nomad_variable.write_only.items.second_key, null) == var.secondary_value
    error_message = "Expected the ephemeral variable read to return the write-only second_key value."
  }

  assert {
    condition     = try(nomad_variable.write_only.items, null) == null
    error_message = "Expected write-only variable items to remain absent from managed resource state."
  }
}

ephemeral "nomad_node_intro_token" "client" {
  node_name = var.node_name
  node_pool = var.node_pool
  ttl       = var.ttl
}

resource "terraform_data" "intro_token_files" {
  triggers_replace = [
    var.node_name,
    var.node_pool,
    var.ttl,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      cat > "$SUMMARY_FILE" <<EOF
      {
        "node_name": "$NODE_NAME",
        "node_pool": "$NODE_POOL",
        "ttl": "$TTL",
        "jwt_segment_count": $JWT_SEGMENT_COUNT,
        "jwt_looks_valid": $JWT_LOOKS_VALID,
        "jwt_length": $JWT_LENGTH
      }
      EOF
      printf '%s\n' "$INTRO_TOKEN_JWT" > "$JWT_FILE"
    EOT

    environment = {
      SUMMARY_FILE      = "${path.module}/intro_token_summary.json"
      JWT_FILE          = "${path.module}/intro_token.jwt"
      NODE_NAME         = var.node_name
      NODE_POOL         = var.node_pool
      TTL               = var.ttl
      INTRO_TOKEN_JWT   = ephemeral.nomad_node_intro_token.client.jwt
      JWT_SEGMENT_COUNT = tostring(length(split(".", nonsensitive(ephemeral.nomad_node_intro_token.client.jwt))))
      JWT_LOOKS_VALID   = jsonencode(length(split(".", nonsensitive(ephemeral.nomad_node_intro_token.client.jwt))) == 3 && length(nonsensitive(ephemeral.nomad_node_intro_token.client.jwt)) > 20)
      JWT_LENGTH        = tostring(length(nonsensitive(ephemeral.nomad_node_intro_token.client.jwt)))
    }
  }
}

check "node_intro_token_can_be_created_and_consumed" {
  assert {
    condition     = length(nonsensitive(ephemeral.nomad_node_intro_token.client.jwt)) > 20
    error_message = "Expected nomad_node_intro_token to return a non-empty JWT."
  }

  assert {
    condition     = length(split(".", nonsensitive(ephemeral.nomad_node_intro_token.client.jwt))) == 3
    error_message = "Expected nomad_node_intro_token.jwt to look like a three-segment JWT."
  }
}

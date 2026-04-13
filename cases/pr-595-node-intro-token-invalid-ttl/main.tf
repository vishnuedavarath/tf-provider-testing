ephemeral "nomad_node_intro_token" "invalid_ttl" {
  node_name = "pr595-invalid-ttl"
  ttl       = "not-a-duration"
}

resource "terraform_data" "sink" {
  triggers_replace = ["pr595-invalid-ttl"]

  provisioner "local-exec" {
    command = "printf '%s\n' \"$INTRO_TOKEN_JWT\" > /dev/null"

    environment = {
      INTRO_TOKEN_JWT = ephemeral.nomad_node_intro_token.invalid_ttl.jwt
    }
  }
}

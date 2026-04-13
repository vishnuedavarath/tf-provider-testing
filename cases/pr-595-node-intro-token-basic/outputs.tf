output "intro_token_artifacts" {
  description = "Artifacts written from the PR 595 nomad_node_intro_token ephemeral resource during apply."
  value = {
    node_name         = var.node_name
    node_pool         = var.node_pool
    ttl               = var.ttl
    jwt_file_path     = "${path.module}/intro_token.jwt"
    summary_file_path = "${path.module}/intro_token_summary.json"
  }
}

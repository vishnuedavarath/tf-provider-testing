resource "nomad_namespace" "invalid_vault_and_consul_config" {
  name        = "pr-581-conflicting-vault-consul-config"
  description = "PR 581 validation coverage for conflicting allowed and denied values"

  vault_config {
    default = "default"
    allowed = ["prod"]
    denied  = ["dev"]
  }

  consul_config {
    default = "default"
    allowed = ["prod"]
    denied  = ["dev"]
  }
}

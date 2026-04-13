resource "nomad_namespace" "namespace_with_cluster_config" {
  name        = var.namespace_name
  description = "PR 581 namespace vault_config and consul_config coverage"

  vault_config {
    default = "prod-vault"
    allowed = ["prod", "staging"]
  }

  consul_config {
    default = "prod-consul"
    denied  = ["dev", "test"]
  }
}

data "nomad_namespace" "namespace_with_cluster_config" {
  name = nomad_namespace.namespace_with_cluster_config.name
}

check "vault_and_consul_config_round_trip" {
  assert {
    condition     = nomad_namespace.namespace_with_cluster_config.vault_config[0].default == "prod-vault"
    error_message = "Expected vault_config.default to be prod-vault on the namespace resource."
  }

  assert {
    condition     = data.nomad_namespace.namespace_with_cluster_config.vault_config[0].allowed == toset(["prod", "staging"])
    error_message = "Expected data source vault_config.allowed to match the configured set."
  }

  assert {
    condition     = nomad_namespace.namespace_with_cluster_config.consul_config[0].default == "prod-consul"
    error_message = "Expected consul_config.default to be prod-consul on the namespace resource."
  }

  assert {
    condition     = data.nomad_namespace.namespace_with_cluster_config.consul_config[0].denied == toset(["dev", "test"])
    error_message = "Expected data source consul_config.denied to match the configured set."
  }
}

output "namespace_cluster_config" {
  value = {
    id          = nomad_namespace.namespace_with_cluster_config.id
    name        = nomad_namespace.namespace_with_cluster_config.name
    description = nomad_namespace.namespace_with_cluster_config.description
    vault_config = {
      default = data.nomad_namespace.namespace_with_cluster_config.vault_config[0].default
      allowed = tolist(data.nomad_namespace.namespace_with_cluster_config.vault_config[0].allowed)
      denied  = tolist(data.nomad_namespace.namespace_with_cluster_config.vault_config[0].denied)
    }
    consul_config = {
      default = data.nomad_namespace.namespace_with_cluster_config.consul_config[0].default
      allowed = tolist(data.nomad_namespace.namespace_with_cluster_config.consul_config[0].allowed)
      denied  = tolist(data.nomad_namespace.namespace_with_cluster_config.consul_config[0].denied)
    }
  }
}

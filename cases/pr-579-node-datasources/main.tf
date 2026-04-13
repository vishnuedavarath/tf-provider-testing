data "nomad_nodes" "matching" {
  filter    = var.node_filter
  prefix    = var.node_prefix
  os        = true
  resources = true
}

locals {
  selected_node_id = one(slice(data.nomad_nodes.matching.nodes[*].id, 0, 1))
}

data "nomad_node" "selected" {
  node_id = local.selected_node_id
}

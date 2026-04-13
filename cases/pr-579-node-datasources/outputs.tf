output "matching_node_ids" {
  value = data.nomad_nodes.matching.nodes[*].id
}

output "matching_node_summary" {
  value = [
    for node in data.nomad_nodes.matching.nodes : {
      id                     = node.id
      name                   = node.name
      datacenter             = node.datacenter
      node_pool              = node.node_pool
      status                 = node.status
      scheduling_eligibility = node.scheduling_eligibility
      os_name                = try(node.attributes["os.name"], null)
      driver_names           = [for driver in node.drivers : driver.name]
      cpu_shares             = try(node.node_resources[0].cpu[0].cpu_shares, null)
      memory_mb              = try(node.node_resources[0].memory[0].memory_mb, null)
      reserved_host_ports    = try(node.reserved_resources[0].networks.reserved_host_ports, null)
    }
  ]
}

output "selected_node_details" {
  value = {
    id                     = data.nomad_node.selected.node_id
    name                   = data.nomad_node.selected.name
    http_addr              = data.nomad_node.selected.http_addr
    datacenter             = data.nomad_node.selected.datacenter
    node_class             = data.nomad_node.selected.node_class
    node_pool              = data.nomad_node.selected.node_pool
    status                 = data.nomad_node.selected.status
    status_description     = data.nomad_node.selected.status_description
    scheduling_eligibility = data.nomad_node.selected.scheduling_eligibility
    os_name                = try(data.nomad_node.selected.attributes["os.name"], null)
    driver_details = [
      for driver in data.nomad_node.selected.drivers : {
        name       = driver.name
        detected   = driver.detected
        healthy    = driver.healthy
        attributes = driver.attributes
      }
    ]
    host_volumes = [
      for volume in data.nomad_node.selected.host_volumes : {
        name      = volume.name
        path      = volume.path
        read_only = volume.read_only
        id        = volume.id
      }
    ]
    node_resources     = try(data.nomad_node.selected.node_resources[0], null)
    reserved_resources = try(data.nomad_node.selected.reserved_resources[0], null)
  }
}

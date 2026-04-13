output "write_only_variable_metadata" {
  description = "Metadata for the write-only Nomad variable resource."
  value = {
    id               = nomad_variable.write_only.id
    namespace        = nomad_variable.write_only.namespace
    path             = nomad_variable.write_only.path
    items_wo_version = var.variable_version
  }
}

output "ephemeral_summary_file_path" {
  description = "Path to the JSON file written from the ephemeral Nomad variable read during apply."
  value       = "${path.module}/ephemeral_variable_summary.json"
}

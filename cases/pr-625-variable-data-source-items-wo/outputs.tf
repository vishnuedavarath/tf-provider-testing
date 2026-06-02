output "secret" {
  value     = data.nomad_variable.test.items["secret"]
  sensitive = true
}

output "resource_id" {
  description = "ID of the write-only variable resource."
  value       = nomad_variable.test.id
}

output "write_only_version" {
  description = "Write-only version used for the items_wo update."
  value       = var.items_wo_version
}

output "secret" {
  value     = data.nomad_variable.test.items["secret"]
  sensitive = true
}

output "variable_path" {
  description = "Path used for the panic reproduction/verification scenario."
  value       = var.variable_path
}

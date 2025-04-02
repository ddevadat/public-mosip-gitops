output "application" {
  description = "Deployment Results"
  value       = data.local_file.output.content

}


data "local_file" "output" {
  filename = "${local.ansible_output_dir}/outputs.txt"
  depends_on = [
    local_sensitive_file.deployment_status
  ]
}

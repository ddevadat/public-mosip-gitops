locals {
  jumphostmap = {
    ansible_ssh_common_args = "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -i ${local_sensitive_file.compute_ssh_key.filename} -o StrictHostKeyChecking=no -q ${var.ansible_bastion_os_username}@${var.ansible_bastion_public_ip}\""
  }
  ansible_output_dir = "${var.ansible_base_output_dir}/${var.env}"
  ssh_private_key_file_map = {
    ansible_ssh_private_key_file = local_sensitive_file.compute_ssh_key.filename
  }
  all_hosts_var_maps = {
    ansible_ssh_user    = "opc"
    ansible_ssh_retries = "10"
  }

}


# data "local_file" "output" {
#   filename = "${var.ansible_base_output_dir}/functional-registry-app/outputs.txt"
#   depends_on = [
#     null_resource.run_ansible
#   ]
# }

# output "file_content" {
#   description = "Content of the specified file"
#   value       = data.local_file.output.content

# }
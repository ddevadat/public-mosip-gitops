
resource "local_sensitive_file" "ansible_inventory" {
  content = templatefile(
    "${path.module}/templates/inventory.yaml.tmpl",
    { all_hosts               = merge(var.operator_hosts_maps),
      operator_hosts_maps     = var.operator_hosts_maps,
      operator_hosts_var_maps = merge(var.operator_hosts_var_maps, local.jumphostmap),
    all_hosts_var_maps = merge(local.all_hosts_var_maps, local.ssh_private_key_file_map) }

  )
  filename        = "${local.ansible_output_dir}/inventory"
  file_permission = "0600"
}

resource "local_sensitive_file" "compute_ssh_key" {
  content         = base64decode(var.ssh_private_key)
  filename        = "${local.ansible_output_dir}/sshkey"
  file_permission = "0600"
}


resource "local_sensitive_file" "deployment_status" {
  content = templatefile(
    "${path.module}/templates/outputs.txt.tmpl",
    { domain            = var.operator_hosts_var_maps["domain"],
      bastion_public_ip = var.operator_hosts_var_maps["bastion_public_ip"],
      workload_name     = var.operator_hosts_var_maps["workload_name"],
  bastion_ssh_key = base64decode(var.ssh_private_key) })
  filename        = "${local.ansible_output_dir}/outputs.txt"
  file_permission = "0600"
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command     = <<-EOT
          ansible-galaxy collection install ${var.ansible_collection_url},${var.ansible_collection_tag}
          ansible-playbook generic.iac.generic_deploy -i ${local_sensitive_file.ansible_inventory.filename}
    EOT
    working_dir = path.module
  }
  triggers = {
    inventory_file_sha_hex = local_sensitive_file.ansible_inventory.id
    ansible_collection_tag = var.ansible_collection_tag
  }
  depends_on = [
    local_sensitive_file.ansible_inventory
  ]
}


# resource "null_resource" "run_ansible_undeploy" {
#   provisioner "local-exec" {
#     when        = destroy
#     command     = <<-EOT
#           echo "Run ansible playbook for undeploy"
#           ansible-playbook generic.iac.generic_undeploy -i ${self.triggers.inventory_file_name}
#     EOT
#     working_dir = path.module
#   }
#   triggers = {
#     ansible_collection_url = var.ansible_collection_url
#     ansible_collection_tag = var.ansible_collection_tag
#     inventory_file_name    = local_sensitive_file.ansible_inventory.filename

#   }
#   depends_on = [
#     local_sensitive_file.ansible_inventory
#   ]
# }





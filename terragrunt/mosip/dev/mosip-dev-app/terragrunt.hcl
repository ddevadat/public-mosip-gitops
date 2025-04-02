terraform {
  source = "git::${get_env("IAC_TERRAFORM_MODULES_REPO")}//terraform/ansible/mosip-app?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}

dependency "mosip_infra" {
  config_path = "../mosip-dev-infra"
  mock_outputs = {
    operator_hosts_maps       = {}
    operator_hosts_var_maps   = {}
    ssh_private_key           = "key"
    ansible_bastion_public_ip = "null"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  operator_hosts_maps       = dependency.mosip_infra.outputs.workload.operator_hosts_maps
  operator_hosts_var_maps   = dependency.mosip_infra.outputs.workload.operator_hosts_var_maps
  ansible_bastion_public_ip = dependency.mosip_infra.outputs.workload.bastion_public_ip
  ssh_private_key           = dependency.mosip_infra.outputs.workload.compute_ssh_key
  env                       = local.env_vars.env
}

locals {
  env_vars = yamldecode(
  file("${find_in_parent_folders("environment.yaml")}"))
}

include "root" {
  path = find_in_parent_folders()
}
